#pragma once

struct Player {
    int index;
    uintptr_t nameOffset;
    uint64_t base;
    std::string name;
    int teamNumber;
    bool isPlayer;
    bool isDrone;
    bool isDummie;
    bool isItem;
    //char signifierName[64] = {0};
    int itemId;
    Vector3D localOrigin;
    Vector3D localOriginDiff;
    Vector3D localOriginPrev;
    Vector3D localOriginPrev2;
    Vector3D localOriginPrev3;
    Vector3D localOriginPrev4;
    float timeLocalOrigin;
    float timeLocalOriginDiff;
    float timeLocalOriginPrev;
    float timeLocalOriginPrev2;
    float timeLocalOriginPrev3;
    float timeLocalOriginPrev4;
    Vector3D absoluteVelocity;
    Vector2D viewAngles;
    float viewYaw;
    int plyrDataTable;
    uint64_t spectators;
    int spctrIndex;
    uint64_t spctrBase;
    bool isDead;
    bool isKnocked;
    int currentHealth;
    int currentShield;
    //int lastTimeAimedAt;
    //bool isAimedAt;
    //int lastTimeAimedAtPrev;
    float lastTimeVisible;
    bool isVisible;
    bool isLocal;
    bool isFriendly;
    bool isEnemy;
    float distanceToLocalPlayer;
    float distance2DToLocalPlayer;

    Player(int in_index) {
        this->index = in_index;
    }

    void reset() {
        base = 0;
    }

    bool isSameTeam(Level* map, LocalPlayer* lp) {
        if (map->isMixtape && lp->squadNumber == -1)
            return (teamNumber & 1) == (lp->teamNumber & 1);
        else
            return teamNumber == lp->teamNumber;
    }

