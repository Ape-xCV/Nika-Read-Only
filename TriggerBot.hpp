#pragma once
struct TriggerBot {
    ConfigLoader* cl;
    MyDisplay* display;
    LocalPlayer* lp;
    std::vector<Player*>* players;

    TriggerBot(ConfigLoader* configLoada, MyDisplay* myDisplay, LocalPlayer* localPlayer, std::vector<Player*>* all_players) {
        this->cl = configLoada;
        this->display = myDisplay;
        this->lp = localPlayer;
        this->players = all_players;
    }
    
//_    void shootAtEnemy(int counter) {
    void shootAtEnemy(int counter, bool autoFire) { //_add
        static std::chrono::milliseconds timeLastShot; //_add
//_        if (!cl->FEATURE_TRIGGERBOT_ON || display->keyDown(cl->TRIGGERBOT_PAUSE_BUTTON)) return;
        if (!cl->FEATURE_TRIGGERBOT_ON || !display->keyDown(cl->AIMBOT_ACTIVATION_KEY)) return; //_add
        if (!lp->isCombatReady()) return;
        
        int weaponId = lp->weaponIndex;
        //printf("Last weapon held: [%s] - id: [%d]- GrenadeID: [%d] - Ammo: [%d]\n", WeaponName(weaponId).c_str(), weaponId, lp->grenadeID, lp->ammoInClip);        
        if (
            weaponId != WEAPON_KRABER &&
            weaponId != WEAPON_P2020 &&
            weaponId != WEAPON_MOZAMBIQUE &&
            weaponId != WEAPON_EVA8 &&
            weaponId != WEAPON_PEACEKEEPER &&
            weaponId != WEAPON_MASTIFF &&
            weaponId != WEAPON_WINGMAN &&
            weaponId != WEAPON_LONGBOW &&
            weaponId != WEAPON_SENTINEL &&
            weaponId != WEAPON_G7 &&
            weaponId != WEAPON_HEMLOCK &&
            weaponId != WEAPON_3030 &&
            weaponId != WEAPON_TRIPLE_TAKE &&
            weaponId != WEAPON_BOCEK &&
            weaponId != WEAPON_THROWING_KNIFE
            )return;

        const float RANGE_MAX = (lp->inZoom) ? util::metersToGameUnits(cl->TRIGGERBOT_ZOOMED_RANGE) : util::metersToGameUnits(cl->TRIGGERBOT_HIPFIRE_RANGE);

        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            std::chrono::milliseconds timeNow = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()); //_add
            if ((timeNow < timeLastShot + std::chrono::milliseconds(125)) || !autoFire) continue; //_add
            if (!p->isCombatReady()) continue;
            if (!p->enemy) continue;
            if (!p->aimedAt) continue;
            if (!p->visible) continue;
            
            if (p->distanceToLocalPlayer <= RANGE_MAX ) {
                display->mouseClickLeft();
                timeLastShot = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()); //_add
                break;
            }
        }
    }
};
