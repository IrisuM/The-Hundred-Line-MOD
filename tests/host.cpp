#include "patches.h"
#include "fixture.h"
#include <array>
#include <cstdio>
extern "C" void InvokeGift(void *, void *, void *, unsigned);
int wmain(int argc, wchar_t **argv)
{
    if (argc != 2)
        return 10;
    uint32_t expected = static_cast<uint32_t>(_wtoi(argv[1]));
    uint32_t offset{};
    memcpy(&offset, fixtureRate + 11, 4);
#ifdef DUPLICATE_GIFT
    printf("Duplicate fixture at %p\n", static_cast<const void *>(duplicateGift));
#endif
    auto proxy = LoadLibraryW(L"winmm.dll");
    if (!proxy)
        return 11;
    auto begin = reinterpret_cast<unsigned(WINAPI *)(unsigned)>(GetProcAddress(proxy, "timeBeginPeriod"));
    auto end = reinterpret_cast<unsigned(WINAPI *)(unsigned)>(GetProcAddress(proxy, "timeEndPeriod"));
    if (!begin || !end || begin(1))
        return 12;
    end(1);
    std::vector<uint8_t> object(offset + 20, 0);
    uint32_t values[] = {175, 120, 230, 340, 450};
    memcpy(object.data() + offset, values, sizeof(values));
    using Getter = uint32_t(__fastcall *)(const void *, uint32_t);
    auto getter = reinterpret_cast<Getter>(const_cast<unsigned char *>(fixtureRate));
    uint32_t expectedCoins = expected == 120 ? 175 : expected;
    if (getter(object.data(), 1) != expected || getter(object.data(), 0) != expectedCoins)
        return 13;
    std::array<uint8_t, 32> record{};
    std::array<uint8_t, 16> context{};
    int id = 2;
    memcpy(record.data(), &id, 4);
    int reactions[] = {4, 2, 1, 0, 3};
    const int *table = reactions;
    memcpy(context.data() + 8, &table, 8);
    InvokeGift(const_cast<unsigned char *>(fixtureGift) + 17, record.data(), context.data(), 0);
    int preference{};
    memcpy(&preference, record.data() + 16, 4);
    if (preference != (expected == 120 ? 5 : 2))
        return 14;
    printf("PASS actual DLL integration: material=%u coins=%u gift=%d\n", expected, expectedCoins,
           preference);
    return 0;
}
