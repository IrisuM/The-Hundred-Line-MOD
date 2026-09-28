#include "patches.h"
#include "version.h"
#include "generated/winmm_exports.h"
#include <cstdio>
#include <cstdarg>
#include <cmath>
#include <cwchar>
#include <cstdlib>

static HMODULE selfModule;
static HMODULE realWinmm;
static INIT_ONCE initializeOnce = INIT_ONCE_STATIC_INIT;
static std::wstring modDirectory;
static uint32_t materialPercent = 500;
static uint32_t rateOffset;
static FARPROC realExports[sizeof(exportNames) / sizeof(exportNames[0])]{};

static void logLine(const char *format, ...)
{
    auto path = modDirectory + L"HundredLineMod.log";
    FILE *file{};
    if (_wfopen_s(&file, path.c_str(), L"a") || !file)
        return;
    SYSTEMTIME now{};
    GetLocalTime(&now);
    fprintf(file, "[%04u-%02u-%02u %02u:%02u:%02u] ", now.wYear, now.wMonth, now.wDay, now.wHour, now.wMinute,
            now.wSecond);
    va_list args;
    va_start(args, format);
    vfprintf(file, format, args);
    va_end(args);
    fputc('\n', file);
    fclose(file);
}

static uint32_t __fastcall lockedRate(const void *object, uint32_t kind)
{
    return hl::rateValue(object, kind, rateOffset, materialPercent);
}

static bool flag(const wchar_t *name, const std::wstring &ini)
{
    wchar_t value[32]{};
    GetPrivateProfileStringW(L"Mod", name, L"1", value, 32, ini.c_str());
    if (!wcscmp(value, L"1"))
        return true;
    if (!wcscmp(value, L"0"))
        return false;
    throw std::runtime_error("Boolean options must be 0 or 1");
}

static void applyMod()
{
    wchar_t host[32768]{};
    GetModuleFileNameW(nullptr, host, 32768);
    auto filename = wcsrchr(host, L'\\');
    if (_wcsicmp(filename ? filename + 1 : host, L"HUNDRED_LINE.exe"))
        return;
    logLine("HundredLineMod %s initializing; x64 signature patches", HL_MOD_VERSION);
    try
    {
        auto ini = modDirectory + L"HundredLineMod.ini";
        if (!flag(L"Enabled", ini))
        {
            logLine("Disabled by config");
            return;
        }
        bool rate = flag(L"LockExplorationMaterials", ini);
        bool gift = flag(L"ShowGiftPreferences", ini);
        wchar_t value[64]{};
        wchar_t *end{};
        GetPrivateProfileStringW(L"Mod", L"MaterialMultiplier", L"5.0", value, 64, ini.c_str());
        double multiplier = wcstod(value, &end);
        if (end == value || *end || !std::isfinite(multiplier) || multiplier < 1.0 || multiplier > 100.0)
            throw std::runtime_error("MaterialMultiplier must be between 1.0 and 100.0");
        materialPercent = static_cast<uint32_t>(std::llround(multiplier * 100.0));
        auto image = GetModuleHandleW(nullptr);
        auto targets = hl::locate(image, rate, gift); // Validate all enabled signatures before any writes.
        uint8_t originalRate[16]{};
        if (rate)
        {
            rateOffset = targets.displacement;
            memcpy(originalRate, targets.rate, 16);
            auto jump = hl::absoluteJump(reinterpret_cast<const void *>(&lockedRate));
            if (!hl::writeCode(targets.rate, jump.data(), jump.size()))
            {
                hl::writeCode(targets.rate, originalRate, 16);
                throw std::runtime_error("Could not install material patch");
            }
        }
        if (gift)
        {
            uint8_t alwaysJump = 0xeb;
            if (!hl::writeCode(targets.gift, &alwaysJump, 1))
            {
                uint8_t conditional = 0x75;
                hl::writeCode(targets.gift, &conditional, 1);
                if (rate)
                    hl::writeCode(targets.rate, originalRate, 16);
                throw std::runtime_error("Could not install gift patch; rollback requested");
            }
        }
        if (rate)
            logLine("APPLIED materials and coins: %.2fx, RVA=0x%llX, object offset=0x%X",
                    materialPercent / 100.0,
                    static_cast<unsigned long long>(targets.rate - reinterpret_cast<uint8_t *>(image)),
                    rateOffset);
        if (gift)
            logLine("APPLIED gift preferences: RVA=0x%llX",
                    static_cast<unsigned long long>(targets.gift - reinterpret_cast<uint8_t *>(image)));
        logLine("Initialization complete");
    }
    catch (const std::exception &e)
    {
        logLine("NOT APPLIED: %s", e.what());
    }
}

static BOOL CALLBACK initialize(PINIT_ONCE, PVOID, PVOID *)
{
    wchar_t path[32768]{};
    GetModuleFileNameW(selfModule, path, 32768);
    modDirectory = path;
    modDirectory.resize(modDirectory.find_last_of(L"\\/") + 1);
    wchar_t system[MAX_PATH]{};
    if (!GetSystemDirectoryW(system, MAX_PATH))
        return FALSE;
    std::wstring library = std::wstring(system) + L"\\winmm.dll";
    realWinmm = LoadLibraryExW(library.c_str(), nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (!realWinmm)
    {
        logLine("Cannot load system winmm.dll: %lu", GetLastError());
        return FALSE;
    }
    for (size_t i = 0; i < sizeof(exportNames) / sizeof(exportNames[0]); ++i)
    {
        realExports[i] =
            GetProcAddress(realWinmm, exportNames[i] ? exportNames[i] : MAKEINTRESOURCEA(exportOrdinals[i]));
        if (!realExports[i])
        {
            logLine("Missing system export ordinal: %u", exportOrdinals[i]);
            return FALSE;
        }
    }
    // Export calls occur after loader initialization; no scanning or LoadLibrary in DllMain.
    applyMod();
    // Keep hook targets alive for the process lifetime.
    HMODULE pinned{};
    GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                       reinterpret_cast<LPCWSTR>(&lockedRate), &pinned);
    return TRUE;
}
extern "C" FARPROC ResolveWinmm(unsigned index)
{
    // The assembly dispatcher preserves all Windows x64 argument registers.
    if (!InitOnceExecuteOnce(&initializeOnce, initialize, nullptr, nullptr) ||
        index >= sizeof(exportNames) / sizeof(exportNames[0]) || !realExports[index])
    {
        RaiseFailFastException(nullptr, nullptr, 0);
        return nullptr;
    }
    return realExports[index];
}
BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID)
{
    if (reason == DLL_PROCESS_ATTACH)
    {
        selfModule = module;
        DisableThreadLibraryCalls(module);
    }
    return TRUE;
}
