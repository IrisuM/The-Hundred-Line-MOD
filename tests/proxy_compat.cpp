#include "patches.h"
#include <cstdio>

static unsigned lookupCount;
static FARPROC WINAPI lookupWithoutWowAppExit(HMODULE module, LPCSTR name)
{
    ++lookupCount;
    if (reinterpret_cast<ULONG_PTR>(name) > 0xffff && !strcmp(name, "WOWAppExit"))
        return nullptr;
    return GetProcAddress(module, name);
}

static unsigned failFastCount;
static void WINAPI captureFailFast(PEXCEPTION_RECORD, PCONTEXT, DWORD)
{
    ++failFastCount;
}

// Exercise the production initializer/resolver with a Wine-like missing export.
// Only the test executable replaces lookup and termination; the DLL is unchanged.
#define GetProcAddress lookupWithoutWowAppExit
#define RaiseFailFastException captureFailFast
#include "../src/mod.cpp"
#undef RaiseFailFastException
#undef GetProcAddress

static void require(bool condition, const char *message)
{
    if (!condition)
        throw std::runtime_error(message);
}

int wmain(int argc, wchar_t **argv)
{
    try
    {
        require(argc == 2, "Usage: proxy_compat.exe path/to/winmm.dll");
        selfModule = GetModuleHandleW(nullptr);
        unsigned ticksIndex = 0, missingIndex = 0;
        for (unsigned i = 0; i < sizeof(exportNames) / sizeof(exportNames[0]); ++i)
        {
            if (exportNames[i] && !strcmp(exportNames[i], "timeGetTime"))
                ticksIndex = i;
            if (exportNames[i] && !strcmp(exportNames[i], "WOWAppExit"))
                missingIndex = i;
        }
        using Ticks = DWORD(WINAPI *)();
        auto ticks = reinterpret_cast<Ticks>(ResolveWinmm(ticksIndex));
        require(ticks != nullptr && realExports[missingIndex] == nullptr,
                "Missing unused export prevented initialization");
        auto lookups = lookupCount;
        DWORD before = ticks();
        Sleep(20);
        DWORD elapsed = ticks() - before;
        require(elapsed > 0 && elapsed < 5000, "System timer forwarding failed");
        require(ResolveWinmm(ticksIndex) == reinterpret_cast<FARPROC>(ticks) && lookupCount == lookups,
                "Successful initialization was repeated");
        require(ResolveWinmm(missingIndex) == nullptr && failFastCount == 1,
                "Calling missing export did not request fail-fast");
        require(ResolveWinmm(ticksIndex) != nullptr && lookupCount == lookups,
                "Missing export corrupted initialized table");
        require(ResolveWinmm(UINT_MAX) == nullptr && failFastCount == 2,
                "Invalid index did not request fail-fast");

        auto proxy = LoadLibraryW(argv[1]);
        require(proxy != nullptr, "Cannot load built proxy DLL");
        auto proxyTicks = reinterpret_cast<Ticks>(GetProcAddress(proxy, "timeGetTime"));
        require(proxyTicks != nullptr, "Built DLL has no timer export");
        before = proxyTicks();
        Sleep(20);
        elapsed = proxyTicks() - before;
        require(elapsed > 0 && elapsed < 5000, "Built DLL timer forwarding failed");
        puts("PASS missing unused export, cached initialization, missing requested export, "
             "invalid index and built DLL forwarding");
        return 0;
    }
    catch (const std::exception &e)
    {
        fprintf(stderr, "FAIL: %s\n", e.what());
        return 1;
    }
}
