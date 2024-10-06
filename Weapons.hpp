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
        { "DRONE_DUMMIE",    "-1" },
        { "G7_SCOUT",        "39" },
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
        { "2X_HCOG",        "232" },
        { "1X-2X_HOLO",     "234" },
        { "3X_HCOG",        "236" },
        { "2X-4X_AOG",      "237" },
        { "6X_SNIPER",      "238" },
        { "4X-8X_SNIPER",   "239" },
        { "4X-10X_SNIPER",  "240" },
        { "HEAT_SHIELD",    "296" },
        { "MOBILE_RESPAWN", "297" },
        { "EVAC_TOWER",     "300" },
        { "ULTIMATE_ACCEL", "193" },
        { "BARREL_STBLZR",  "243" },
        { "LASER_SIGHT",    "247" },
        { "STNDRD_STOCK",   "270" },
        { "SNIPER_STOCK",   "273" },
        { "P_LIGHT_MAG",    "250" },
        { "P_ENERGY_MAG",   "258" },
        { "P_SHOTGUN_BOLT", "266" },
        { "P_HEAVY_MAG",    "254" },
        { "P_SNIPER_MAG",   "262" },
        { "G_LIGHT_MAG",    "251" },
        { "G_ENERGY_MAG",   "259" },
        { "G_SHOTGUN_BOLT", "267" },
        { "G_HEAVY_MAG",    "255" },
        { "G_SNIPER_MAG",   "263" },
        { "WEAPON_SCOPE",    "-1" },
        { "EPIC_GEAR",       "-1" },
        { "LEGENDARY_GEAR",  "-1" },
        { "SHIELD_BATTERY", "197" },
        { "BLUE_BACKPACK",  "224" },
        { "PINK_BACKPACK",  "225" },
        { "GOLD_HELMET",    "202" },
        { "GOLD_KNOCKDOWN", "222" },
        { "GOLD_BACKPACK",  "226" },
        { "PLAYER_ONLY",     "-1" }
    };
    const std::string itemsScope[][2] = {
        { "2X_HCOG",        "232" },
        { "1X-2X_HOLO",     "234" },
        { "3X_HCOG",        "236" },
        { "2X-4X_AOG",      "237" },
        { "6X_SNIPER",      "238" },
        { "4X-8X_SNIPER",   "239" },
        { "4X-10X_SNIPER",  "240" }
    };
    const std::string itemsEpicGear[][2] = {
        { "ULTIMATE_ACCEL", "193" },
        { "BARREL_STBLZR",  "243" },
        { "LASER_SIGHT",    "247" },
        { "STNDRD_STOCK",   "270" },
        { "SNIPER_STOCK",   "273" },
        { "P_LIGHT_MAG",    "250" },
        { "P_ENERGY_MAG",   "258" },
        { "P_SHOTGUN_BOLT", "266" },
        { "P_HEAVY_MAG",    "254" },
        { "P_SNIPER_MAG",   "262" },
        { "SHIELD_BATTERY", "197" },
        { "BLUE_BACKPACK",  "224" },
        { "PINK_BACKPACK",  "225" }
    };
    const std::string itemsLegendaryGear[][2] = {
        { "G_LIGHT_MAG",    "251" },
        { "G_ENERGY_MAG",   "259" },
        { "G_SHOTGUN_BOLT", "267" },
        { "G_HEAVY_MAG",    "255" },
        { "G_SNIPER_MAG",   "263" },
        { "GOLD_HELMET",    "202" },
        { "GOLD_KNOCKDOWN", "222" },
        { "GOLD_BACKPACK",  "226" }
    };
};
