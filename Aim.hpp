#pragma once
#include "LocalPlayer.hpp"
#include "Player.hpp"
struct Aim {
    HitboxType Hitbox = HitboxType::Neck;
    float FinalDistance = 0;
    float FinalFOV = 0;
    float HipfireDistance = 60;

    MyDisplay* display;
    LocalPlayer* lp;
    std::vector<Player*>* players;
    ConfigLoader* cl;
    Player* CurrentTarget = nullptr;
    bool TargetSelected = true;

    Aim(MyDisplay* myDisplay, LocalPlayer* localPlayer, std::vector<Player*>* all_players, ConfigLoader* ConfigLoada) {
        this->display = myDisplay;
        this->lp = localPlayer;
        this->players = all_players;
        this->cl = ConfigLoada;   
    }
//_    bool active(){
    bool active(bool leftLock, bool rightLock){ //_add
        bool aimbotIsOn = cl->FEATURE_AIMBOT_ON;
        bool combatReady = lp->isCombatReady();
        bool activatedByAttack = cl->AIMBOT_ACTIVATED_BY_ATTACK && lp->inAttack;
        bool activatedByADS = cl->AIMBOT_ACTIVATED_BY_ADS && lp->inZoom;
        bool activatedByKey = cl->AIMBOT_ACTIVATED_BY_KEY && (cl->AIMBOT_ACTIVATION_KEY != "" || "NONE" ) && display->keyDown(cl->AIMBOT_ACTIVATION_KEY);
        bool active = aimbotIsOn
            && combatReady
//_            && (activatedByAttack
            && ((activatedByAttack && leftLock) //_add
//_                || activatedByADS
                || (activatedByADS && rightLock) //_add
                || activatedByKey);
        return active;
    }
//_    void update(int counter) {
    void update(int counter, bool leftLock, bool rightLock) { //_add
        if (lp->grippingGrenade){ ReleaseTarget(); return; }
//_        if (!active()){ ReleaseTarget(); return; }
        if (!active(leftLock, rightLock)){ ReleaseTarget(); return; } //_add
        if (lp->inZoom) {
            FinalFOV = cl->AIMBOT_FOV;
            FinalDistance = cl->AIMBOT_MAX_DISTANCE;
        }
        else {
            FinalFOV = (cl->AIMBOT_FOV + 20);
            FinalDistance = HipfireDistance;
        }

        Player* Target = CurrentTarget;
        if (!IsValidTarget(Target)) {
            if(TargetSelected && !cl->AIMBOT_ALLOW_TARGET_SWITCH)
                return;

            Target = FindBestTarget();
            if (!IsValidTarget(Target)) {
                CurrentTarget = nullptr;
                return;
            }
            CurrentTarget = Target;
            CurrentTarget->IsLockedOn = true;
            TargetSelected = true;
        }

        double DistanceFromCrosshair = CalculateDistanceFromCrosshair(CurrentTarget);
        if (DistanceFromCrosshair > FinalFOV || DistanceFromCrosshair == -1) {
            ReleaseTarget();
            return;
        }
        StartAiming();
    }

    void StartAiming() {
        QAngle DesiredAngles = QAngle(0, 0);
        if (!GetAngle(CurrentTarget, DesiredAngles))
            return;

        Vector2D DesiredAnglesIncrement = Vector2D(CalculatePitchIncrement(DesiredAngles), CalculateYawIncrement(DesiredAngles));

        float Extra = cl->AIMBOT_SMOOTH_EXTRA_BY_DISTANCE / CurrentTarget->distanceToLocalPlayer;
        float TotalSmooth = cl->AIMBOT_SMOOTH + Extra;

        Vector2D punchAnglesDiff = lp->punchAnglesDiff.Divide(cl->AIMBOT_SMOOTH).Multiply(cl->AIMBOT_SPEED);
        double nrPitchIncrement = punchAnglesDiff.x;
        double nrYawIncrement = -punchAnglesDiff.y;

        Vector2D aimbotDelta = DesiredAnglesIncrement.Divide(TotalSmooth).Multiply(cl->AIMBOT_SPEED);
        double aimYawIncrement = aimbotDelta.y * -1;
        double aimPitchIncrement = aimbotDelta.x;

        double totalPitchIncrement = aimPitchIncrement + nrPitchIncrement;
        double totalYawIncrement = aimYawIncrement + nrYawIncrement;

        int totalPitchIncrementInt = RoundHalfEven(AL1AF0(totalPitchIncrement));
        int totalYawIncrementInt = RoundHalfEven(AL1AF0(totalYawIncrement));

//_begin
        int zoomedMaxMove = cl->AIMBOT_ZOOMED_MAX_MOVE;
        int hipfireMaxMove = cl->AIMBOT_HIPFIRE_MAX_MOVE;

        // if (lp->inZoom) { //Ape-xCV; this method is slow
        if (display->isRightMouseButtonDown()) {
            if (totalPitchIncrementInt > zoomedMaxMove) totalPitchIncrementInt = zoomedMaxMove;
            if (totalPitchIncrementInt < zoomedMaxMove * -1) totalPitchIncrementInt = zoomedMaxMove * -1;
            if (totalYawIncrementInt > zoomedMaxMove) totalYawIncrementInt = zoomedMaxMove;
            if (totalYawIncrementInt < zoomedMaxMove * -1) totalYawIncrementInt = zoomedMaxMove * -1;
        } else {
            if (totalPitchIncrementInt > hipfireMaxMove) totalPitchIncrementInt = hipfireMaxMove;
            if (totalPitchIncrementInt < hipfireMaxMove * -1) totalPitchIncrementInt = hipfireMaxMove * -1;
            if (totalYawIncrementInt > hipfireMaxMove) totalYawIncrementInt = hipfireMaxMove;
            if (totalYawIncrementInt < hipfireMaxMove * -1) totalYawIncrementInt = hipfireMaxMove * -1;
        }

//_end
        if (totalPitchIncrementInt == 0 && totalYawIncrementInt == 0) return;
        display->moveMouseRelative(totalPitchIncrementInt, totalYawIncrementInt);
    }

