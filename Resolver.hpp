#pragma once

struct Resolver {
    static QAngle CalculateAngle(Vector3D from, Vector3D to) {
        Vector3D newDirection = to.Subtract(from);
        newDirection.Normalize();
        
        float pitch = -asinf(newDirection.z) * (180 / M_PI);
        float yaw = atan2f(newDirection.y, newDirection.x) * (180 / M_PI);

        return QAngle(pitch, yaw);
    }

    static Vector3D GetTargetPosition(const Vector3D& targetPosition, Vector3D targetVelocity, float time) {
        return targetPosition.Subtract((targetVelocity.Multiply(time)));
    }

    static float GetTimeToTarget(Vector3D startPosition, Vector3D endPosition, float bulletSpeed) {
        float distance = (endPosition.Subtract(startPosition)).Magnitude();
        return distance / bulletSpeed;
    }

    static float GetBasicBulletDrop(Vector3D startPosition, Vector3D endPosition, float bulletSpeed, float bulletDropRate) {
        float time = GetTimeToTarget(startPosition, endPosition, bulletSpeed);
        bulletDropRate *= 750.0f;
        return 0.5f * bulletDropRate * time * time;
    }

    static Vector3D GetTargetPosition(Vector3D startPosition, Vector3D endPosition, Vector3D targetVelocity, float bulletSpeed) {
        float time = GetTimeToTarget(startPosition, endPosition, bulletSpeed);
        return GetTargetPosition(endPosition, targetVelocity, bulletSpeed);
    }

    // Aim at moving target without bullet drop predicion
    static bool CalculateAimRotation(Vector3D startPosition, Vector3D endPosition, Vector3D targetVelocity, float bulletSpeed, QAngle& result) {
        endPosition = GetTargetPosition(startPosition, endPosition, targetVelocity, bulletSpeed);
        result = CalculateAngle(startPosition, endPosition);
        return true;
    }

    // Aim at moving target without movement prediction
    static void CalculateAimRotationBasicDrop(Vector3D startPosition, Vector3D endPosition, Vector3D targetVelocity, float bulletSpeed, float bulletScale, QAngle& result) {
        endPosition.z += GetBasicBulletDrop(startPosition, endPosition, bulletSpeed, bulletScale);
        result = CalculateAngle(startPosition, endPosition);
    }

    static bool CalculateAimRotationNew(Vector3D start, Vector3D targetPosition, Vector3D targetVelocity, float bulletSpeed, float bulletScale, int steps, QAngle& result) {
        const float gravity = 750.0f / bulletScale;

        float angle = 0;
        float time = 0.0;
        float timeStep = 1.0f / steps;

        for(int i = 0; i < steps; i++) {
            Vector3D predictedPosition = GetTargetPosition(targetPosition, targetVelocity, time);
            if (!OptimalAngle(start, predictedPosition, bulletSpeed, gravity, angle))
                continue;
            
            Vector3D direction = predictedPosition.Subtract(start);
            float horizontalDistance = direction.Magnitude2D();
            float travelTime = horizontalDistance / (bulletSpeed * cosf(angle));

            if(travelTime <= time){
                result.x = -angle  * (180 / M_PI);
                result.y = atan2f(direction.y, direction.x)  * (180 / M_PI);
                return true;
            }
            time += timeStep;
        }

        targetPosition = GetTargetPosition(start, targetPosition, targetVelocity, bulletSpeed);
        result = CalculateAngle(start, targetPosition);
        return true;
    }

    static float GetTimeToTarget(const Vector3D start, const Vector3D end, const float speed, const float gravity) {
        float horizontalDistance = start.Distance2D(end);
        float heightDifference = end.z - start.z;
        return (speed * sqrtf(2 * sinf(M_PI / 4) / gravity)) + (sqrtf(2 * sinf(M_PI / 4) * (sinf(M_PI / 4) - 2 * heightDifference) / gravity));
    }

    static bool OptimalAngle(const Vector3D start, const Vector3D end, const float speed, const float gravity, float& angle) {
        float horizontalDistance = start.Distance2D(end);
        float heightDifference = end.z - start.z;
        
        float root = powf(speed, 4) - gravity * (gravity * powf(horizontalDistance, 2) + 2 * heightDifference * powf(speed, 2));
        if (root < 0.0)
            return false;

        float term1 = powf(speed, 2) - sqrt(root);
        float term2 = gravity * horizontalDistance;

        angle = atanf(term1 / term2);
        return true;
    }
};
