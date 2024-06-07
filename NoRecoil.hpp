#pragma once
struct NoRecoil {
    ConfigLoader* cl;
    MyDisplay* display;
    Level* map;
    LocalPlayer* lp;
    int noRecPitch;
    int noRecYaw;

    NoRecoil(ConfigLoader* cl, MyDisplay* myDisplay, Level* level, LocalPlayer* localPlayer) {
        this->cl = cl;
        this->display = myDisplay;
        this->map = level;
        this->lp = localPlayer;
    }

    void controlWeapon() {
        noRecPitch = cl->NORECOIL_PITCH_REDUCTION; 
        noRecYaw = cl->NORECOIL_YAW_REDUCTION; 
        if (!cl->FEATURE_NORECOIL_ON)return;
        if (!lp->isCombatReady()) return;
        if (!lp->inAttack) return;
        Vector2D punchAnglesDiff = lp->punchAnglesDiff;
        if (punchAnglesDiff.IsZeroVector()) return;
        int pitch = (punchAnglesDiff.x > 0)
            ? roundHalfEven(punchAnglesDiff.x * noRecPitch)
            : 0;
        int yaw = roundHalfEven(-punchAnglesDiff.y * noRecYaw);
        display->moveMouseRelative(pitch, yaw);
    }
    int roundHalfEven(float x) {
        return (x >= 0.0)
            ? static_cast<int>(std::round(x))
            : static_cast<int>(std::round(-x)) * -1;
    }
};
