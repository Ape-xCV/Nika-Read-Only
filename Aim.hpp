#pragma once
#include "LocalPlayer.hpp"
#include "Player.hpp"
#include "Utils/Camera.hpp" //_add
struct Aim {
    ConfigLoader* cl;
    MyDisplay* display;
    LocalPlayer* lp;
    std::vector<Player*>* players;
    Camera* GameCamera; //_add
    HitboxType Hitbox = HitboxType::Neck;
    float FinalFOV = 0.0f;
    float FinalDistance = 0.0f;
//_    float HipfireDistance = 60.0f;
    Player* CurrentTarget = nullptr;
    bool TargetSelected = true;
    int lastMoveX = 0; //_add
    int lastMoveY = 0; //_add

//_    Aim(ConfigLoader* ConfigLoada, MyDisplay* myDisplay, LocalPlayer* localPlayer, std::vector<Player*>* all_players) {
    Aim(ConfigLoader* ConfigLoada, MyDisplay* myDisplay, LocalPlayer* localPlayer, std::vector<Player*>* all_players, Camera* GameCamera) { //_add
        this->cl = ConfigLoada;
        this->display = myDisplay;
        this->lp = localPlayer;
        this->players = all_players;
        this->GameCamera = GameCamera; //_add
    }
//_    bool active() {
    bool active(bool leftLock, bool rightLock) { //_add
        bool aimbotIsOn = cl->FEATURE_AIMBOT_ON;
        bool combatReady = lp->isCombatReady();
        bool activatedByAttack = cl->AIMBOT_ACTIVATED_BY_ATTACK && lp->inAttack;
//_        bool activatedByADS = cl->AIMBOT_ACTIVATED_BY_ADS && lp->inZoom;
        bool activatedByADS = rightLock && lp->inZoom; //_add
//_        bool activatedByKey = cl->AIMBOT_ACTIVATED_BY_KEY && (cl->AIMBOT_ACTIVATION_KEY != "" || "NONE") && display->isKeyDown(cl->AIMBOT_ACTIVATION_KEY);
        bool activatedByKey = keymap::AIMBOT_ACTIVATION_KEY; //_add
        bool active = aimbotIsOn
            && combatReady
            && (activatedByAttack
                || activatedByADS
                || activatedByKey);
        return active;
    }
//_    void update(int counter) {
    void update(int counter, double averageProcessingTime, bool leftLock, bool rightLock, bool autoFire, int boneID, int TotalSpectators) { //_add
        if (keymap::AIMBOT_FIRING_KEY && (!keymap::AIMBOT_ACTIVATION_KEY || CurrentTarget != nullptr && !CurrentTarget->visible)) { //_add
            display->kbRelease(cl->AIMBOT_FIRING_KEY); //_add
            keymap::AIMBOT_FIRING_KEY = false; //_add
        } //_add
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
            FinalFOV = (cl->AIMBOT_FOV + 20.0f);
//_            FinalDistance = HipfireDistance;
            FinalDistance = cl->TRIGGERBOT_HIPFIRE_RANGE; //_add
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

        Vector3D TargetBone3DCached = CurrentTarget->GetBonePosition(Hitbox); //_add
//_        double DistanceFromCrosshair = CalculateDistanceFromCrosshair(CurrentTarget);
        double DistanceFromCrosshair = CalculateDistanceFromCrosshair(TargetBone3DCached); //_add
//_        if (DistanceFromCrosshair > FinalFOV || DistanceFromCrosshair == -1) {
        if (!lp->inAttack && (rightLock && !lp->inZoom) && !keymap::AIMBOT_ACTIVATION_KEY || DistanceFromCrosshair == -1) { //_add
            ReleaseTarget();
            return;
        }
        int zoomedMaxMove = cl->AIMBOT_ZOOMED_MAX_MOVE; //_add
        int hipfireMaxMove = cl->AIMBOT_HIPFIRE_MAX_MOVE; //_add
        int maxDelta = cl->AIMBOT_MAX_DELTA; //_add
        if (DistanceFromCrosshair < FinalFOV * cl->AIMBOT_FAST_AREA) { //_add
            zoomedMaxMove *= cl->AIMBOT_SLOW_AREA; //_add
            hipfireMaxMove *= cl->AIMBOT_SLOW_AREA; //_add
            maxDelta /= cl->AIMBOT_WEAKEN; //_add
        } else if (DistanceFromCrosshair < FinalFOV * cl->AIMBOT_SLOW_AREA) { //_add
            zoomedMaxMove *= cl->AIMBOT_FAST_AREA; //_add
            hipfireMaxMove *= cl->AIMBOT_FAST_AREA; //_add
            maxDelta /= cl->AIMBOT_WEAKEN; //_add
        } //_add
//_        StartAiming();
//_    }

//_    void StartAiming() {
        QAngle DesiredAngles = QAngle(0.0f, 0.0f);
        if (!GetAngle(CurrentTarget, DesiredAngles))
            return;

        Vector2D DesiredAnglesIncrement = Vector2D(CalculatePitchIncrement(DesiredAngles), CalculateYawIncrement(DesiredAngles));

        float Extra = cl->AIMBOT_SMOOTH_EXTRA_BY_DISTANCE / CurrentTarget->distanceToLocalPlayer;
        float TotalSmooth = cl->AIMBOT_SMOOTH + Extra;
        TotalSmooth /= (1 + averageProcessingTime * 0.3f); //_add
        float bulletSpeed = lp->WeaponProjectileSpeed * 0.95f; //_add
        if (!leftLock || !lp->inZoom || cl->AIMBOT_SPECTATORS_WEAKEN && TotalSpectators > 0) { //_add
            TotalSmooth *= cl->AIMBOT_WEAKEN; //_add
            bulletSpeed -= bulletSpeed * (cl->AIMBOT_SMOOTH / 200) * cl->AIMBOT_WEAKEN; //_add
        } //_add

//_        Vector2D punchAnglesDiff = lp->punchAnglesDiff.Multiply(cl->AIMBOT_SPEED).Divide(cl->AIMBOT_SMOOTH);
//_        double nrPitchIncrement = punchAnglesDiff.x;
//_        double nrYawIncrement = -punchAnglesDiff.y;

        Vector2D aimbotDelta = DesiredAnglesIncrement.Multiply(cl->AIMBOT_SPEED).Divide(TotalSmooth);
        double aimPitchIncrement = aimbotDelta.x;
        double aimYawIncrement = -aimbotDelta.y;

        double totalPitchIncrement = aimPitchIncrement; //_+ nrPitchIncrement;
        double totalYawIncrement = aimYawIncrement; //_+ nrYawIncrement;

        int totalPitchIncrementInt = RoundHalfEven(AL1AF0(totalPitchIncrement));
        int totalYawIncrementInt = RoundHalfEven(AL1AF0(totalYawIncrement));

//_begin
        Vector2D LocalOriginW2S, HeadPositionW2S;
        Vector3D LocalOrigin3D = CurrentTarget->localOrigin;
        Vector3D HeadPosition3D = CurrentTarget->GetBonePosition(HitboxType::Head);
        bool bLocalOriginW2SValid = GameCamera->WorldToScreen(LocalOrigin3D, LocalOriginW2S);
        bool bHeadPositionW2SValid = GameCamera->WorldToScreen(HeadPosition3D, HeadPositionW2S);
        float width = (LocalOriginW2S.y - HeadPositionW2S.y) / 2;
        width += width*util::inchesToMeters(CurrentTarget->distance2DToLocalPlayer / 85);
        Vector2D TargetBoneW2S;
        Vector3D TargetBone3D = TargetBone3DCached;
        Vector2D ScreenSize = GameCamera->GetResolution();
        if (!cl->AIMBOT_LEGACY_MODE) {
            if (cl->AIMBOT_PREDICT_BULLETDROP && lp->WeaponProjectileSpeed > 999.9f)
                if (lp->WeaponProjectileScale >= 0.5f && lp->WeaponProjectileScale <= 1.6f)
                    TargetBone3D.z += Resolver::GetBasicBulletDrop(lp->CameraPosition, TargetBone3D, lp->WeaponProjectileSpeed, lp->WeaponProjectileScale);
                else
                    TargetBone3D.z += Resolver::GetBasicBulletDrop(lp->CameraPosition, TargetBone3D, lp->WeaponProjectileSpeed, 1.0f);
            if (cl->AIMBOT_PREDICT_MOVEMENT && lp->WeaponProjectileSpeed > 999.9f)
                //if (CurrentTarget->AbsoluteVelocity.IsZeroVector())
                if (CurrentTarget->isDummie())
                    TargetBone3D = Resolver::GetTargetPosition(lp->CameraPosition, TargetBone3D, CurrentTarget->velocity, bulletSpeed);
                else
                    TargetBone3D = Resolver::GetTargetPosition(lp->CameraPosition, TargetBone3D, CurrentTarget->AbsoluteVelocity, bulletSpeed);
            GameCamera->WorldToScreen(TargetBone3D, TargetBoneW2S);
            totalPitchIncrementInt = (TargetBoneW2S.y - ScreenSize.y/2) * cl->AIMBOT_SPEED / TotalSmooth / 10;
            totalYawIncrementInt = (TargetBoneW2S.x - ScreenSize.x/2) * cl->AIMBOT_SPEED / TotalSmooth / 10;
        }
        zoomedMaxMove *= util::randomFloat(1.0f, 1.25f);
        hipfireMaxMove *= util::randomFloat(1.0f, 1.25f);

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

        if (abs(totalPitchIncrementInt - lastMoveY) > maxDelta)
            if (totalPitchIncrementInt > lastMoveY)
                totalPitchIncrementInt = lastMoveY + maxDelta;
            else
                totalPitchIncrementInt = lastMoveY - maxDelta;
        if (abs(totalYawIncrementInt - lastMoveX) > maxDelta)
            if (totalYawIncrementInt > lastMoveX)
                totalYawIncrementInt = lastMoveX + maxDelta;
            else
                totalYawIncrementInt = lastMoveX - maxDelta;

//_end
        if (totalPitchIncrementInt == 0 && totalYawIncrementInt == 0) return;
        display->moveMouseRelative(totalPitchIncrementInt, totalYawIncrementInt);
//_begin
        lastMoveY = totalPitchIncrementInt;
        lastMoveX = totalYawIncrementInt;

        int weapon = lp->weaponIndex;
        if (weapon != WEAPON_SENTINEL &&
            weapon != WEAPON_BOCEK &&
            weapon != WEAPON_CHARGE_RIFLE &&
            weapon != WEAPON_LONGBOW &&
            weapon != WEAPON_G7 &&
            weapon != WEAPON_HEMLOCK &&
            weapon != WEAPON_KRABER &&
            weapon != WEAPON_MASTIFF &&
            weapon != WEAPON_PROWLER &&
            weapon != WEAPON_PEACEKEEPER &&
            weapon != WEAPON_P2020 &&
            weapon != WEAPON_TRIPLE_TAKE &&
            weapon != WEAPON_WINGMAN &&
            weapon != WEAPON_3030 &&
            weapon != WEAPON_MELEE &&
            weapon != WEAPON_THROWING_KNIFE) {
            if (autoFire && !keymap::AIMBOT_FIRING_KEY && keymap::AIMBOT_ACTIVATION_KEY && abs(TargetBoneW2S.x - ScreenSize.x/2) < width && abs(TargetBoneW2S.y - ScreenSize.y/2) < width) {
                display->kbPress(cl->AIMBOT_FIRING_KEY);
                keymap::AIMBOT_FIRING_KEY = true;
            }
        } else {
            if (weapon == WEAPON_G7 ||
                weapon == WEAPON_HEMLOCK ||
                weapon == WEAPON_MASTIFF ||
                weapon == WEAPON_PROWLER ||
                weapon == WEAPON_PEACEKEEPER ||
                weapon == WEAPON_P2020 ||
                weapon == WEAPON_WINGMAN ||
                weapon == WEAPON_3030)
                if (autoFire && keymap::AIMBOT_ACTIVATION_KEY && abs(TargetBoneW2S.x - ScreenSize.x/2) < width && abs(TargetBoneW2S.y - ScreenSize.y/2) < width) {
                    std::chrono::milliseconds timeNow = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
                    if (timeNow > keymap::timeLastShot + std::chrono::milliseconds(125)) {
                        //display->mouseClickLeft();
                        display->kbPress(cl->AIMBOT_FIRING_KEY);
                        display->kbRelease(cl->AIMBOT_FIRING_KEY);
                        keymap::AIMBOT_FIRING_KEY = false;
                        keymap::timeLastShot = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
                    }
                }
        }
//_end
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
//_        const Vector3D TargetVelocity = Target->AbsoluteVelocity;
        const Vector3D TargetVelocity = Target->velocity; //_add
        const Vector3D CameraPosition = lp->CameraPosition;
        const QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();
        
        if (lp->WeaponProjectileSpeed > 1.0f) {
            if (cl->AIMBOT_PREDICT_BULLETDROP && cl->AIMBOT_PREDICT_MOVEMENT) {
                return Resolver::CalculateAimRotationNew(CameraPosition, TargetPosition, TargetVelocity, lp->WeaponProjectileSpeed, lp->WeaponProjectileScale, 255, Angle);
            }
            else if (cl->AIMBOT_PREDICT_BULLETDROP) {
                return Resolver::CalculateAimRotationNew(CameraPosition, TargetPosition, Vector3D(0.0f, 0.0f, 0.0f), lp->WeaponProjectileSpeed, lp->WeaponProjectileScale, 255, Angle);
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
//_            !target->isValid() ||
            !target->isCombatReady() ||
            !target->visible ||
            !target->enemy ||
            target->distance2DToLocalPlayer < util::metersToInches(cl->AIMBOT_MIN_DISTANCE) ||
            target->distance2DToLocalPlayer > util::metersToInches(FinalDistance))
            return false;
        return true;
    }

    float CalculatePitchIncrement(QAngle AimbotDesiredAngles) {
        float wayA = AimbotDesiredAngles.x - lp->viewAngles.x;
        float wayB = 180.0f - abs(wayA);
        if (wayA > 0.0f && wayB > 0.0f)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }

    float CalculateYawIncrement(QAngle AimbotDesiredAngles) {
        float wayA = AimbotDesiredAngles.y - lp->viewAngles.y;
        float wayB = 360.0f - abs(wayA);
        if (wayA > 0.0f && wayB > 0.0f)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }

//_    double CalculateDistanceFromCrosshair(Player* target) {
    double CalculateDistanceFromCrosshair(Vector3D TargetPos) { //_add
        Vector3D CameraPosition = lp->CameraPosition;
        QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();

//_        Vector3D TargetPos = target->localOrigin;
        if (CameraPosition.Distance(TargetPos) <= 0.0001f)
            return -1;

        QAngle TargetAngle = Resolver::CalculateAngle(CameraPosition, TargetPos);
        if (!TargetAngle.isValid())
            return -1;
        
        return CurrentAngle.distanceTo(TargetAngle);
    }

    Player* FindBestTarget() {
        float NearestDistance = 9999.9f;
        Player* BestTarget = nullptr;
        Vector3D CameraPosition = lp->CameraPosition;
        QAngle CurrentAngle = QAngle(lp->viewAngles.x, lp->viewAngles.y).fixAngle();
        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!IsValidTarget(p)) continue;

//_            double DistanceFromCrosshair = CalculateDistanceFromCrosshair(p);
            double DistanceFromCrosshair = CalculateDistanceFromCrosshair(p->GetBonePosition(Hitbox)); //_add
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
        return (x >= 0.0f)
            ? static_cast<int>(std::round(x))
            : static_cast<int>(std::round(-x)) * -1;
    }

    float AL1AF0(float num) {
        if (num > 0.0f) return std::max(num, 1.0f);
        return std::min(num, -1.0f);
    }
};