    void readFromMemory(ConfigLoader* cl, Level* map, LocalPlayer* lp, int counter) {
        base = mem::Read<uint64_t>(OFF_REGION + OFF_ENTITY_LIST + ((index + 1) << 5), "Player base");
        if (base == 0) return;
        name = mem::ReadString(base + OFF_NAME, 64, "Player name");
        isPlayer = name == "player";
        isDrone = name == "drone_no_minimap_object";
        if (map->isTrainingArea) {
            teamNumber = mem::Read<int>(base + OFF_TEAM_NUMBER, "Player teamNumber");
            isDummie = teamNumber == 97;
        } else { isDummie = false; }
        isItem = false;
        if (!isPlayer && !isDrone && !isDummie) {
            //uint64_t signifierNamePtr = mem::Read<uint64_t>(base + 0x0478, "Player signifierNamePtr"); //[RecvTable.DT_PropSurvival]->m_iSignifierName=0x0478
            //mem::Read(signifierNamePtr, &signifierName, sizeof(signifierName));
            //size_t found = static_cast<std::string>(signifierName).find("prop_survival");
            //if (found == std::string::npos) { reset(); return; }
            itemId = mem::ReadInt(base + OFF_ITEM_HANDLE, "Player itemId");
            isItem = itemId != -1 && itemId == stoi(data::items[data::selectedRadio][1]);
            if (data::items[data::selectedRadio][0] == "SHORT_SCOPE")
                if (itemId == stoi(data::itemsShortScope[0][1]) || itemId == stoi(data::itemsShortScope[1][1])) isItem = true;
            if (data::items[data::selectedRadio][0] == "MEDIUM_SCOPE")
                if (itemId == stoi(data::itemsMediumScope[0][1]) || itemId == stoi(data::itemsMediumScope[1][1])) isItem = true;
            if (data::items[data::selectedRadio][0] == "LONG_SCOPE")
                if (itemId == stoi(data::itemsLongScope[0][1]) || itemId == stoi(data::itemsLongScope[1][1]) || itemId == stoi(data::itemsLongScope[2][1])) isItem = true;
            if (isItem) {
                localOrigin = mem::Read<Vector3D>(base + OFF_LOCAL_ORIGIN, "Player localOrigin");
                isEnemy = true;
                if (lp->isValid()) distance2DToLocalPlayer = lp->localOrigin.Distance2D(localOrigin);
                return;
            }
            reset(); return;
        }
        if (!map->isTrainingArea)
            teamNumber = mem::Read<int>(base + OFF_TEAM_NUMBER, "Player teamNumber");
        localOrigin = mem::Read<Vector3D>(base + OFF_LOCAL_ORIGIN, "Player localOrigin");
        timeLocalOrigin = lp->worldTime;
        //if (!isPlayer) {
            localOriginDiff = localOrigin.Subtract(localOriginPrev).Add(localOriginPrev.Subtract(localOriginPrev2)).Add(localOriginPrev2.Subtract(localOriginPrev3)).Add(localOriginPrev3.Subtract(localOriginPrev4));
            timeLocalOriginDiff = (timeLocalOrigin - timeLocalOriginPrev) + (timeLocalOriginPrev - timeLocalOriginPrev2) + (timeLocalOriginPrev2 - timeLocalOriginPrev3) + (timeLocalOriginPrev3 - timeLocalOriginPrev4);
            absoluteVelocity = localOriginDiff.Divide(timeLocalOriginDiff); // v = d/t
            localOriginPrev4 = localOriginPrev3;
            localOriginPrev3 = localOriginPrev2;
            localOriginPrev2 = localOriginPrev;
            localOriginPrev = localOrigin;
            timeLocalOriginPrev4 = timeLocalOriginPrev3;
            timeLocalOriginPrev3 = timeLocalOriginPrev2;
            timeLocalOriginPrev2 = timeLocalOriginPrev;
            timeLocalOriginPrev = timeLocalOrigin;
        //} else {
        //    absoluteVelocity = mem::Read<Vector3D>(base + OFF_ABS_VELOCITY, "Player absoluteVelocity");
        if (isPlayer) {
            viewAngles = mem::Read<Vector2D>(base + OFF_VIEW_ANGLES, "Player viewAngles");
            viewYaw = mem::Read<float>(base + OFF_YAW, "Player viewYaw");
            plyrDataTable = mem::Read<int>(base + OFF_NAME_INDEX, "Player plyrDataTable");
            if (cl->FEATURE_SPECTATORS_ON && counter % 99 == 0) {
                spectators = mem::Read<uint64_t>(OFF_REGION + OFF_OBSERVER_LIST, "Player spectators");
                spctrIndex = mem::Read<int>(spectators + plyrDataTable * 8 + OFF_OBSERVER_ARRAY, "Player spctrIndex");
                spctrBase = mem::Read<uint64_t>(OFF_REGION + OFF_ENTITY_LIST + ((spctrIndex & 0xFFFF) << 5), "Player spctrBase");
            }
        }
        isDead = (isDrone || isDummie) ? false : mem::Read<short>(base + OFF_LIFE_STATE, "Player isDead") > 0;
        isKnocked = (isDrone || isDummie) ? false : mem::Read<short>(base + OFF_BLEEDOUT_STATE, "Player isKnocked") > 0;
        currentHealth = mem::Read<int>(base + OFF_HEALTH, "Player currentHealth");
        currentShield = mem::Read<int>(base + OFF_SHIELD, "Player currentShield");

        //lastTimeAimedAt = mem::Read<int>(base + OFF_LAST_AIMEDAT_TIME, "Player lastTimeAimedAt");
        //isAimedAt = lastTimeAimedAtPrev < lastTimeAimedAt;
        //lastTimeAimedAtPrev = lastTimeAimedAt;

        lastTimeVisible = mem::Read<float>(base + OFF_LAST_VISIBLE_TIME, "Player lastTimeVisible");
        isVisible = (lastTimeVisible + 0.3f) > lp->worldTime || isDrone;

        if (lp->isValid()) {
            isLocal = base == lp->base;
            isFriendly = isSameTeam(map, lp);
            isEnemy = !isFriendly || isItem || cl->AIMBOT_FRIENDLY_FIRE;// || map->isTrainingArea && isDrone;
            distanceToLocalPlayer = lp->localOrigin.Distance(localOrigin);
            distance2DToLocalPlayer = lp->localOrigin.Distance2D(localOrigin);
            //distance2DToLocalPlayer = lp->localOrigin.To2D().Distance(localOrigin.To2D());
        }
    }

