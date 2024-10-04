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
        { "DRONE / DUMMIE",  "-1" },
        { "G7 SCOUT",        "39" },
        { "ALTERNATOR",      "44" },
        { "R-99",            "49" },
        { "SPITFIRE",        "75" },
        { "R-301",           "80" },
        { "P2020",          "113" },
        { "RE-45",          "122" },
        { "L-STAR",           "7" },
        { "HAVOC",           "13" },
        { "DEVOTION",        "19" },
        { "TRIPLE_TAKE",     "24" },
        { "VOLT",            "60" },
        { "NEMESIS",        "139" },
        { "MASTIFF",          "2" },
        { "EVA-8",           "85" },
        { "PEACEKEEPER",     "90" },
        { "MOZAMBIQUE",      "95" },
        { "FLATLINE",        "29" },
        { "HEMLOK",          "34" },
        { "PROWLER",         "55" },
        { "30-30",          "133" },
        { "RAMPAGE",        "150" },
        { "C.A.R.",         "155" },
        { "KRABER",           "1" },
        { "LONGBOW",         "65" },
        { "CHARGE_RIFLE",    "70" },
        { "WINGMAN",        "108" },
        { "SENTINEL",       "127" },
        { "BOCEK",          "132" },
        { "LIGHT_AMMO",     "144" },
        { "ENERGY_AMMO",    "145" },
        { "SHOTGUN_AMMO",   "146" },
        { "HEAVY_AMMO",     "147" },
        { "SNIPER_AMMO",    "148" },
//        { "1X_HCOG",        "231" },
        { "2X_HCOG",        "232" },
//        { "1X_HOLO",        "233" },
        { "1X-2X_HOLO",     "234" },
        { "3X_HCOG",        "236" },
        { "2X-4X_AOG",      "237" },
        { "6X_SNIPER",      "238" },
        { "4X-8X_SNIPER",   "239" },
        { "4X-10X_SNIPER",  "240" },
        { "HEAT_SHIELD",    "296" },
        { "MOBILE_RESPAWN", "297" },
        { "EVAC_TOWER",     "300" },
        { "SHORT_SCOPE",     "-2" },
        { "MEDIUM_SCOPE",    "-2" },
        { "LONG_SCOPE",      "-2" }
    };
    const std::string itemsShortScope[][2] = {
        { "2X_HCOG",        "232" },
        { "1X-2X_HOLO",     "234" }
    };
    const std::string itemsMediumScope[][2] = {
        { "3X_HCOG",        "236" },
        { "2X-4X_AOG",      "237" }
    };
    const std::string itemsLongScope[][2] = {
        { "6X_SNIPER",      "238" },
        { "4X-8X_SNIPER",   "239" },
        { "4X-10X_SNIPER",  "240" }
    };
};
