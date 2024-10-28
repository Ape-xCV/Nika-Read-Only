#pragma once

struct LocalPlayer {
    ConfigLoader* cl;
    uint16_t index;
    uintptr_t base;
    //uint64_t base;
    int teamNumber;
    int squadNumber;
    Vector3D localOrigin;
    float worldTime;
    float worldTimePrev;
    int currentHealth;
    bool isDead;
    bool isKnocked;
    uint8_t grenadeId;
    uint8_t ultimateId;
    bool grippingGrenade;
    uint16_t weaponHandle;
    long weaponEntity;
    uint16_t weaponId;
    float weaponProjectileSpeed;
    float weaponProjectileScale;
    float zoomFov;
    bool inZoom;
    Vector2D viewAngles;
    Vector3D cameraPosition;
    int frameCount; 
    float traversalStartTime;
    float traversalProgress;

    LocalPlayer(ConfigLoader* in_cl) {
        this->cl = in_cl;
    }

    void reset() {
        base = 0;
    }

    void readFromMemory() {
        index = mem::Read<uint16_t>(OFF_REGION + OFF_LOCAL_ENTITY_HANDLE, "LocalPlayer index");
        long basePointer = static_cast<long>(OFF_REGION + OFF_ENTITY_LIST + (index << 5));
        if (!mem::IsValidPointer(basePointer)) { reset(); return; }
        base = mem::Read<uintptr_t>(basePointer, "LocalPlayer base");
        //base = mem::Read<long>(OFF_REGION + OFF_LOCAL_PLAYER, "LocalPlayer base");
        if (base == 0) return;
        teamNumber = mem::Read<int>(base + OFF_TEAM_NUMBER, "LocalPlayer teamNumber");
        squadNumber = mem::Read<int>(base + OFF_SQUAD_ID, "LocalPlayer squadNumber");
        localOrigin = mem::Read<Vector3D>(base + OFF_LOCAL_ORIGIN, "LocalPlayer localOrigin");
        worldTime = mem::Read<float>(base + OFF_TIME_BASE, "LocalPlayer worldTime");
        if (worldTimePrev + 0.01f < worldTime)
            worldTimePrev = worldTime;
        currentHealth = mem::Read<int>(base + OFF_HEALTH, "LocalPlayer currentHealth");
        isDead = mem::Read<short>(base + OFF_LIFE_STATE, "LocalPlayer isDead") > 0;
        isKnocked = mem::Read<short>(base + OFF_BLEEDOUT_STATE, "LocalPlayer isKnocked") > 0;
        if (!isDead && !isKnocked) {
            grenadeId = mem::Read<uint8_t>(base + OFF_GRENADE_HANDLE, "LocalPlayer grenadeId");
            ultimateId = mem::Read<uint8_t>(base + OFF_GRENADE_HANDLE + 0x2, "LocalPlayer ultimateId");
            grippingGrenade = (grenadeId == 5 || grenadeId == 6) && ultimateId == 255 ? true : false;
            weaponHandle = mem::Read<uint16_t>(base + OFF_WEAPON_HANDLE, "LocalPlayer weaponHandle");
            weaponEntity = mem::Read<long>(OFF_REGION + OFF_ENTITY_LIST + ((weaponHandle & 0xFFFF) << 5), "LocalPlayer weaponEntity");
            weaponId = mem::Read<uint16_t>(weaponEntity + OFF_WEAPON_INDEX, "LocalPlayer weaponId");
            weaponProjectileSpeed = ultimateId == 4 ? 24000.0f : 0.7f * mem::Read<float>(weaponEntity + OFF_PROJECTILE_SPEED, "LocalPlayer weaponProjectileSpeed");
            weaponProjectileScale = ultimateId == 4 ? 0.5f : 0.5f * mem::Read<float>(weaponEntity + OFF_PROJECTILE_SCALE, "LocalPlayer weaponProjectileScale");
            zoomFov = mem::Read<float>(weaponEntity + OFF_ZOOM_FOV, "LocalPlayer zoomFov");
        }
        inZoom = mem::Read<short>(base + OFF_ZOOMING, "LocalPlayer inZoom") > 0;
        viewAngles = mem::Read<Vector2D>(base + OFF_VIEW_ANGLES, "LocalPlayer viewAngles");
        cameraPosition = mem::Read<Vector3D>(base + OFF_CAMERA_ORIGIN, "LocalPlayer cameraPosition");
        if (cl->FEATURE_SUPER_GLIDE_ON) {
            frameCount = mem::Read<int>(OFF_REGION + OFF_GLOBAL_VARS + sizeof(double), "LocalPlayer frameCount");
            traversalStartTime = mem::Read<float>(base + OFF_TRAVERSAL_START_TIME, "LocalPlayer traversalStartTime");
            traversalProgress = mem::Read<float>(base + OFF_TRAVERSAL_PROGRESS, "LocalPlayer traversalProgress");
        }
    }

    bool isValid() {
        return base != 0;
    }

    bool isCombatReady() {
        if (!isValid() || isDead || isKnocked) return false;
        return true;
    }
};