    bool isValid() {
        return base != 0 && (isPlayer || isDrone || isDummie || isItem);
    }

    bool isCombatReady() {
        if (!isValid()) return false;
        if (isDrone || isDummie) return true;
        if (isDead || isKnocked) return false;
        return true;
    }

    std::string getPlayerName(){
        uintptr_t nameOffset = mem::Read<uintptr_t>(OFF_REGION + OFF_NAME_LIST + ((plyrDataTable - 1) * 24), "Player nameOffset");
        std::string playerName = mem::ReadString(nameOffset, 64, "Player playerName");
        return playerName;
    }

    int GetPlayerLevel() {
        int m_xp = mem::Read<int>(base + OFF_XP_LEVEL, "Player m_xp");
        if (m_xp < 0) return 0;
        if (m_xp < 100) return 1;

        int levels[] = { 2750, 6650, 11400, 17000, 23350, 30450, 38300, 46450, 55050,
        64100, 73600, 83550, 93950, 104800, 116100, 127850, 140050, 152400, 164900,
        177550, 190350, 203300, 216400, 229650, 243050, 256600, 270300, 284150, 298150,
        312300, 326600, 341050, 355650, 370400, 385300, 400350, 415550, 430900, 446400,
        462050, 477850, 493800, 509900, 526150, 542550, 559100, 575800, 592650, 609650,
        626800, 644100, 661550, 679150, 696900, 714800 };

        int level = 56;

        int arraySize = sizeof(levels) / sizeof(levels[0]);
        for (int i = 0; i < arraySize; i++)
            if (m_xp < levels[i])
                return i + 1;

        return level + ((m_xp - levels[arraySize - 1] + 1) / 18000);
    }

    int getBoneFromHitbox(HitboxType hitbox) const {
        long modelPointer = mem::Read<long>(base + OFF_STUDIO_HDR, "Player modelPointer");
        if (!mem::IsValidPointer(modelPointer))
            return -1;

        long studioHdr = mem::Read<long>(modelPointer + 0x8, "Player studioHdr");
        if (!mem::IsValidPointer(studioHdr + 0x34))
            return -1;

        auto hitboxCache = mem::Read<uint16_t>(studioHdr + 0x34, "Player hitboxCache");
        auto hitboxArray = studioHdr + ((uint16_t)(hitboxCache & 0xFFFE) << (4 * (hitboxCache & 1)));
        if (!mem::IsValidPointer(hitboxArray + 0x4))
            return -1;

        auto indexCache = mem::Read<uint16_t>(hitboxArray + 0x4, "Player indexCache");
        auto hitboxIndex = ((uint16_t)(indexCache & 0xFFFE) << (4 * (indexCache & 1)));
        auto bonePointer = hitboxIndex + hitboxArray + (static_cast<int>(hitbox) * 0x20);
        if (!mem::IsValidPointer(bonePointer))
            return -1;

        return mem::Read<uint16_t>(bonePointer, "Player bonePointer");
    }

    Vector3D getBonePosition(HitboxType hitbox) const {
        Vector3D offset = Vector3D(0.0f, 0.0f, 50.0f);

        int bone = getBoneFromHitbox(hitbox);
        if (bone < 0 || bone > 255)
            return localOrigin.Add(offset);

        long boneMatrixPtr = mem::Read<long>(base + OFF_BONE, "Player boneMatrixPtr");
        boneMatrixPtr += (bone * sizeof(Matrix3x4));
        if (!mem::IsValidPointer(boneMatrixPtr))
            return localOrigin.Add(offset);

        Matrix3x4 boneMatrix = mem::Read<Matrix3x4>(boneMatrixPtr, "Player boneMatrix");
        Vector3D bonePosition = boneMatrix.GetPosition();
        if (!bonePosition.IsValid())
            return localOrigin.Add(offset);

        return localOrigin.Add(bonePosition);
    }
};
