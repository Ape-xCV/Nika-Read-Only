#pragma once
constexpr int WEAPON_R301 = 0;
constexpr int WEAPON_SENTINEL = 1;
constexpr int WEAPON_BOCEK = 2;
constexpr int WEAPON_RAMPAGE = 6;
constexpr int WEAPON_RAMPART_SHEILA_STATIONARY = 14;
constexpr int WEAPON_ALTERNATOR = 84;
constexpr int WEAPON_RE45 = 85;
constexpr int WEAPON_CHARGE_RIFLE = 87;
constexpr int WEAPON_DEVOTION = 89;
constexpr int WEAPON_LONGBOW = 90;
constexpr int WEAPON_HAVOC = 91;
constexpr int WEAPON_EVA8 = 92;
constexpr int WEAPON_FLATLINE = 94;
constexpr int WEAPON_G7 = 95;
constexpr int WEAPON_HEMLOCK = 96;
constexpr int WEAPON_KRABER = 98;
constexpr int WEAPON_LSTAR = 99;
constexpr int WEAPON_MASTIFF = 101;
constexpr int WEAPON_MOZAMBIQUE = 102;
constexpr int WEAPON_PROWLER = 107;
constexpr int WEAPON_PEACEKEEPER = 109;
constexpr int WEAPON_R99 = 111;
constexpr int WEAPON_P2020 = 112;
constexpr int WEAPON_SPITFIRE = 113;
constexpr int WEAPON_TRIPLE_TAKE = 114;
constexpr int WEAPON_WINGMAN = 115;
constexpr int WEAPON_VOLT = 117;
constexpr int WEAPON_3030 = 118;
constexpr int WEAPON_CAR = 119;
constexpr int WEAPON_NEMESIS = 120;
constexpr int WEAPON_MELEE = 121;
constexpr int WEAPON_THROWING_KNIFE = 178;

namespace data {
    int selectedRadio = 0;
    const std::string items[][2] = {
        { "DRONE / DUMMIE", "-1" },
        { "R-301",          "80" },
        { "SENTINEL",      "127" },
        { "BOCEK",         "132" },
        { "RAMPAGE",       "150" },
        { "ALTERNATOR",     "44" },
        { "RE-45",         "122" },
        { "CHARGE_RIFLE",   "70" },
        { "DEVOTION",       "19" },
        { "LONGBOW",        "65" },
        { "HAVOC",          "13" },
        { "EVA-8",          "85" },
        { "FLATLINE",       "29" },
        { "G7 SCOUT",       "39" },
        { "HEMLOK",         "34" },
        { "KRABER",          "1" },
        { "L-STAR",          "7" },
        { "MASTIFF",         "2" },
        { "MOZAMBIQUE",     "95" },
        { "PROWLER",        "55" },
        { "PEACEKEEPER",    "90" },
        { "R-99",           "49" },
        { "P2020",         "113" },
        { "SPITFIRE",       "75" },
        { "TRIPLE_TAKE",    "24" },
        { "WINGMAN",       "108" },
        { "VOLT",           "60" },
        { "30-30",         "133" },
        { "C.A.R.",        "155" },
        { "NEMESIS",       "139" },
        { "LIGHT_AMMO",    "144" },
        { "ENERGY_AMMO",   "145" },
        { "SHOTGUN_AMMO",  "146" },
        { "HEAVY_AMMO",    "147" },
        { "SNIPER_AMMO",   "148" },
//        { "1X_HCOG",       "231" },
        { "2X_HCOG",       "232" },
//        { "1X_HOLO",       "233" },
        { "1X-2X_HOLO",    "234" },
        { "3X_HCOG",       "236" },
        { "2X-4X_AOG",     "237" },
        { "6X_SNIPER",     "238" },
        { "4X-8X_SNIPER",  "239" },
        { "4X-10X_SNIPER", "240" }
    };
};
