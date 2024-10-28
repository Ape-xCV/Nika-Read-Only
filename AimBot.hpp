#pragma once

struct AimBot {
    ConfigLoader* cl;
    XDisplay* myDisplay;
    LocalPlayer* lp;
    std::vector<Player*>* players;
	Camera* gameCamera;
    Player* currentTarget = nullptr;
    bool targetSelected = false;
    float finalDistance = 0;
    HitboxType hitbox = HitboxType::Neck;
    float finalFov = 0;
    Vector3D targetBone3DCache;
    int lastMoveX = 0;
    int lastMoveY = 0;

    AimBot(ConfigLoader* in_cl, XDisplay* in_myDisplay, LocalPlayer* in_lp, std::vector<Player*>* in_players, Camera* in_gameCamera) {
        this->cl = in_cl;
        this->myDisplay = in_myDisplay;
        this->lp = in_lp;
        this->players = in_players;
        this->gameCamera = in_gameCamera;
    }

    bool active(bool rightLock) {
        bool isAimbotOn = cl->FEATURE_AIMBOT_ON;
        bool isCombatReady = lp->isCombatReady();
        bool activatedByAds = cl->AIMBOT_ACTIVATED_BY_ADS && rightLock && lp->inZoom;
        bool activatedByKey = keymap::AIMBOT_ACTIVATION_KEY;
        bool active = isAimbotOn && isCombatReady && (activatedByAds || activatedByKey);
        return active;
    }

    void releaseTarget() {
        currentTarget = nullptr;
        targetSelected = false;
    }

    bool isValidTarget(Player* target) {
        if (target == nullptr
            || !target->isCombatReady()
            || !target->isVisible
            || !target->isEnemy
            || target->distance2DToLocalPlayer > util::metersToInches(finalDistance)
            || target->distance2DToLocalPlayer < util::metersToInches(cl->AIMBOT_MIN_DISTANCE))
            return false;
        return true;
    }

    Player* findBestTarget() {
        float nearestDistance = 9999.9f;
        Player* bestTarget = nullptr;
        Vector3D cameraPosition = lp->cameraPosition;
        Vector2D currentAngles = Vector2D(lp->viewAngles.x, lp->viewAngles.y).NormalizeAngles();
        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!isValidTarget(p)) continue;

            double distanceFromCrosshair;
            if (p->isDrone)
                distanceFromCrosshair = calculateDistanceFromCrosshair(p->getBonePosition(HitboxType::Head));
            else
                distanceFromCrosshair = calculateDistanceFromCrosshair(p->getBonePosition(hitbox));
            if (distanceFromCrosshair > finalFov || distanceFromCrosshair == -1)
                continue;

