#pragma once

struct Player {
    LocalPlayer* lp;
    ConfigLoader* cl;
    int index;
    uint64_t base;
    std::string name;
    bool dead;
    bool knocked;
    int teamNumber;
    int currentHealth;
    int currentShields;
    Vector3D localOrigin_prev;
    Vector3D localOrigin;
    Vector3D AbsoluteVelocity;
    Vector3D localOrigin_predicted;
    bool local;
    bool friendly;
    bool enemy;
    int lastTimeAimedAt;
    int lastTimeAimedAtPrev;
    int plyrDataTable;
    int spctrIndex;
    bool aimedAt;
//_    int lastTimeVisible;
    float lastTimeVisible;
//_    int lastTimeVisiblePrev;
    bool visible;
    float distanceToLocalPlayer;
    float distance2DToLocalPlayer;
    bool IsLockedOn;
    Vector2D aimbotDesiredAngles;
    Vector2D aimbotDesiredAnglesIncrement;
    float aimbotScore;
    uintptr_t nameOffset;
    uint64_t spectators;
    uint64_t spctrBase;

    Player(int in_index, LocalPlayer* in_localPlayer, ConfigLoader* in_cl) {
        this->index = in_index;
        this->lp = in_localPlayer;
        this->cl = in_cl;
    }

