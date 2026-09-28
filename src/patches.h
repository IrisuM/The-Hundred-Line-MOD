#pragma once
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <cstdint>
#include <cstring>
#include <vector>
#include <string>
#include <stdexcept>
#include "signatures.h"

namespace hl
{
struct Region
{
    uint8_t *data;
    size_t size;
};
inline std::vector<int> parse(const char *s)
{
    std::vector<int> out;
    while (*s)
    {
        if (*s == ' ')
        {
            ++s;
            continue;
        }
        if (*s == '?')
        {
            ++s;
            if (*s == '?')
                ++s;
            out.push_back(-1);
            continue;
        }
        char *end = nullptr;
        auto value = strtoul(s, &end, 16);
        if (end == s || end - s != 2 || value > 255)
            throw std::runtime_error("Invalid signature");
        out.push_back(static_cast<int>(value));
        s = end;
    }
    if (out.empty())
        throw std::runtime_error("Empty signature");
    return out;
}
inline std::vector<uint8_t *> scan(const std::vector<Region> &regions, const char *signature)
{
    auto p = parse(signature);
    std::vector<uint8_t *> matches;
    for (auto r : regions)
    {
        if (r.size < p.size())
            continue;
        for (size_t i = 0; i <= r.size - p.size(); ++i)
        {
            size_t j = 0;
            for (; j < p.size(); ++j)
                if (p[j] >= 0 && r.data[i + j] != p[j])
                    break;
            if (j == p.size())
                matches.push_back(r.data + i);
        }
    }
    return matches;
}
inline std::vector<Region> codeSections(void *image)
{
    auto base = static_cast<uint8_t *>(image);
    auto dos = reinterpret_cast<IMAGE_DOS_HEADER *>(base);
    if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0 || dos->e_lfanew > 0x100000)
        throw std::runtime_error("Invalid DOS header");
    auto nt = reinterpret_cast<IMAGE_NT_HEADERS64 *>(base + dos->e_lfanew);
    if (nt->Signature != IMAGE_NT_SIGNATURE || nt->FileHeader.Machine != IMAGE_FILE_MACHINE_AMD64 ||
        nt->OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR64_MAGIC)
        throw std::runtime_error("Expected x64 PE image");
    std::vector<Region> out;
    auto section = IMAGE_FIRST_SECTION(nt);
    for (unsigned i = 0; i < nt->FileHeader.NumberOfSections; ++i)
    {
        const auto &s = section[i];
        if (!(s.Characteristics & IMAGE_SCN_MEM_EXECUTE))
            continue;
        if (s.VirtualAddress > nt->OptionalHeader.SizeOfImage ||
            s.Misc.VirtualSize > nt->OptionalHeader.SizeOfImage - s.VirtualAddress)
            throw std::runtime_error("Section outside image");
        out.push_back({base + s.VirtualAddress, s.Misc.VirtualSize});
    }
    return out;
}
struct Targets
{
    uint8_t *rate{};
    uint8_t *gift{};
    uint32_t displacement{};
};
inline Targets locate(void *image, bool rate, bool gift)
{
    auto regions = codeSections(image);
    Targets t;
    if (rate)
    {
        auto m = scan(regions, kRate);
        if (m.size() != 1)
            throw std::runtime_error("Rate signature matches: " + std::to_string(m.size()));
        t.rate = m[0];
        memcpy(&t.displacement, t.rate + 11, 4);
        if ((t.displacement & 3) || t.displacement < 0x100 || t.displacement > 0x100000)
            throw std::runtime_error("Invalid rate object displacement");
    }
    if (gift)
    {
        auto m = scan(regions, kGift);
        if (m.size() != 1)
            throw std::runtime_error("Gift signature matches: " + std::to_string(m.size()));
        t.gift = m[0] + 19;
    }
    return t;
}
inline uint32_t rateValue(const void *object, uint32_t kind, uint32_t offset, uint32_t percent)
{
    if (kind <= 4)
        return percent;
    // Valid rewards include coins (kind 0) and all four material kinds.
    // Preserve the original stored-value fallback for invalid kinds only.
    uint32_t value;
    memcpy(&value, static_cast<const uint8_t *>(object) + offset, 4);
    return value;
}
inline std::vector<uint8_t> absoluteJump(const void *target)
{
    std::vector<uint8_t> bytes(16, 0x90);
    bytes[0] = 0xff;
    bytes[1] = 0x25;
    memset(bytes.data() + 2, 0, 4);
    memcpy(bytes.data() + 6, &target, 8);
    return bytes;
}
inline bool writeCode(void *address, const void *bytes, size_t size)
{
    DWORD old{};
    if (!VirtualProtect(address, size, PAGE_EXECUTE_READWRITE, &old))
        return false;
    memcpy(address, bytes, size);
    const bool flushed = FlushInstructionCache(GetCurrentProcess(), address, size) != FALSE;
    DWORD ignored{};
    const bool restored = VirtualProtect(address, size, old, &ignored) != FALSE;
    return flushed && restored;
}
} // namespace hl
