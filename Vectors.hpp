#pragma once
struct Vector2D {
    float x, y;

    Vector2D() : x(0), y(0) {}

    Vector2D(float x_val, float y_val) : x(x_val), y(y_val) {}

    Vector2D Subtract(const Vector2D& other) const {
        return Vector2D(x - other.x, y - other.y);
    }
    Vector2D Add(const Vector2D& other) const {
        return Vector2D(x + other.x, y + other.y);
    }
    Vector2D Divide(const Vector2D& other) const {
        return Vector2D(x / other.x, y / other.y);
    }
    Vector2D Divide(float scalar) const {
        return Vector2D(x / scalar, y / scalar);
    }
    Vector2D Multiply(float scalar) const {
        return Vector2D(x * scalar, y * scalar);
    }
    Vector2D Normalized() const {
        Vector2D result;
        float length = std::sqrt(x * x + y * y);
        if (length != 0) {
            result.x = x / length;
            result.y = y / length;
        }
        return result;
    }
    Vector2D MultipliedByScalar(float scalar) const {
        Vector2D result;
        result.x = x * scalar;
        result.y = y * scalar;
        return result;
    }
    Vector2D Clamp() const {
        float clampedX = x;
        if (clampedX < -89) clampedX = -89;
        if (clampedX > 89) clampedX = 89;
        float clampedY = y;
        if (clampedY < -180) clampedY += 360;
        if (clampedY > 180) clampedY -= 360;
        if (clampedX > 89 || clampedX < -89) throw std::invalid_argument("BAD PITCH CLAMPING. CHECK YOUR CODE");
        if (clampedY > 180 || clampedY < -180) throw std::invalid_argument("BAD YAW CLAMPING. CHECK YOUR CODE");
        return Vector2D(clampedX, clampedY);
    }
    float DotProduct(const Vector2D& other) const {
        return x * other.x + y * other.y;
    }
    float Magnitude() const {
        return std::sqrt(x * x + y * y);
    }
    float Distance(const Vector2D& other) const {
        Vector2D diff = Subtract(other);
        return diff.Magnitude();
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

    Vector3D Subtract(const Vector3D& other) const {
        return Vector3D(x - other.x, y - other.y, z - other.z);
    }
    Vector3D Add(const Vector3D& other) const {
        return Vector3D(x + other.x, y + other.y, z + other.z);
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
    Vector3D Multiply(float scalar) const {
        return Vector3D(x * scalar, y * scalar, z * scalar);
    }
    Vector2D To2D() const {
        return Vector2D(x, y);
    }
    Vector3D& operator+=(const Vector3D& other) {
        x += other.x;
        y += other.y;
        z += other.z;
        return *this;
    }
    float DotProduct(const Vector3D& other) const {
        return x * other.x + y * other.y + z * other.z;
    }
    float Magnitude() const {
        return std::sqrt(x * x + y * y + z * z);
    }
    float Magnitude2D() const {
        return std::sqrt(x * x + y * y);
    }
    float Distance(const Vector3D& other) const {
        Vector3D diff = Subtract(other);
        return diff.Magnitude();
    }
    float Distance2D(const Vector3D& other) const {
        return (other.Subtract(*this)).Magnitude2D();
    };
    bool IsZeroVector() {
        return x == 0 && y == 0 && z == 0;
    }
    bool IsValid() {
        if(std::isnan(x) || std::isinf(x) || std::isnan(y) || std::isinf(y) || std::isnan(z) || std::isinf(z)) {
            return false;
        }
        return true;
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