    void reset() {
        base = 0;
    }
    std::string getPlayerName(){
        nameOffset = mem::Read<uintptr_t>(OFF_REGION + OFF_NAMELIST + ((plyrDataTable - 1) * 24 ), "Player nameOffset");
        std::string playerName = mem::ReadString(nameOffset, 64, "Player playerName");
        return playerName;
    }
    std::string getPlayerModelName(){
        uintptr_t modelOffset = mem::Read<uintptr_t>(base + OFF_MODELNAME, "Player OFF_MODELNAME");
        std::string modelName = mem::ReadString(modelOffset, 1024, "Player modelName");
        // Check for different player names
        if (modelName.find("dummie") != std::string::npos) modelName = "DUMMIE";
        else if (modelName.find("ash") != std::string::npos) modelName = "ASH";
        else if (modelName.find("ballistic") != std::string::npos) modelName = "BALLISTIC";
        else if (modelName.find("bangalore") != std::string::npos) modelName = "BANGALORE";
        else if (modelName.find("bloodhound") != std::string::npos) modelName = "BLOODHOUND";
        else if (modelName.find("catalyst") != std::string::npos) modelName = "CATALYST";
        else if (modelName.find("caustic") != std::string::npos) modelName = "CAUSTIC";
        else if (modelName.find("conduit") != std::string::npos) modelName = "CONDUIT";
        else if (modelName.find("crypto") != std::string::npos) modelName = "CRYPTO";
        else if (modelName.find("fuse") != std::string::npos) modelName = "FUSE";
        else if (modelName.find("gibraltar") != std::string::npos) modelName = "GIBRALTAR";
        else if (modelName.find("horizon") != std::string::npos) modelName = "HORIZON";
        else if (modelName.find("nova") != std::string::npos) modelName = "HORIZON";
        else if (modelName.find("holo") != std::string::npos) modelName = "MIRAGE";
        else if (modelName.find("mirage") != std::string::npos) modelName = "MIRAGE";
        else if (modelName.find("lifeline") != std::string::npos) modelName = "LIFELINE";
        else if (modelName.find("loba") != std::string::npos) modelName = "LOBA";
        else if (modelName.find("madmaggie") != std::string::npos) modelName = "MADMAGGIE";
        else if (modelName.find("newcastle") != std::string::npos) modelName = "NEWCASTLE";
        else if (modelName.find("octane") != std::string::npos) modelName = "OCTANE";
        else if (modelName.find("pathfinder") != std::string::npos) modelName = "PATHFINDER";
        else if (modelName.find("rampart") != std::string::npos) modelName = "RAMPART";
        else if (modelName.find("revenant") != std::string::npos) modelName = "REVENANT";
        else if (modelName.find("seer") != std::string::npos) modelName = "SEER";
        else if (modelName.find("stim") != std::string::npos) modelName = "OCTANE";
        else if (modelName.find("valkyrie") != std::string::npos) modelName = "VALKYRIE";
        else if (modelName.find("vantage") != std::string::npos) modelName = "VANTAGE";
        else if (modelName.find("wattson") != std::string::npos) modelName = "WATTSON";
        else if (modelName.find("wraith") != std::string::npos) modelName = "WRAITH";

        return modelName;
    }
    void readFromMemory() {
        base = mem::Read<uint64_t>(OFF_REGION + OFF_ENTITY_LIST + ((index + 1) << 5), "Player base");
        if (base == 0) return;
        plyrDataTable = mem::Read<int>(base + OFF_NAMEINDEX, "Player Data Table");
        spectators = mem::Read<uint64_t>(OFF_REGION + OFF_SPECTATOR_LIST, "spectators");
        spctrIndex = mem::Read<int>(spectators + plyrDataTable * 8 + 0x964, "Spectator Index");
        spctrBase =  mem::Read<uint64_t>(OFF_REGION + OFF_ENTITY_LIST + ((spctrIndex & 0xFFFF) << 5), "Spectator Base");
        name = mem::ReadString(base + OFF_NAME, 1024, "Player name");
        teamNumber = mem::Read<int>(base + OFF_TEAM_NUMBER, "Player teamNumber");
        currentHealth = mem::Read<int>(base + OFF_CURRENT_HEALTH, "Player currentHealth");
        currentShields = mem::Read<int>(base + OFF_CURRENT_SHIELDS, "Player currentShields");
        if (!isPlayer() && !isDummie()) { reset(); return; }
        dead = (isDummie()) ? false : mem::Read<short>(base + OFF_LIFE_STATE, "Player dead") > 0;
        knocked = (isDummie()) ? false : mem::Read<short>(base + OFF_BLEEDOUT_STATE, "Player knocked") > 0;
        localOrigin = mem::Read<Vector3D>(base + OFF_LOCAL_ORIGIN, "Player localOrigin");
        AbsoluteVelocity = mem::Read<Vector3D>(base + OFF_ABSVELOCITY, "Player AbsoluteVelocity");
        Vector3D localOrigin_diff = localOrigin.Subtract(localOrigin_prev).Normalize().Multiply(20);
        localOrigin_predicted = localOrigin.Add(localOrigin_diff);
        localOrigin_prev = Vector3D(localOrigin.x, localOrigin.y, localOrigin.z);

        lastTimeAimedAt = mem::Read<int>(base + OFF_LAST_AIMEDAT_TIME, "Player lastTimeAimedAt");
        aimedAt = lastTimeAimedAtPrev < lastTimeAimedAt;
        lastTimeAimedAtPrev = lastTimeAimedAt;

//_        lastTimeVisible = mem::Read<int>(base + OFF_LAST_VISIBLE_TIME, "Player lastTimeVisible");
        lastTimeVisible = mem::Read<float>(base + OFF_LAST_VISIBLE_TIME, "Player lastTimeVisible"); //_add
//_        visible = isDummie() || aimedAt || lastTimeVisiblePrev < lastTimeVisible;
        visible = aimedAt || (lastTimeVisible + 0.2) > lp->worldtime; //_add
//_        lastTimeVisiblePrev = lastTimeVisible;

        if (lp->isValid()) {
            local = lp->base == base;
            friendly = SameTeam();
            enemy = !friendly;
            distanceToLocalPlayer = lp->localOrigin.Distance(localOrigin);
            distance2DToLocalPlayer = lp->localOrigin.To2D().Distance(localOrigin.To2D());
            if (visible) {
                aimbotDesiredAngles = calcDesiredAngles();
                aimbotDesiredAnglesIncrement = calcDesiredAnglesIncrement();
                aimbotScore = calcAimbotScore();
            }
        }
    }
    void setGlowThroughWall(int glowThroughWall)
    {
        long ptrLong = base + OFF_GLOW_THROUGH_WALL;
        mem::Write<int>(ptrLong, glowThroughWall);
    }
    void setGlowEnable(int glowEnable)
    {
        long ptrLong = base + OFF_GLOW_HIGHLIGHT_ID;
        mem::Write<int>(ptrLong, glowEnable);
    }
    void setCustomGlow(int health, bool isVisible, bool isSameTeam)
    {
        static const int contextId = 0; // Same as glow enable
        long basePointer = base;
        int settingIndex = 50;
        std::array<unsigned char, 4> highlightFunctionBits = {
            2,   // InsideFunction
            125, // OutlineFunction: HIGHLIGHT_OUTLINE_OBJECTIVE
            64,  // OutlineRadius: size * 255 / 8
            64   // (EntityVisible << 6) | State & 0x3F | (AfterPostProcess << 7)
        };
        std::array<float, 3> glowColorRGB = { 0, 0, 0 };
        if (!isVisible) {
            settingIndex = 65;
            glowColorRGB = { 0.5, 0.5, 0.5 }; // grey
        } else if (health >= 205) {
            settingIndex = 66;
            glowColorRGB = { 1, 0, 0 }; // red shield
        } else if (health >= 190) {
            settingIndex = 67;
            glowColorRGB = { 0.5, 0, 0.5 }; // purple shield
        } else if (health >= 170) {
            settingIndex = 68;
            glowColorRGB = { 0, 0.5, 1 }; // blue shield
        } else if (health >= 95) {
            settingIndex = 69;
            glowColorRGB = { 0, 1, 0.5 }; // gray shield // cyan color
        } else {
            settingIndex = 70;
            glowColorRGB = { 0, 1, 0 }; // low health enemies // green color
        }

        if (!isSameTeam) {
            mem::Write<unsigned char>(basePointer + OFF_GLOW_HIGHLIGHT_ID + contextId, settingIndex);
            mem::Write<typeof(highlightFunctionBits)>(
                lp->highlightSettingsPtr + HIGHLIGHT_TYPE_SIZE * settingIndex + 0, highlightFunctionBits);
            mem::Write<typeof(glowColorRGB)>(
                lp->highlightSettingsPtr + HIGHLIGHT_TYPE_SIZE * settingIndex + 4, glowColorRGB);
            mem::Write<int>(basePointer + OFF_GLOW_FIX, 0);
        }
    }
    bool SameTeam()
    {
        if (Map::map_mixtape && lp->squadNumber == -1)
        {
            return (teamNumber & 1) == (lp->teamNumber & 1);
        }
        else
        {
            return teamNumber == lp->teamNumber;
        }
    }
//_begin
    bool isSpectating() {
//        if (!dead)
//            return false;
        if(spctrBase == lp->base)
            return true;
        return false;
    }
    float getViewYaw() {
        if (!isDummie() || isPlayer()) {
            return mem::Read<float>(base + OFF_YAW, "");
        }
        return 0.0f;
    }
//_end
    bool isValid() {
        return base != 0 && (isPlayer() || isDummie());
    }
    bool isCombatReady() {
        if (!isValid())return false;
        if (isDummie()) return true;
        if (dead) return false;
        if (knocked) return false;
        return true;
    }
    bool isPlayer() {
        return name == "player";
    }
    bool isDummie() {
        return teamNumber == 97;
    }
    int getGlowThroughWall()
    {
        int ptrInt = mem::Read<int>(base + OFF_GLOW_THROUGH_WALL, "Player GlowThroughWall");
        if (!mem::IsValidPointer(ptrInt))
            return -1;
        return ptrInt;
    }
    int getGlowEnable()
    {
        int ptrInt = mem::Read<int>(base + OFF_GLOW_HIGHLIGHT_ID, "Player GlowEnable");
        if (!mem::IsValidPointer(ptrInt))
            return -1;
        return ptrInt;
    }
    int GetPlayerLevel()
    {
        int m_xp = mem::Read<int>(base + OFF_XPLEVEL, "Player XP_Level");
        if (m_xp < 0) return 0;
        if (m_xp < 100) return 1;

        int levels[] = { 2750, 6650, 11400, 17000, 23350, 30450, 38300, 46450, 55050,
        64100, 73600, 83550, 93950, 104800, 116100, 127850, 140050, 152400, 164900,
        177550, 190350, 203300, 216400, 229650, 243050, 256600, 270300, 284150, 298150,
        312300, 326600, 341050, 355650, 370400, 385300, 400350, 415550, 430900, 446400,
        462050, 477850, 493800, 509900, 526150, 542550, 559100, 575800, 592650, 609650, 626800,
        644100, 661550, 679150, 696900, 714800 };

        int level = 56;
        int arraySize = sizeof(levels) / sizeof(levels[0]);

        for (int i = 0; i < arraySize; i++)
        {
            if (m_xp < levels[i])
            {
                return i + 1;
            }
        }
        return level + ((m_xp - levels[arraySize - 1] + 1) / 18000);
    }
    int getBoneFromHitbox(HitboxType HitBox) const {
        long ModelPointer = mem::Read<long>(base + OFF_STUDIOHDR, "Player ModelPointer");
        if (!mem::IsValidPointer(ModelPointer))
            return -1;

        long StudioHDR = mem::Read<long>(ModelPointer + 0x8, "Player StudioHDR");
        if (!mem::IsValidPointer(StudioHDR + 0x34))
            return -1;

        auto HitboxCache = mem::Read<uint16_t>(StudioHDR + 0x34, "Player HitboxCache");
        auto HitboxArray = StudioHDR + ((uint16_t)(HitboxCache & 0xFFFE) << (4 * (HitboxCache & 1)));
        if (!mem::IsValidPointer(HitboxArray + 0x4))
            return -1;

        auto IndexCache = mem::Read<uint16_t>(HitboxArray + 0x4, "Player IndexCache");
        auto HitboxIndex = ((uint16_t)(IndexCache & 0xFFFE) << (4 * (IndexCache & 1)));
        auto BonePointer = HitboxIndex + HitboxArray + (static_cast<int>(HitBox) * 0x20);
        if (!mem::IsValidPointer(BonePointer))
            return -1;
        return mem::Read<uint16_t>(BonePointer, "Player BonePointer");
    }
    float calcPitchIncrement() {
        float wayA = aimbotDesiredAngles.x - lp->viewAngles.x;
        float wayB = 180 - abs(wayA);
        if (wayA > 0 && wayB > 0)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }
    float calcDesiredPitch() {
        if (local) return 0;
        const Vector3D shift = Vector3D(100000, 100000, 100000);
        const Vector3D originA = lp->localOrigin.Add(shift);
        const Vector3D originB = localOrigin_predicted.Add(shift).Subtract(Vector3D(0, 0, 10));
        const float deltaZ = originB.z - originA.z;
        const float pitchInRadians = std::atan2(-deltaZ, distance2DToLocalPlayer);
        const float degrees = pitchInRadians * (180.0f / M_PI);
        return degrees;
    }
    float calcDesiredYaw() {
        if (local) return 0;
        const Vector2D shift = Vector2D(100000, 100000);
        const Vector2D originA = lp->localOrigin.To2D().Add(shift);
        const Vector2D originB = localOrigin_predicted.To2D().Add(shift);
        const Vector2D diff = originB.Subtract(originA);
        const double yawInRadians = std::atan2(diff.y, diff.x);
        const float degrees = yawInRadians * (180.0f / M_PI);
        return degrees;
    }
    float calcYawIncrement() {
        float wayA = aimbotDesiredAngles.y - lp->viewAngles.y;
        float wayB = 360 - abs(wayA);
        if (wayA > 0 && wayB > 0)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }
    float calcAimbotScore() {
        return (1000 - (fabs(aimbotDesiredAnglesIncrement.x) + fabs(aimbotDesiredAnglesIncrement.y)));
    }
    Vector2D calcDesiredAngles() {
        return Vector2D(calcDesiredPitch(), calcDesiredYaw());
    }
    Vector2D calcDesiredAnglesIncrement() {
        return Vector2D(calcPitchIncrement(), calcYawIncrement());
    }
    Vector3D GetBonePosition(HitboxType HitBox) const {
        Vector3D Offset = Vector3D(0.0f, 0.0f, 0.0f);

        int Bone = getBoneFromHitbox(HitBox);
        if (Bone < 0 || Bone > 255)
            return localOrigin.Add(Offset);

        long BonePtr = mem::Read<long>(base + OFF_BONES, "Player Bones Offset");
        BonePtr += (Bone * sizeof(Matrix3x4));
        if (!mem::IsValidPointer(BonePtr))
            return localOrigin.Add(Offset);

        Matrix3x4 BoneMatrix = mem::Read<Matrix3x4>(BonePtr, "Player BoneMatrix");
        Vector3D BonePosition = BoneMatrix.GetPosition();

        if (!BonePosition.IsValid())
            return localOrigin.Add(Vector3D(0, 0, 0));

        BonePosition += localOrigin;
        return BonePosition;
    }
};
