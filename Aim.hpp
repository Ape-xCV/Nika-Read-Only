#pragma once
#include "LocalPlayer.hpp"
#include "Player.hpp"
struct Aim {
    HitboxType Hitbox = HitboxType::Neck;
    float FinalDistance = 0;
    float FinalFOV = 0;
    float HipfireDistance = 60;
    int lastMoveX = 0; //_add
    int lastMoveY = 0; //_add

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
//_        bool activatedByAttack = cl->AIMBOT_ACTIVATED_BY_ATTACK && lp->inAttack;
        bool activatedByAttack = cl->AIMBOT_ACTIVATED_BY_ATTACK && display->isLeftMouseButtonDown(); //_add
        bool activatedByADS = cl->AIMBOT_ACTIVATED_BY_ADS && lp->inZoom;
        bool activatedByKey = cl->AIMBOT_ACTIVATED_BY_KEY && (cl->AIMBOT_ACTIVATION_KEY != "" || "NONE" ) && display->keyDown(cl->AIMBOT_ACTIVATION_KEY);
        bool active = aimbotIsOn
            && combatReady
            && (activatedByAttack
            //&& ((activatedByAttack && leftLock) //_add
//_                || activatedByADS
                || (activatedByADS && rightLock) //_add
                || activatedByKey);
        return active;
    }
//_    void update(int counter) {
    void update(int counter, double averageProcessingTime, bool leftLock, bool rightLock, int boneID) { //_add
        if (boneID == 0) Hitbox = HitboxType::UpperChest; //_add
        else if (boneID == 1) Hitbox = HitboxType::Neck; //_add
        else Hitbox = HitboxType::Head; //_add
        if (lp->grippingGrenade){ ReleaseTarget(); return; }
//_        if (!active()){ ReleaseTarget(); return; }
        if (!active(leftLock, rightLock)){ ReleaseTarget(); return; } //_add
        if (lp->inZoom) {
            FinalFOV = cl->AIMBOT_FOV;
            FinalDistance = cl->AIMBOT_MAX_DISTANCE;
        }
        else {
//_            FinalFOV = (cl->AIMBOT_FOV + 20);
            FinalFOV = (cl->AIMBOT_FOV * 2); //_add
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
//_        StartAiming();
        StartAiming(averageProcessingTime, leftLock); //_add
    }

//_    void StartAiming() {
    void StartAiming(double interval, bool leftLock) { //_add
        QAngle DesiredAngles = QAngle(0, 0);
        if (!GetAngle(CurrentTarget, DesiredAngles))
            return;

        Vector2D DesiredAnglesIncrement = Vector2D(CalculatePitchIncrement(DesiredAngles), CalculateYawIncrement(DesiredAngles));

        float Extra = cl->AIMBOT_SMOOTH_EXTRA_BY_DISTANCE / CurrentTarget->distanceToLocalPlayer;
        float TotalSmooth = cl->AIMBOT_SMOOTH + Extra;
        TotalSmooth /= (2 + interval * 0.5); //_add
        if (!leftLock) TotalSmooth *= cl->AIMBOT_WEAKEN; //_add

//_        Vector2D punchAnglesDiff = lp->punchAnglesDiff.Divide(cl->AIMBOT_SMOOTH).Multiply(cl->AIMBOT_SPEED);
//_        double nrPitchIncrement = punchAnglesDiff.x;
//_        double nrYawIncrement = punchAnglesDiff.y * -1;

        Vector2D aimbotDelta = DesiredAnglesIncrement.Divide(TotalSmooth).Multiply(cl->AIMBOT_SPEED);
        double aimPitchIncrement = aimbotDelta.x;
        double aimYawIncrement = aimbotDelta.y * -1;

//_        double totalPitchIncrement = aimPitchIncrement + nrPitchIncrement;
//_        double totalYawIncrement = aimYawIncrement + nrYawIncrement;

//_        int totalPitchIncrementInt = RoundHalfEven(AL1AF0(totalPitchIncrement));
//_        int totalYawIncrementInt = RoundHalfEven(AL1AF0(totalYawIncrement));
        int totalPitchIncrementInt = RoundHalfEven(AL1AF0(aimPitchIncrement)); //_add
        int totalYawIncrementInt = RoundHalfEven(AL1AF0(aimYawIncrement)); //_add

//_begin
        int zoomedMaxMove = cl->AIMBOT_ZOOMED_MAX_MOVE;
        int hipfireMaxMove = cl->AIMBOT_HIPFIRE_MAX_MOVE;

        if (lp->inZoom) {
            if (totalPitchIncrementInt > zoomedMaxMove) totalPitchIncrementInt = zoomedMaxMove;
            else if (totalPitchIncrementInt < zoomedMaxMove * -1) totalPitchIncrementInt = zoomedMaxMove * -1;
            if (totalYawIncrementInt > zoomedMaxMove) totalYawIncrementInt = zoomedMaxMove;
            else if (totalYawIncrementInt < zoomedMaxMove * -1) totalYawIncrementInt = zoomedMaxMove * -1;
        } else {
            if (totalPitchIncrementInt > hipfireMaxMove) totalPitchIncrementInt = hipfireMaxMove;
            else if (totalPitchIncrementInt < hipfireMaxMove * -1) totalPitchIncrementInt = hipfireMaxMove * -1;
            if (totalYawIncrementInt > hipfireMaxMove) totalYawIncrementInt = hipfireMaxMove;
            else if (totalYawIncrementInt < hipfireMaxMove * -1) totalYawIncrementInt = hipfireMaxMove * -1;
        }

        if (abs(totalPitchIncrementInt - lastMoveY) > cl->AIMBOT_MAX_DELTA)
            if (totalPitchIncrementInt > lastMoveY)
                totalPitchIncrementInt = lastMoveY + cl->AIMBOT_MAX_DELTA;
            else
                totalPitchIncrementInt = lastMoveY - cl->AIMBOT_MAX_DELTA;
        if (abs(totalYawIncrementInt - lastMoveX) > cl->AIMBOT_MAX_DELTA)
            if (totalYawIncrementInt > lastMoveX)
                totalYawIncrementInt = lastMoveX + cl->AIMBOT_MAX_DELTA;
            else
                totalYawIncrementInt = lastMoveX - cl->AIMBOT_MAX_DELTA;

        if ((aimPitchIncrement > -1.0f) && (aimPitchIncrement < 1.0f)) totalPitchIncrementInt = 0;
        if ((aimYawIncrement > -1.0f) && (aimYawIncrement < 1.0f)) totalYawIncrementInt = 0;
//_end
        if (totalPitchIncrementInt == 0 && totalYawIncrementInt == 0) return;
        display->moveMouseRelative(totalPitchIncrementInt, totalYawIncrementInt);
        lastMoveY = totalPitchIncrementInt; //_add
        lastMoveX = totalYawIncrementInt; //_add
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
