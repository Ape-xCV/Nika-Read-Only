#pragma once

struct Resolver {
    static float GetBulletDrop(Vector3D localPosition, Vector3D targetPosition, float bulletSpeed, float bulletGravity) {
        float time = GetTimeToTarget(localPosition, targetPosition, bulletSpeed);
        //bulletGravity *= 750.0f;
        bulletGravity *= 700.0f;
        return 0.5f * bulletGravity * time * time; // d = 1/2(at^2)+vt
    }

    static float GetTimeToTarget(Vector3D localPosition, Vector3D targetPosition, float bulletSpeed) {
        float distance = (targetPosition.Subtract(localPosition)).Magnitude();
        return distance / bulletSpeed;
    }

    static Vector3D GetTargetPosition(Vector3D& targetPosition, Vector3D targetVelocity, float time) {
        return targetPosition.Add((targetVelocity.Multiply(time + 0.2f)));
    }

    static Vector3D GetTargetPosition(Vector3D localPosition, Vector3D targetPosition, Vector3D targetVelocity, float bulletSpeed) {
        float time = GetTimeToTarget(localPosition, targetPosition, bulletSpeed);
        return GetTargetPosition(targetPosition, targetVelocity, time);
    }

    static Vector2D CalculateAngles(Vector3D from, Vector3D to) {
        Vector3D newDirection = to.Subtract(from);
        newDirection.Normalize();

        float yaw = atan2f(newDirection.y, newDirection.x) * (180.0f / M_PI);
        float pitch = -asinf(newDirection.z) * (180.0f / M_PI);

        return Vector2D(pitch, yaw);
    }
};
