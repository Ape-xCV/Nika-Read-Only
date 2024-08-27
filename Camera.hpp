#pragma once

struct Camera {
    Vector2D screenSize;
    ViewMatrix gameViewMatrix;

    void Initialize(int width, int height) {
        screenSize = Vector2D(width, height);
    }

    const Vector2D& GetResolution() {
        return screenSize;
    }

    void Update() {
        long renderPtr = mem::Read<long>(OFF_REGION + OFF_VIEW_RENDER, "Camera renderPtr");
        long matrixPtr = mem::Read<long>(renderPtr + OFF_VIEW_MATRIX, "Camera matrixPtr");
        gameViewMatrix = mem::Read<ViewMatrix>(matrixPtr, "Camera gameViewMatrix");
    }

    bool WorldToScreen(Vector3D worldPosition, Vector2D& screenPosition) const {
        Vector3D transformed = gameViewMatrix.Transform(worldPosition);

        if (transformed.z < 0.001f) {
            return false;
        }

        transformed.x *= 1.0f / transformed.z;
        transformed.y *= 1.0f / transformed.z;

        screenPosition = Vector2D(screenSize.x / 2.0f + transformed.x * (screenSize.x / 2.0f), screenSize.y / 2.0f - transformed.y * (screenSize.y / 2.0f));

        return true;
    }
};
