#include <sstream> // for std::stringstream
#pragma once

struct Color {
    float red;
    float green;
    float blue;

    bool operator==(const Color& other) const {
        return (red == other.red) && (green == other.green) && (blue == other.blue);
    }

    bool operator!=(const Color& other) const {
        return !(*this == other);
    }
};

namespace keymap { //_add
    bool AIMBOT_ACTIVATION_KEY; //_add
    bool AIMBOT_FIRING_KEY; //_add
    static std::chrono::milliseconds timeLastShot; //_add
}; //_add

namespace level {
    bool isMixtape;
};

struct Level {
    std::string name;
    bool isLobby; //_add
    bool isPlayable;
    bool isTrainingArea;
    char gameMode[64] = {0};
    std::unordered_map<std::string, bool> gameModes = {{"control", true}, {"freedm", true}};
    bool isMixtape;

    void readFromMemory() {
        name = mem::ReadString(OFF_REGION + OFF_LEVEL, 1024, "Level name");
        isLobby = name == "mp_lobby"; //_add
        isPlayable = !name.empty() && name != "mp_lobby";
        isTrainingArea = name == "mp_rr_canyonlands_staging_mu1";
        uint64_t gameModePtr = mem::Read<uint64_t>(OFF_REGION + OFF_GAMEMODE + 0x50, "gameModePtr");
        if (gameModePtr > 0) {
            mem::Read(gameModePtr, &gameMode, sizeof(gameMode));
            isMixtape=gameModes[gameMode];
            level::isMixtape = isMixtape;
        }
    }
};

namespace util {
    long long currentEpochMillis() {
        auto currentTime = std::chrono::system_clock::now();
        auto duration = currentTime.time_since_epoch();
        return std::chrono::duration_cast<std::chrono::milliseconds>(duration).count();
    }

    float inchesToMeters(float inches) {
        return inches / 39.37007874;
    }

    float metersToInches(float meters) {
        return 39.37007874 * meters;
    }

    float randomFloat(float min, float max) {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<float> dis(min, max);
        return dis(gen);
    }

    template <typename T>
    std::string convertNumberToString(const T a_value)
    {
        std::ostringstream out;
        out.precision(6);
        out << std::fixed << a_value;
        return out.str();
    }
    // trim from start (in place)
    static inline void ltrim(std::string &s)
    {
        s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch)
                                        { return !std::isspace(ch); }));
    }

    // trim from end (in place)
    static inline void rtrim(std::string &s)
    {
        s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch)
                             { return !std::isspace(ch); })
                    .base(),
                s.end());
    }

    // trim from both ends (in place)
    static inline void trim(std::string &s)
    {
        ltrim(s);
        rtrim(s);
    }

    std::vector<std::string> static inline split(std::string s)
    {
        std::stringstream ss(s);
        std::istream_iterator<std::string> begin(ss);
        std::istream_iterator<std::string> end;
        std::vector<std::string> tokens(begin, end);
        return tokens;
    }
    bool toBool(std::string str)
    {
        std::transform(str.begin(), str.end(), str.begin(), ::tolower);
        std::istringstream is(str);
        bool b;
        is >> std::boolalpha >> b;
        return b;
    }
    void clearScreen() {
        printf("\e[H\e[2J\e[3J");
    }
};

enum class HitboxType {
    Head = 0,
    Neck = 1,
    UpperChest = 2,
    LowerChest = 3,
    Stomach = 4,
    Hip = 5,
    LeftShoulder = 6,
    LeftElbow = 7,
    LeftHand = 8,
    RightShoulder = 9,
    RightElbow = 10,
    RightHand = 11,
    LeftThighs = 12,
    LeftKnees = 13,
    LeftLeg = 18,
    RightThighs = 16,
    RightKnees = 17,
    RightLeg = 14
};

struct Matrix3x4 {
public:
	float matrix[3][4];

	Vector3D GetPosition() const {
		return Vector3D(matrix[0][3], matrix[1][3], matrix[2][3]);
	}

	Vector3D GetPosition2() const {
		return Vector3D(matrix[0][3], matrix[1][3], matrix[2][3]);
	}
};

struct ViewMatrix {
public:
	float matrix[4][4];

	Vector3D Transform(const Vector3D vector) const {
		Vector3D transformed;

		transformed.x = vector.y * matrix[0][1] + vector.x * matrix[0][0] + vector.z * matrix[0][2] + matrix[0][3];
	    transformed.y = vector.y * matrix[1][1] + vector.x * matrix[1][0] + vector.z * matrix[1][2] + matrix[1][3];
	    transformed.z = vector.y * matrix[3][1] + vector.x * matrix[3][0] + vector.z * matrix[3][2] + matrix[3][3];

		return transformed;
	}
};

struct GlowMode {
    std::byte bodyStyle, borderStyle, borderWidth, transparency;

    GlowMode() {}

    GlowMode(int bodyStyle_val, int borderStyle_val, int borderWidth_val, int transparency_val) :
        bodyStyle(static_cast<std::byte>(bodyStyle_val)),
        borderStyle(static_cast<std::byte>(borderStyle_val)),
        borderWidth(static_cast<std::byte>(borderWidth_val)),
        transparency(static_cast<std::byte>(transparency_val)) {}


    GlowMode(std::byte bodyStyle_val, std::byte borderStyle_val, std::byte borderWidth_val, std::byte transparency_val) :
        bodyStyle(bodyStyle_val),
        borderStyle(borderStyle_val),
        borderWidth(borderWidth_val),
        transparency(transparency_val) {}

    bool isZeroVector() const {
        return bodyStyle == std::byte(0)
            && borderStyle == std::byte(0)
            && borderWidth == std::byte(0)
            && borderWidth == std::byte(0);
    }

    void print() const {
        std::cout
            << "bodyStyle:" << static_cast<int>(bodyStyle)
            << " borderStyle:" << static_cast<int>(borderStyle)
            << " borderWidth:" << static_cast<int>(borderWidth)
            << " transparency:" << static_cast<int>(transparency)
            << "\n";
    }

    bool operator==(const GlowMode& other) const {
        return bodyStyle == other.bodyStyle
            && borderStyle == other.borderStyle
            && borderWidth == other.borderWidth
            && transparency == other.transparency;
    }

    bool operator!=(const GlowMode& other) const {
        return !(*this == other);
    }
};


