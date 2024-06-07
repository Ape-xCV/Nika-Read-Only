#pragma once
#include "../Memory.hpp"
#include "../Offsets.hpp"

struct Camera {
    Vector2D ScreenSize;
    ViewMatrix GameViewMatrix;

    void Initialize(int Width, int Height) {
        ScreenSize = Vector2D(Width, Height);
    }

    const Vector2D& GetResolution() {
        return ScreenSize;
    }

    void Update() {
        long RenderPtr = mem::Read<long>(OFF_REGION + OFF_VIEWRENDER, "RenderPtr");
        long MatrixPtr = mem::Read<long>(RenderPtr + OFF_VIEWMATRIX, "MatrixPtr");
        GameViewMatrix = mem::Read<ViewMatrix>(MatrixPtr, "GameViewMatrix");
    }

    bool WorldToScreen(Vector3D WorldPosition, Vector2D& ScreenPosition) const {
        Vector3D transformed = GameViewMatrix.Transform(WorldPosition);

        if (transformed.z < 0.001) {
            return false;
        }

        transformed.x *= 1.0 / transformed.z;
        transformed.y *= 1.0 / transformed.z;

        ScreenPosition = Vector2D(ScreenSize.x / 2.0f + transformed.x * (ScreenSize.x / 2.0f), ScreenSize.y / 2.0f - transformed.y * (ScreenSize.y / 2.0f));

        return true;
    }
};