            if (distanceFromCrosshair < nearestDistance) {
                bestTarget = p;
                nearestDistance = distanceFromCrosshair;
            }
        }
        return bestTarget;
    }

    double calculateDistanceFromCrosshair(Vector3D targetPosition) {
        Vector3D cameraPosition = lp->cameraPosition;
        Vector2D currentAngles = Vector2D(lp->viewAngles.x, lp->viewAngles.y).NormalizeAngles();

        if (cameraPosition.Distance(targetPosition) <= 0.001f)
            return -1;

        Vector2D targetAngles = Resolver::CalculateAngles(cameraPosition, targetPosition);
        if (!targetAngles.IsValid())
            return -1;
        
        return currentAngles.Distance(targetAngles);
    }

    void getAnglesToTarget(Player* target, Vector3D targetPosition, Vector2D& angles, float timeOffset) {
        if (cl->AIMBOT_PREDICT_BULLETDROP && lp->weaponProjectileSpeed > 999.9f)
            if (lp->weaponProjectileScale >= 0.5f && lp->weaponProjectileScale <= 1.6f)
                targetPosition.z += Resolver::GetBulletDrop(lp->cameraPosition, targetPosition, lp->weaponProjectileSpeed, lp->weaponProjectileScale);
            else
                targetPosition.z += Resolver::GetBulletDrop(lp->cameraPosition, targetPosition, lp->weaponProjectileSpeed, 1.0f);
        if (cl->AIMBOT_PREDICT_MOVEMENT && lp->weaponProjectileSpeed > 999.9f)
            targetPosition = Resolver::GetTargetPosition(lp->cameraPosition, targetPosition, target->absoluteVelocity, lp->weaponProjectileSpeed, timeOffset);

        angles = Resolver::CalculateAngles(lp->cameraPosition, targetPosition);
    }

    bool getAngles(Player* target, Vector3D targetPosition, Vector2D& angles, float timeOffset) {
        Vector2D currentAngles = Vector2D(lp->viewAngles.x, lp->viewAngles.y).NormalizeAngles();
        if (!currentAngles.IsValid())
            return false;

        getAnglesToTarget(target, targetPosition, angles, timeOffset);
        return true;
    }

    float calculateYawIncrement(Vector2D aimbotDesiredAngles) {
        float wayA = aimbotDesiredAngles.y - lp->viewAngles.y;
        float wayB = 360.0f - abs(wayA);
        if (wayA > 0.0f && wayB > 0.0f)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }

    float calculatePitchIncrement(Vector2D aimbotDesiredAngles) {
        float wayA = aimbotDesiredAngles.x - lp->viewAngles.x;
        float wayB = 180.0f - abs(wayA);
        if (wayA > 0.0f && wayB > 0.0f)
            wayB *= -1;
        if (fabs(wayA) < fabs(wayB))
            return wayA;
        return wayB;
    }

    void update(bool leftLock, bool rightLock, int autoFire, int boneId, int totalSpectators) {
        if (keymap::AIMBOT_FIRING_KEY && (!keymap::AIMBOT_ACTIVATION_KEY || currentTarget != nullptr && !currentTarget->isVisible)) {
            myDisplay->kbRelease(cl->AIMBOT_FIRING_KEY);
            keymap::AIMBOT_FIRING_KEY = false;
        }

        if (lp->grippingGrenade){ releaseTarget(); return; }
        if (!active(rightLock)) { releaseTarget(); return; }

        if (lp->inZoom) {
            finalFov = cl->AIMBOT_FOV * lp->zoomFov / 60;
            finalFov += finalFov * (60/lp->zoomFov - 1) * cl->AIMBOT_FOV_EXTRA_BY_ZOOM;
            finalDistance = cl->AIMBOT_MAX_DISTANCE;
        } else {
            finalFov = (cl->AIMBOT_FOV + 20);
            finalDistance = cl->TRIGGERBOT_HIPFIRE_RANGE;
        }

        Player* target = currentTarget;
        if (!isValidTarget(target)) {
//            if(targetSelected && !cl->AIMBOT_ALLOW_TARGET_SWITCH)
//                return;

            target = findBestTarget();
            if (!isValidTarget(target)) {
                currentTarget = nullptr;
                return;
            }
            currentTarget = target;
            targetSelected = true;
        }

        if (boneId == 0 || currentTarget->isDrone) hitbox = HitboxType::Head;
        else if (boneId == 1) hitbox = HitboxType::Neck;
        else hitbox = HitboxType::UpperChest;
        targetBone3DCache = currentTarget->getBonePosition(hitbox);
        double distanceFromCrosshair = calculateDistanceFromCrosshair(targetBone3DCache);
        if (distanceFromCrosshair == -1) {
            releaseTarget();
            return;
        }

        int zoomedMaxMove = cl->AIMBOT_ZOOMED_MAX_MOVE;
        int hipfireMaxMove = cl->AIMBOT_HIPFIRE_MAX_MOVE;
        int maxDelta = cl->AIMBOT_MAX_DELTA;
        if (distanceFromCrosshair < finalFov * cl->AIMBOT_FAST_AREA) {
            zoomedMaxMove *= cl->AIMBOT_FAST_AREA;
            hipfireMaxMove *= cl->AIMBOT_FAST_AREA;
            maxDelta /= cl->AIMBOT_WEAKEN;
        } else if (distanceFromCrosshair < finalFov * cl->AIMBOT_SLOW_AREA) {
            zoomedMaxMove *= cl->AIMBOT_SLOW_AREA;
            hipfireMaxMove *= cl->AIMBOT_SLOW_AREA;
            maxDelta /= cl->AIMBOT_WEAKEN;
        }

        Vector2D desiredAngles = Vector2D(0.0f, 0.0f);
        float timeOffset = 0.075f * (1 + !leftLock * (cl->AIMBOT_WEAKEN - 1) / 2);
        if (!getAngles(currentTarget, targetBone3DCache, desiredAngles, timeOffset))
            return;

        Vector2D desiredAnglesIncrement = Vector2D(calculatePitchIncrement(desiredAngles), calculateYawIncrement(desiredAngles));

        float totalSmooth;
        if (cl->AIMBOT_LEGACY_MODE)
            totalSmooth = cl->AIMBOT_SMOOTH / 10 + cl->AIMBOT_SMOOTH_EXTRA_BY_DISTANCE / currentTarget->distanceToLocalPlayer;
        else
            totalSmooth = cl->AIMBOT_SMOOTH * 10;
        float bulletSpeed = lp->weaponProjectileSpeed;
        if (!lp->inZoom)
            totalSmooth *= cl->AIMBOT_WEAKEN;
        else
            if (!currentTarget->isDrone && (!leftLock || cl->AIMBOT_SPECTATORS_WEAKEN && totalSpectators > 0))
                totalSmooth *= (cl->AIMBOT_WEAKEN + 1) / 2;

        Vector2D aimbotDelta = desiredAnglesIncrement.Multiply(cl->AIMBOT_SPEED).Divide(totalSmooth);
        double aimYawIncrement = -aimbotDelta.y;
        double aimPitchIncrement = aimbotDelta.x;

        int totalYawIncrementInt = std::round(aimYawIncrement);
        int totalPitchIncrementInt = std::round(aimPitchIncrement);

        Vector2D localOriginW2S, headPositionW2S;
        Vector3D localOrigin3D = currentTarget->localOrigin;
        Vector3D headPosition3D = currentTarget->getBonePosition(HitboxType::Head);
        bool isLocalOriginW2SValid = gameCamera->worldToScreen(localOrigin3D, localOriginW2S);
        bool isHeadPositionW2SValid = gameCamera->worldToScreen(headPosition3D, headPositionW2S);
        float width = (localOriginW2S.y - headPositionW2S.y) / 2;
        width += width * util::inchesToMeters(currentTarget->distance2DToLocalPlayer) / 100;
        Vector2D targetBoneW2S;
        Vector3D targetBone3D = targetBone3DCache;
        Vector2D screenSize = gameCamera->getResolution();
        if (!cl->AIMBOT_LEGACY_MODE) {
            if (cl->AIMBOT_PREDICT_BULLETDROP && lp->weaponProjectileSpeed > 999.9f)
                if (lp->weaponProjectileScale >= 0.5f && lp->weaponProjectileScale <= 1.6f)
                    targetBone3D.z += Resolver::GetBulletDrop(lp->cameraPosition, targetBone3D, lp->weaponProjectileSpeed, lp->weaponProjectileScale);
                else
                    targetBone3D.z += Resolver::GetBulletDrop(lp->cameraPosition, targetBone3D, lp->weaponProjectileSpeed, 1.0f);
            if (cl->AIMBOT_PREDICT_MOVEMENT && lp->weaponProjectileSpeed > 999.9f)
                targetBone3D = Resolver::GetTargetPosition(lp->cameraPosition, targetBone3D, currentTarget->absoluteVelocity, bulletSpeed, timeOffset);
            gameCamera->worldToScreen(targetBone3D, targetBoneW2S);
            totalPitchIncrementInt = std::round((targetBoneW2S.y - screenSize.y/2) * cl->AIMBOT_SPEED / totalSmooth);
            totalYawIncrementInt = std::round((targetBoneW2S.x - screenSize.x/2) * cl->AIMBOT_SPEED / totalSmooth);
        }
        zoomedMaxMove *= util::randomFloat(1.0f, 1.5f);
        hipfireMaxMove *= util::randomFloat(1.0f, 1.5f);

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

        myDisplay->moveMouseRelative(totalYawIncrementInt, totalPitchIncrementInt);
        lastMoveY = totalPitchIncrementInt;
        lastMoveX = totalYawIncrementInt;

        gameCamera->worldToScreen(targetBone3DCache, targetBoneW2S);
        int weapon = lp->weaponId;
        if (myDisplay->isLeftMouseButtonDown() && (
            lp->ultimateId == 4 ||
            weapon == WEAPON_SENTINEL ||
            weapon == WEAPON_LONGBOW ||
            weapon == WEAPON_KRABER ||
            weapon == WEAPON_TRIPLE_TAKE ||
            weapon == WEAPON_MELEE) ||
            lp->ultimateId != 4 &&
            weapon != WEAPON_SENTINEL &&
            weapon != WEAPON_LONGBOW &&
            (autoFire != 2 || weapon != WEAPON_EVA8) &&
            weapon != WEAPON_G7 &&
            weapon != WEAPON_HEMLOCK &&
            weapon != WEAPON_KRABER &&
            weapon != WEAPON_MASTIFF &&
            (autoFire != 2 || weapon != WEAPON_MOZAMBIQUE) &&
            weapon != WEAPON_PROWLER &&
            weapon != WEAPON_PEACEKEEPER &&
            //weapon != WEAPON_P2020 &&
            weapon != WEAPON_TRIPLE_TAKE &&
            weapon != WEAPON_WINGMAN &&
            weapon != WEAPON_3030 &&
            weapon != WEAPON_NEMESIS &&
            weapon != WEAPON_MELEE) {
            if (autoFire > 0 && !keymap::AIMBOT_FIRING_KEY && keymap::AIMBOT_ACTIVATION_KEY &&
                abs(targetBoneW2S.x - screenSize.x/2) < width &&
                abs(targetBoneW2S.y - screenSize.y/2) < width) {
                myDisplay->kbPress(cl->AIMBOT_FIRING_KEY);
                keymap::AIMBOT_FIRING_KEY = true;
            }
        } else {
            if (lp->ultimateId == 255 && (
                weapon == WEAPON_G7 ||
                weapon == WEAPON_HEMLOCK ||
                weapon == WEAPON_PROWLER ||
                //weapon == WEAPON_P2020 ||
                weapon == WEAPON_3030 ||
                weapon == WEAPON_NEMESIS))
                if (autoFire && keymap::AIMBOT_ACTIVATION_KEY &&
                    abs(targetBoneW2S.x - screenSize.x/2) < width &&
                    abs(targetBoneW2S.y - screenSize.y/2) < width) {
                    std::chrono::milliseconds timeNow = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
                    if (timeNow > keymap::timeLastShot + std::chrono::milliseconds(125)) {
                        //myDisplay->mouseClickLeft();
                        myDisplay->kbPress(cl->AIMBOT_FIRING_KEY);
                        myDisplay->kbRelease(cl->AIMBOT_FIRING_KEY);
                        keymap::AIMBOT_FIRING_KEY = false;
                        keymap::timeLastShot = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
                    }
                }
            if (!myDisplay->isLeftMouseButtonDown() && keymap::AIMBOT_FIRING_KEY) {
                myDisplay->kbRelease(cl->AIMBOT_FIRING_KEY);
                keymap::AIMBOT_FIRING_KEY = false;
            }
        }
    }
};
