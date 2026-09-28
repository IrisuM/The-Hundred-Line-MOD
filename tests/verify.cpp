#include "patches.h"
#include "generated/winmm_exports.h"
#include <cstdio>
#include <array>
#include <mmsystem.h>

extern "C" void InvokeGift(void *code, void *record, void *context, unsigned known);
static uint32_t testOffset;
static uint32_t __fastcall testRate(const void *object, uint32_t kind)
{
    return hl::rateValue(object, kind, testOffset, 500);
}
static void require(bool okay, const char *message)
{
    if (!okay)
        throw std::runtime_error(message);
}

int wmain(int argc, wchar_t **argv)
{
    try
    {
        require(argc >= 2, "Usage: verify.exe HUNDRED_LINE.exe [winmm.dll]");
        HANDLE file =
            CreateFileW(argv[1], GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                        nullptr, OPEN_EXISTING, 0, nullptr);
        require(file != INVALID_HANDLE_VALUE, "Cannot read game EXE");
        HANDLE mapping = CreateFileMappingW(file, nullptr, PAGE_READONLY | SEC_IMAGE, 0, 0, nullptr);
        CloseHandle(file);
        require(mapping != nullptr, "Cannot map game image");
        void *image = MapViewOfFile(mapping, FILE_MAP_READ, 0, 0, 0);
        CloseHandle(mapping);
        require(image != nullptr, "Cannot map view");
        auto t = hl::locate(image, true, true);
        printf("PASS unique signatures: rate RVA=%llX gift RVA=%llX displacement=%X\n",
               static_cast<unsigned long long>(t.rate - static_cast<uint8_t *>(image)),
               static_cast<unsigned long long>(t.gift - static_cast<uint8_t *>(image)), t.displacement);

        // Execute a copy of the actual 16-byte game getter with synthetic objects.
        // Neither the game image nor its on-disk executable is modified.
        auto executable =
            static_cast<uint8_t *>(VirtualAlloc(nullptr, 4096, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE));
        require(executable != nullptr, "Allocation failed");
        memcpy(executable, t.rate, 16);
        DWORD previous{};
        require(VirtualProtect(executable, 4096, PAGE_EXECUTE_READ, &previous) != FALSE,
                "Cannot protect test page");
        FlushInstructionCache(GetCurrentProcess(), executable, 4096);
        using Getter = uint32_t(__fastcall *)(const void *, uint32_t);
        auto getter = reinterpret_cast<Getter>(executable);
        std::vector<uint8_t> object(t.displacement + 20, 0);
        uint32_t values[] = {175, 120, 230, 340, 450};
        memcpy(object.data() + t.displacement, values, sizeof(values));
        require(getter(object.data(), 1) == 120 && getter(object.data(), 4) == 450 &&
                    getter(object.data(), 5) == 175 && getter(object.data(), UINT32_MAX) == 175,
                "Unexpected original getter behavior");
        testOffset = t.displacement;
        auto jump = hl::absoluteJump(reinterpret_cast<const void *>(&testRate));
        require(hl::writeCode(executable, jump.data(), jump.size()), "Cannot patch test getter");
        for (unsigned i = 0; i <= 4; ++i)
            require(getter(object.data(), i) == 500, "Coins/materials not locked to 500 percent");
        require(getter(object.data(), 5) == 175 && getter(object.data(), UINT32_MAX) == 175,
                "Invalid kind fallback changed");
        values[0] = 150;
        values[1] = 999;
        memcpy(object.data() + t.displacement, values, sizeof(values));
        require(getter(object.data(), 0) == 500 && getter(object.data(), 1) == 500,
                "Game rate changes broke lock");
        require(hl::writeCode(executable, t.rate, 16) && getter(object.data(), 1) == 999 &&
                    getter(object.data(), 0) == 150,
                "Restore failed");
        puts(
            "PASS native getter execution: coins and four materials locked, invalid kinds, lock and restore");

        size_t giftSize = hl::parse(hl::kGift).size() - 17;
        std::vector<uint8_t> fragment(t.gift - 2, t.gift - 2 + giftSize);
        fragment.push_back(0xc3);
        require(hl::writeCode(executable, fragment.data(), fragment.size()),
                "Cannot install gift test fragment");
        std::array<uint8_t, 32> record{};
        std::array<uint8_t, 16> context{};
        int character = 2;
        memcpy(record.data(), &character, 4);
        int reactions[] = {4, 2, 1, 0, 3};
        const int *ptr = reactions;
        memcpy(context.data() + 8, &ptr, 8);
        auto preference = [&]() {
            int x;
            memcpy(&x, record.data() + 16, 4);
            return x;
        };
        InvokeGift(executable, record.data(), context.data(), 0);
        require(preference() == 5, "Original unknown gift icon unexpected");
        InvokeGift(executable, record.data(), context.data(), 1);
        require(preference() == 2, "Original known gift icon unexpected");
        uint8_t forced = 0xeb;
        require(hl::writeCode(executable + 2, &forced, 1), "Gift patch failed");
        for (int reaction = 0; reaction <= 4; ++reaction)
        {
            reactions[1] = reaction;
            InvokeGift(executable, record.data(), context.data(), 0);
            require(preference() == reaction, "Patched gift icon not actual preference");
        }
        puts(
            "PASS native gift branch execution: unknown before patch; all five true preferences after patch");

        uint8_t data[] = {0x11, 0x22, 0x33, 0x11, 0x44, 0x33};
        require(hl::scan({{data, 6}}, "11 ?? 33").size() == 2, "Ambiguous scan not detected");
        require(hl::scan({{data, 2}}, "11 ?? 33").empty(), "Short buffer scan failure");
        require(hl::scan({{data, 6}}, "44 33").size() == 1, "End-of-buffer scan failure");
        require(hl::scan({{data, 6}}, "FF 00").empty(), "Missing scan failure");
        puts("PASS scanner boundaries, wildcard, missing and multiple matches");
        VirtualFree(executable, 0, MEM_RELEASE);
        UnmapViewOfFile(image);

        if (argc >= 3)
        {
            auto proxy = LoadLibraryW(argv[2]);
            require(proxy != nullptr, "Cannot load proxy DLL");
            for (size_t i = 0; i < sizeof(exportNames) / sizeof(exportNames[0]); ++i)
            {
                require(GetProcAddress(proxy, MAKEINTRESOURCEA(exportOrdinals[i])) != nullptr,
                        "Missing proxy ordinal");
                if (exportNames[i])
                    require(GetProcAddress(proxy, exportNames[i]) != nullptr, "Missing proxy name");
            }
            auto begin = reinterpret_cast<MMRESULT(WINAPI *)(UINT)>(GetProcAddress(proxy, "timeBeginPeriod"));
            auto end = reinterpret_cast<MMRESULT(WINAPI *)(UINT)>(GetProcAddress(proxy, "timeEndPeriod"));
            auto ticks = reinterpret_cast<DWORD(WINAPI *)()>(GetProcAddress(proxy, "timeGetTime"));
            auto errorText = reinterpret_cast<MMRESULT(WINAPI *)(MMRESULT, LPWSTR, UINT)>(
                GetProcAddress(proxy, "waveOutGetErrorTextW"));
            require(begin(1) == TIMERR_NOERROR, "Forwarded timeBeginPeriod failed");
            DWORD before = ticks();
            Sleep(20);
            DWORD after = ticks();
            require(end(1) == TIMERR_NOERROR, "Forwarded timeEndPeriod failed");
            require(after - before >= 1 && after - before < 5000, "Forwarded timeGetTime failed");
            wchar_t text[256]{};
            require(errorText(MMSYSERR_NOERROR, text, 256) == MMSYSERR_NOERROR && text[0],
                    "Forwarded argument registers failed");
            using WaveOpen =
                MMRESULT(WINAPI *)(LPHWAVEOUT, UINT, LPCWAVEFORMATEX, DWORD_PTR, DWORD_PTR, DWORD);
            auto waveOpen = reinterpret_cast<WaveOpen>(GetProcAddress(proxy, "waveOutOpen"));
            wchar_t system[MAX_PATH]{};
            GetSystemDirectoryW(system, MAX_PATH);
            auto real = LoadLibraryW((std::wstring(system) + L"\\winmm.dll").c_str());
            require(real != nullptr, "Cannot load system WinMM for comparison");
            auto realWaveOpen = reinterpret_cast<WaveOpen>(GetProcAddress(real, "waveOutOpen"));
            WAVEFORMATEX format = {WAVE_FORMAT_PCM, 2, 44100, 176400, 4, 16, 0};
            require(waveOpen(nullptr, WAVE_MAPPER, &format, 0, 0, WAVE_FORMAT_QUERY) ==
                        realWaveOpen(nullptr, WAVE_MAPPER, &format, 0, 0, WAVE_FORMAT_QUERY),
                    "Six-argument stack forwarding failed");
            FreeLibrary(real);
            puts("PASS WinMM proxy: 181 ordinals, 180 names, timers, Unicode and six-argument format query");
        }
        puts("ALL CHECKS PASSED (offline/native harness; in-game scene validation is separate)");
        return 0;
    }
    catch (const std::exception &e)
    {
        fprintf(stderr, "FAIL: %s\n", e.what());
        return 1;
    }
}
