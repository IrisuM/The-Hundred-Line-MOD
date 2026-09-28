#pragma once

namespace hl
{
// Whole leaf function; its object displacement is decoded after matching.
inline constexpr char kRate[] = "33 C0 83 FA 04 0F 47 D0 8B 84 91 ?? ?? ?? ?? C3";
// Present-target list only: keep the history query, bypass its display restriction.
inline constexpr char kGift[] =
    "41 8B 16 4C 8B C5 83 EA 02 48 8B C8 E8 ?? ?? ?? ?? 84 C0 75 0A 41 C7 46 10 05 00 00 00 EB 0F 48 8B 45 08 49 63 0E 8B 4C 88 FC 41 89 4E 10";
} // namespace hl