    bool GetAngle(const Player* Target, QAngle& Angle) {
        const QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();
        if (!CurrentAngle.isValid())
            return false;

        if (!GetAngleToTarget(Target, Angle))
            return false;

        return true;
    }

    bool GetAngleToTarget(const Player* Target, QAngle& Angle) const {
        const Vector3D TargetPosition = Target->GetBonePosition(Hitbox);
        const Vector3D TargetVelocity = Target->AbsoluteVelocity;
        const Vector3D CameraPosition = lp->CameraPosition;
        const QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();
        
        if (lp->WeaponProjectileSpeed > 1.0f) {
            if (cl->AIMBOT_PREDICT_BULLETDROP && cl->AIMBOT_PREDICT_MOVEMENT) {
                return Resolver::CalculateAimRotationNew(CameraPosition, TargetPosition, TargetVelocity, lp->WeaponProjectileSpeed, lp->WeaponProjectileScale, 255, Angle);
            }
            else if (cl->AIMBOT_PREDICT_BULLETDROP) {
                return Resolver::CalculateAimRotationNew(CameraPosition, TargetPosition, Vector3D(0, 0, 0), lp->WeaponProjectileSpeed, lp->WeaponProjectileScale, 255, Angle);
            }
            else if (cl->AIMBOT_PREDICT_MOVEMENT) {
                return Resolver::CalculateAimRotation(CameraPosition, TargetPosition, TargetVelocity, lp->WeaponProjectileSpeed, Angle);
            }
        }

        Angle = Resolver::CalculateAngle(CameraPosition, TargetPosition);
        return true;   
    }

    bool IsValidTarget(Player* target) {
        if (target == nullptr ||
            !target->isValid() || 
            !target->isCombatReady() ||
            !target->visible || 
            !target->enemy || 
            target->distance2DToLocalPlayer < Conversion::ToGameUnits(cl->AIMBOT_MIN_DISTANCE) || 
            target->distance2DToLocalPlayer > Conversion::ToGameUnits(FinalDistance))
            return false;
        return true;
    }

    float CalculatePitchIncrement(QAngle AimbotDesiredAngles) {
        float wayA = AimbotDesiredAngles.x - lp->viewAngles.x;
        float wayB = 180 - abs(wayA);
        if (wayA > 0 && wayB > 0)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }

    float CalculateYawIncrement(QAngle AimbotDesiredAngles) {
        float wayA = AimbotDesiredAngles.y - lp->viewAngles.y;
        float wayB = 360 - abs(wayA);
        if (wayA > 0 && wayB > 0)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }

    double CalculateDistanceFromCrosshair(Player* target) {
        Vector3D CameraPosition = lp->CameraPosition;
        QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();

        Vector3D TargetPos = target->localOrigin;
        if (CameraPosition.Distance(TargetPos) <= 0.0001f)
            return -1;

        QAngle TargetAngle = Resolver::CalculateAngle(CameraPosition, TargetPos);
        if (!TargetAngle.isValid())
            return -1;
        
        return CurrentAngle.distanceTo(TargetAngle);
    }

    Player* FindBestTarget() {
        float NearestDistance = 9999;
        Player* BestTarget = nullptr;
        Vector3D CameraPosition = lp->CameraPosition;
        QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();
        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!IsValidTarget(p)) continue;

            double DistanceFromCrosshair = CalculateDistanceFromCrosshair(p);
            if (DistanceFromCrosshair > FinalFOV || DistanceFromCrosshair == -1)
                continue;

            if (DistanceFromCrosshair < NearestDistance) {
                BestTarget = p;
                NearestDistance = DistanceFromCrosshair;
            }
        }
        return BestTarget;
    }

    void ReleaseTarget() {
        if (CurrentTarget != nullptr && CurrentTarget->isValid())
            CurrentTarget->IsLockedOn = false;
        
        TargetSelected = false;
        CurrentTarget = nullptr;
    }

    int RoundHalfEven(float x) {
        return (x >= 0.0)
            ? static_cast<int>(std::round(x))
            : static_cast<int>(std::round(-x)) * -1;
    }

    float AL1AF0(float num) {
        if (num > 0) return std::max(num, 1.0f);
        return std::min(num, -1.0f);
    }
};
