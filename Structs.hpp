#pragma once
#include <pwd.h> // isOutdated()

struct Level {
    std::string name;
    bool isLobby;
    bool isPlayable;
    bool isTrainingArea;
    char gameMode[64] = {0};
    std::unordered_map<std::string, bool> gameModes = {{"control", true}, {"freedm", true}};
    bool isMixtape;

    void readFromMemory() {
        name = mem::ReadString(OFF_REGION + OFF_LEVEL_NAME, 1024, "Level name");
        isLobby = name == "mp_lobby";
        isPlayable = !name.empty() && name != "mp_lobby";
        isTrainingArea = name == "mp_rr_canyonlands_staging_mu1";
        uint64_t gameModePtr = mem::Read<uint64_t>(OFF_REGION + OFF_GAME_MODE + 0x50, "Level gameModePtr");
        if (gameModePtr > 0) {
            mem::Read(gameModePtr, &gameMode, sizeof(gameMode));
            isMixtape=gameModes[gameMode];
        }
    }
};

namespace keymap {
    bool AIMBOT_ACTIVATION_KEY;
    bool AIMBOT_FIRING_KEY;
    static std::chrono::milliseconds timeLastShot;
};

namespace util {
    std::string slurpFile(const std::string& absolutePath) {
        std::string contents;
        std::ifstream file;
        file.open(absolutePath, std::ios::in);
        if (file.fail()) {
            return contents;
        }
        char c;
        while (file.get(c)) {
            contents += c;
        }
        file.close();
        std::erase(contents, '\n');
        std::erase(contents, '\r');
        return contents;
    }

    // isOutdated() by hir0xygen
    bool isOutdated() { // Scan possible Steam installation paths for "libraryfolders.vdf" to then scan existing library folders for "gameversion.txt"
        // Get currently logged in user
        struct passwd* pw;
        const char* username = nullptr;
        while ((pw = getpwent()) != nullptr) {
            if (strncmp(pw->pw_dir, "/home/", 6) == 0) {
                username = pw->pw_name;
                break;
            }
        }
        endpwent();
        if (username == nullptr)
            return true;
        const std::string steamPaths[] = {
            "/.steam/steam/config/libraryfolders.vdf",
            "/.local/share/Steam/config/libraryfolders.vdf",
            "/.var/app/com.valvesoftware.Steam/data/Steam/config/libraryfolders.vdf"
        };
        std::vector<std::string> extractedPaths;
        for (const auto& steamPath : steamPaths) {
            std::stringstream fullPath;
            fullPath << "/home/" << username << steamPath;
            std::string libraryfolders = slurpFile(fullPath.str());
            size_t currentPos = 0;
            while (true) {
                const size_t pathPos = libraryfolders.find("path", currentPos);
                if (pathPos == std::string::npos)
                    break;
                const size_t pathStart = pathPos + 8;
                const size_t pathEnd = libraryfolders.find('"', pathStart);
                if (pathEnd != std::string::npos) {
                    std::string extractedPath = libraryfolders.substr(pathStart, pathEnd - pathStart);
                    std::stringstream finalPath;
                    finalPath << extractedPath << R"(/steamapps/common/Apex Legends/gameversion.txt)";
                    std::string version = slurpFile(finalPath.str());
                    printf("Apex Legends %s\n", version.c_str());
                    if (version == OFF_GAME_VERSION) {
                        return false;
                    }
                }
                currentPos = pathEnd;
            }
        }
        return true;
    }

    void sleep(int ms) {
        std::this_thread::sleep_for(std::chrono::milliseconds(ms));
    }

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
