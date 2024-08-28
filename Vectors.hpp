#pragma once

struct Vector2D {
    float x, y;

    Vector2D() : x(0), y(0) {}

    Vector2D(float x_val, float y_val) : x(x_val), y(y_val) {}

    Vector2D Add(const Vector2D& other) const {
        return Vector2D(x + other.x, y + other.y);
    }
    Vector2D Subtract(const Vector2D& other) const {
        return Vector2D(x - other.x, y - other.y);
    }
    Vector2D Multiply(float scalar) const {
        return Vector2D(x * scalar, y * scalar);
    }
    Vector2D Divide(float scalar) const {
        return Vector2D(x / scalar, y / scalar);
    }
    float Magnitude() const {
        return std::sqrt(x * x + y * y);
    }
    Vector2D& Normalize() {
        float len = Magnitude();
        if (len > 0) {
            x /= len;
            y /= len;
        }
        return *this;
    }
    float Distance(const Vector2D& other) const {
        Vector2D diff = Subtract(other);
        return diff.Magnitude();
    }
    bool IsValid() {
        if (std::isnan(x) || std::isinf(x) || std::isnan(y) || std::isinf(y)) {
            return false;
        }
        return true;
    }
    Vector2D& NormalizeAngles() {
        if(!IsValid()) {
            return *this;
        }
        while (x > 90.0f)
            x -= 180.f;
        while (x < -90.0f)
            x += 180.f;
        while (y > 180.f)
            y -= 360.f;
        while (y < -180.f)
            y += 360.f;
        return *this;
    }
    bool IsZeroVector() {
        return x == 0 && y == 0;
    }
    bool operator==(const Vector2D& other) const {
        float epsilon = 1e-5;
        return (std::abs(x - other.x) < epsilon)
            && (std::abs(y - other.y) < epsilon);
    }
    bool operator!=(const Vector2D& other) const {
        return !(*this == other);
    }
};

struct Vector3D {
    float x, y, z;

    Vector3D() : x(0), y(0), z(0) {}

    Vector3D(float x_val, float y_val, float z_val) : x(x_val), y(y_val), z(z_val) {}

    Vector3D Add(const Vector3D& other) const {
        return Vector3D(x + other.x, y + other.y, z + other.z);
    }
    Vector3D Subtract(const Vector3D& other) const {
        return Vector3D(x - other.x, y - other.y, z - other.z);
    }
    Vector3D Multiply(float scalar) const {
        return Vector3D(x * scalar, y * scalar, z * scalar);
    }
    Vector3D Divide(float scalar) const {
        return Vector3D(x / scalar, y / scalar, z / scalar);
    }
    float Magnitude() const {
        return std::sqrt(x * x + y * y + z * z);
    }
    Vector3D& Normalize() {
        float len = Magnitude();
        if (len > 0) {
            x /= len;
            y /= len;
            z /= len;
        }
        return *this;
    }
    float Distance(const Vector3D& other) const {
        Vector3D diff = Subtract(other);
        return diff.Magnitude();
    }
    float Magnitude2D() const {
        return std::sqrt(x * x + y * y);
    }
    float Distance2D(const Vector3D& other) const {
        return (other.Subtract(*this)).Magnitude2D();
    }
    Vector2D To2D() const {
        return Vector2D(x, y);
    }
    bool IsValid() {
        if (std::isnan(x) || std::isinf(x) || std::isnan(y) || std::isinf(y) || std::isnan(z) || std::isinf(z)) {
            return false;
        }
        return true;
    }
    bool IsZeroVector() {
        return x == 0 && y == 0 && z == 0;
    }
    bool operator==(const Vector3D& other) const {
        float epsilon = 1e-5;
        return (std::abs(x - other.x) < epsilon)
            && (std::abs(y - other.y) < epsilon)
            && (std::abs(z - other.z) < epsilon);
    }
    bool operator!=(const Vector3D& other) const {
        return !(*this == other);
    }
};

struct Matrix3x4 {
    float matrix[3][4];
    Vector3D GetPosition() const {
        return Vector3D(matrix[0][3], matrix[1][3], matrix[2][3]);
    }
};

struct ViewMatrix {
    float matrix[4][4];
    Vector3D Transform(const Vector3D vector) const {
        Vector3D transformed;
        transformed.x = vector.y * matrix[0][1] + vector.x * matrix[0][0] + vector.z * matrix[0][2] + matrix[0][3];
        transformed.y = vector.y * matrix[1][1] + vector.x * matrix[1][0] + vector.z * matrix[1][2] + matrix[1][3];
        transformed.z = vector.y * matrix[3][1] + vector.x * matrix[3][0] + vector.z * matrix[3][2] + matrix[3][3];
        return transformed;
    }
};
