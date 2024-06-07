#pragma once

struct QAngle {

    float x;
    float y;

    QAngle() : x(0), y(0) {}

    QAngle(float x, float y) : x(x), y(y) {}

    float distanceTo(const QAngle& other) const {
        return (other - *this).length();
    };
    inline QAngle operator+(const QAngle& other) const {
        return QAngle(x + other.x, y + other.y);
    }
    inline QAngle operator-(const QAngle& other) const {
        return QAngle(x - other.x, y - other.y);
    }
    inline QAngle operator*(const float scalar) const {
        return QAngle(x * scalar, y * scalar);
    }
    inline QAngle operator/(const float scalar) const {
        return QAngle(x / scalar, y / scalar);
    }
    inline QAngle& operator+=(const QAngle& other) {
        x += other.x;
        y += other.y;
        return *this;
    }
    inline QAngle& operator-=(const QAngle& other) {
        x -= other.x;
        y -= other.y;
        return *this;
    }
    inline QAngle& operator*=(const float scalar) {
        x *= scalar;
        y *= scalar;
        return *this;
    }
    inline QAngle& operator/=(const float scalar) {
        x /= scalar;
        y /= scalar;
        return *this;
    }
    inline bool operator==(const QAngle& other) const
    {
        return x == other.x && y == other.y;
    }
    inline bool operator!=(const QAngle& other) const
    {
        return !(*this == other);
    }
    inline float dot(const QAngle& other) const {
        return x * other.x + y * other.y;
    }
    inline float length() const {
        return std::sqrt(x * x + y * y);
    }
    inline QAngle& normalize() {
        float len = length();
        if (len > 0) {
            x /= len;
            y /= len;
        }
        return *this;
    }
    inline QAngle& clamp(float minVal, float maxVal) {
        x = std::clamp(x, minVal, maxVal);
        y = std::clamp(y, minVal, maxVal);

        return *this;
    }
    inline QAngle lerp(const QAngle& other, float t) const {
        return (*this) * (1.0f - t) + other * t;
    }
    inline QAngle& fixAngle() {
        if(!isValid()) {
            return *this;
        }

        while (x > 89.0f)
            x -= 180.f;

        while (x < -89.0f)
            x += 180.f;

        while (y > 180.f)
            y -= 360.f;

        while (y < -180.f)
            y += 360.f;

        return *this;
    }
    inline bool isValid() const {
        if(std::isnan(x) || std::isinf(x) || std::isnan(y) || std::isinf(y)) {
            return false;
        }
        
        return true;
    }
    inline static QAngle zero() {
        return QAngle(0, 0);
    }
};