#pragma once

struct ConfigLoader {
    const std::string FILE_NAME = "nika.ini";
    std::vector<std::string>* lines = new std::vector<std::string>;
    long m_lastTimeFileEdited = 0;

    ConfigLoader() {
        reloadFile();
    }

    // Features
    bool FEATURE_AIMBOT_ON = true;
    bool FEATURE_TRIGGERBOT_ON = true;
    bool FEATURE_SPECTATORS_ON = false;
    bool FEATURE_SPECTATORS_SHOW_DEAD = false;
    bool FEATURE_SUPER_GLIDE_ON = false;
    bool FEATURE_MAP_RADAR_ON = true;
    int FEATURE_MAP_RADAR_X = 220;
    int FEATURE_MAP_RADAR_Y = 220;
    // Sense
    int SENSE_VERBOSE = 2;
    int SENSE_MAX_RANGE = 250;
    bool SENSE_SHOW_PLAYER_BARS = true;
    bool SENSE_SHOW_PLAYER_DISTANCES = true;
    bool SENSE_SHOW_PLAYER_NAMES = false;
    bool SENSE_SHOW_PLAYER_LEVELS = false;
    bool SENSE_TEXT_BOTTOM = true;
    bool SENSE_SHOW_DEAD = false;
    bool SENSE_SHOW_FOV = true;
    bool SENSE_SHOW_TARGET = true;
    // TriggerBot
//    int TRIGGERBOT_ZOOMED_RANGE = 180;
    int TRIGGERBOT_HIPFIRE_RANGE = 45;
    // AimBot
    int AIMBOT_DELAY = 2;
    float AIMBOT_SPEED = 20;
    float AIMBOT_SMOOTH = 20;
    float AIMBOT_SMOOTH_EXTRA_BY_DISTANCE = 1500;
    float AIMBOT_FOV = 7.5f;
    float AIMBOT_FOV_EXTRA_BY_ZOOM = 0.2f;
    float AIMBOT_FAST_AREA = 0.75f;
    float AIMBOT_SLOW_AREA = 0.50f;
    float AIMBOT_WEAKEN = 2;
    bool AIMBOT_SPECTATORS_WEAKEN = true;
    bool AIMBOT_PREDICT_BULLETDROP = true;
    bool AIMBOT_PREDICT_MOVEMENT = true;
//    bool AIMBOT_ALLOW_TARGET_SWITCH = false;
    bool AIMBOT_FRIENDLY_FIRE = false;
    bool AIMBOT_LEGACY_MODE = false;
    int AIMBOT_MAX_DISTANCE = 250;
    int AIMBOT_MIN_DISTANCE = 0;
    int AIMBOT_ZOOMED_MAX_MOVE = 45;
    int AIMBOT_HIPFIRE_MAX_MOVE = 30;
    int AIMBOT_MAX_DELTA = 15;
    bool AIMBOT_ACTIVATED_BY_ADS = false;
    bool AIMBOT_ACTIVATED_BY_MOUSE = true;
    bool AIMBOT_ACTIVATED_BY_KEY = true;
    // Keys
    std::string AIMBOT_ACTIVATION_KEY = "XK_Shift_L";
    std::string AIMBOT_FIRING_KEY = "XK_x";
    std::string SUPER_GLIDE_ACTIVATION_KEY = "XK_Caps_Lock";

    bool loadFileIntoVector() {
        struct stat result;
        if (stat(FILE_NAME.c_str(), &result) == 0) {
            long modTime = result.st_mtime;
            bool fileNeedsReload = modTime > m_lastTimeFileEdited;
            m_lastTimeFileEdited = modTime;
            if (!fileNeedsReload) return false;
        }
        lines->clear();
        std::string str;
        std::ifstream myFile(FILE_NAME);
        while (getline(myFile, str)) {
            trim(str);
            if (str.empty()) continue;
            if (str.rfind("#", 0) == 0) continue;
            lines->push_back(str);
        }
        myFile.close();
        return true;
    }

    std::vector<std::string> split(std::string s) {
        std::stringstream ss(s);
        std::istream_iterator<std::string> begin(ss);
        std::istream_iterator<std::string> end;
        std::vector<std::string> tokens(begin, end);
        return tokens;
    }

    void ltrim(std::string& s) {
        s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch)
            { return !std::isspace(ch); }));
    }

    void rtrim(std::string& s) {
        s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch)
            { return !std::isspace(ch); })
            .base(),
            s.end());
    }

    void trim(std::string& s) {
        ltrim(s);
        rtrim(s);
    }

    std::string toLowerCase(const std::string& input) {
        std::string result = input;
        std::transform(result.begin(), result.end(), result.begin(), ::tolower);
        return result;
    }

    bool toBool(std::string str) {
        if (toLowerCase(str) == "y") return true;
        if (toLowerCase(str) == "n") return false;
        if (toLowerCase(str) == "yes") return true;
        if (toLowerCase(str) == "no") return false;
        if (toLowerCase(str) == "1") return true;
        if (toLowerCase(str) == "0") return false;
        throw  std::invalid_argument("Cannot parse string to boolean: " + str);
    }

    std::string trimConstructive(std::string& s) {
        ltrim(s);
        rtrim(s);
        return s;
    }

    void loadVariables(std::string key, std::string val) {
        // Features
        FEATURE_AIMBOT_ON = (key.compare("FEATURE_AIMBOT_ON") != 0) ? FEATURE_AIMBOT_ON : toBool(val);
        FEATURE_TRIGGERBOT_ON = (key.compare("FEATURE_TRIGGERBOT_ON") != 0) ? FEATURE_TRIGGERBOT_ON : toBool(val);
        FEATURE_SPECTATORS_ON = (key.compare("FEATURE_SPECTATORS_ON") != 0) ? FEATURE_SPECTATORS_ON : toBool(val);
        FEATURE_SPECTATORS_SHOW_DEAD = (key.compare("FEATURE_SPECTATORS_SHOW_DEAD") != 0) ? FEATURE_SPECTATORS_SHOW_DEAD : toBool(val);
        FEATURE_SUPER_GLIDE_ON = (key.compare("FEATURE_SUPER_GLIDE_ON") != 0) ? FEATURE_SUPER_GLIDE_ON : toBool(val);
        FEATURE_MAP_RADAR_ON = (key.compare("FEATURE_MAP_RADAR_ON") != 0) ? FEATURE_MAP_RADAR_ON : toBool(val);
        FEATURE_MAP_RADAR_X = (key.compare("FEATURE_MAP_RADAR_X") != 0) ? FEATURE_MAP_RADAR_X : stoi(val);
        FEATURE_MAP_RADAR_Y = (key.compare("FEATURE_MAP_RADAR_Y") != 0) ? FEATURE_MAP_RADAR_Y : stoi(val);
        // Sense
        SENSE_VERBOSE = (key.compare("SENSE_VERBOSE") != 0) ? SENSE_VERBOSE : stoi(val);
        SENSE_MAX_RANGE = (key.compare("SENSE_MAX_RANGE") != 0) ? SENSE_MAX_RANGE : stoi(val);
        SENSE_SHOW_PLAYER_BARS = (key.compare("SENSE_SHOW_PLAYER_BARS") != 0) ? SENSE_SHOW_PLAYER_BARS : toBool(val);
        SENSE_SHOW_PLAYER_DISTANCES = (key.compare("SENSE_SHOW_PLAYER_DISTANCES") != 0) ? SENSE_SHOW_PLAYER_DISTANCES : toBool(val);
        SENSE_SHOW_PLAYER_NAMES = (key.compare("SENSE_SHOW_PLAYER_NAMES") != 0) ? SENSE_SHOW_PLAYER_NAMES : toBool(val);
        SENSE_SHOW_PLAYER_LEVELS = (key.compare("SENSE_SHOW_PLAYER_LEVELS") != 0) ? SENSE_SHOW_PLAYER_LEVELS : toBool(val);
        SENSE_TEXT_BOTTOM = (key.compare("SENSE_TEXT_BOTTOM") != 0) ? SENSE_TEXT_BOTTOM : toBool(val);
        SENSE_SHOW_DEAD = (key.compare("SENSE_SHOW_DEAD") != 0) ? SENSE_SHOW_DEAD : toBool(val);
        SENSE_SHOW_FOV = (key.compare("SENSE_SHOW_FOV") != 0) ? SENSE_SHOW_FOV : toBool(val);
        SENSE_SHOW_TARGET = (key.compare("SENSE_SHOW_TARGET") != 0) ? SENSE_SHOW_TARGET : toBool(val);
        // TriggerBot
//        TRIGGERBOT_ZOOMED_RANGE = (key.compare("TRIGGERBOT_ZOOMED_RANGE") != 0) ? TRIGGERBOT_ZOOMED_RANGE : stoi(val);
        TRIGGERBOT_HIPFIRE_RANGE = (key.compare("TRIGGERBOT_HIPFIRE_RANGE") != 0) ? TRIGGERBOT_HIPFIRE_RANGE : stoi(val);
        // AimBot
        AIMBOT_DELAY = (key.compare("AIMBOT_DELAY") != 0) ? AIMBOT_DELAY : stod(val);
        AIMBOT_SPEED = (key.compare("AIMBOT_SPEED") != 0) ? AIMBOT_SPEED : stod(val);
        AIMBOT_SMOOTH = (key.compare("AIMBOT_SMOOTH") != 0) ? AIMBOT_SMOOTH : stod(val);
        AIMBOT_SMOOTH_EXTRA_BY_DISTANCE = (key.compare("AIMBOT_SMOOTH_EXTRA_BY_DISTANCE") != 0) ? AIMBOT_SMOOTH_EXTRA_BY_DISTANCE : stod(val);
        AIMBOT_FOV = (key.compare("AIMBOT_FOV") != 0) ? AIMBOT_FOV : stod(val);
        AIMBOT_FOV_EXTRA_BY_ZOOM = (key.compare("AIMBOT_FOV_EXTRA_BY_ZOOM") != 0) ? AIMBOT_FOV_EXTRA_BY_ZOOM : stod(val);
        AIMBOT_FAST_AREA = (key.compare("AIMBOT_FAST_AREA") != 0) ? AIMBOT_FAST_AREA : stod(val);
        AIMBOT_SLOW_AREA = (key.compare("AIMBOT_SLOW_AREA") != 0) ? AIMBOT_SLOW_AREA : stod(val);
        AIMBOT_WEAKEN = (key.compare("AIMBOT_WEAKEN") != 0) ? AIMBOT_WEAKEN : stod(val);
        AIMBOT_SPECTATORS_WEAKEN = (key.compare("AIMBOT_SPECTATORS_WEAKEN") != 0) ? AIMBOT_SPECTATORS_WEAKEN : toBool(val);
        AIMBOT_PREDICT_BULLETDROP = (key.compare("AIMBOT_PREDICT_BULLETDROP") != 0) ? AIMBOT_PREDICT_BULLETDROP : toBool(val);
        AIMBOT_PREDICT_MOVEMENT = (key.compare("AIMBOT_PREDICT_MOVEMENT") != 0) ? AIMBOT_PREDICT_MOVEMENT : toBool(val);
//        AIMBOT_ALLOW_TARGET_SWITCH = (key.compare("AIMBOT_ALLOW_TARGET_SWITCH") != 0) ? AIMBOT_ALLOW_TARGET_SWITCH : toBool(val);
        AIMBOT_FRIENDLY_FIRE = (key.compare("AIMBOT_FRIENDLY_FIRE") != 0) ? AIMBOT_FRIENDLY_FIRE : toBool(val);
        AIMBOT_LEGACY_MODE = (key.compare("AIMBOT_LEGACY_MODE") != 0) ? AIMBOT_LEGACY_MODE : toBool(val);
        AIMBOT_MAX_DISTANCE = (key.compare("AIMBOT_MAX_DISTANCE") != 0) ? AIMBOT_MAX_DISTANCE : stoi(val);
        AIMBOT_MIN_DISTANCE = (key.compare("AIMBOT_MIN_DISTANCE") != 0) ? AIMBOT_MIN_DISTANCE : stoi(val);
        AIMBOT_ZOOMED_MAX_MOVE = (key.compare("AIMBOT_ZOOMED_MAX_MOVE") != 0) ? AIMBOT_ZOOMED_MAX_MOVE : stoi(val);
        AIMBOT_HIPFIRE_MAX_MOVE = (key.compare("AIMBOT_HIPFIRE_MAX_MOVE") != 0) ? AIMBOT_HIPFIRE_MAX_MOVE : stoi(val);
        AIMBOT_MAX_DELTA = (key.compare("AIMBOT_MAX_DELTA") != 0) ? AIMBOT_MAX_DELTA : stoi(val);
        AIMBOT_ACTIVATED_BY_ADS = (key.compare("AIMBOT_ACTIVATED_BY_ADS") != 0) ? AIMBOT_ACTIVATED_BY_ADS : toBool(val);
        AIMBOT_ACTIVATED_BY_MOUSE = (key.compare("AIMBOT_ACTIVATED_BY_MOUSE") != 0) ? AIMBOT_ACTIVATED_BY_MOUSE : toBool(val);
        AIMBOT_ACTIVATED_BY_KEY = (key.compare("AIMBOT_ACTIVATED_BY_KEY") != 0) ? AIMBOT_ACTIVATED_BY_KEY : toBool(val);
        // Keys
        AIMBOT_ACTIVATION_KEY = (key.compare("AIMBOT_ACTIVATION_KEY") != 0) ? AIMBOT_ACTIVATION_KEY : trimConstructive(val);
        AIMBOT_FIRING_KEY = (key.compare("AIMBOT_FIRING_KEY") != 0) ? AIMBOT_FIRING_KEY : trimConstructive(val);
        SUPER_GLIDE_ACTIVATION_KEY = (key.compare("SUPER_GLIDE_ACTIVATION_KEY") != 0) ? SUPER_GLIDE_ACTIVATION_KEY : trimConstructive(val);
    }

    void parseLines() {
        for (int i = 0; i < lines->size(); i++) {
            std::vector<std::string> lineParts = split(lines->at(i));
            // Line key
            std::string key(lineParts.at(0));
            trim(key);
            if (key.empty()) throw "Cannot parse the config. Bad key";
            // Line value
            std::string value(lineParts.at(1));
            trim(value);
            if (value.empty()) throw "Cannot parse the config. Bad value";
            loadVariables(key, value);
        }
    }

    void print() {
        printf("\n======================== NIKA CONFIG LOADED ========================\n");
        // Features
        printf("FEATURE_AIMBOT_ON\t\t\t\t\t%s\n", FEATURE_AIMBOT_ON ? "YES" : "NO");
        printf("FEATURE_TRIGGERBOT_ON\t\t\t\t\t%s\n", FEATURE_TRIGGERBOT_ON ? "YES" : "NO");
        printf("FEATURE_SPECTATORS_ON\t\t\t\t\t%s\n", FEATURE_SPECTATORS_ON ? "YES" : "NO");
        printf("FEATURE_SPECTATORS_SHOW_DEAD\t\t\t\t%s\n", FEATURE_SPECTATORS_SHOW_DEAD ? "YES" : "NO");
        printf("FEATURE_SUPER_GLIDE_ON\t\t\t\t\t%s\n", FEATURE_SUPER_GLIDE_ON ? "YES" : "NO");
        printf("FEATURE_MAP_RADAR_ON\t\t\t\t\t%s\n", FEATURE_MAP_RADAR_ON ? "YES" : "NO");
        printf("FEATURE_MAP_RADAR_X\t\t\t\t\t%d\n", FEATURE_MAP_RADAR_X);
        printf("FEATURE_MAP_RADAR_Y\t\t\t\t\t%d\n", FEATURE_MAP_RADAR_Y);
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        // Sense
        printf("SENSE_VERBOSE\t\t\t\t\t\t%d\n", SENSE_VERBOSE);
        printf("SENSE_MAX_RANGE\t\t\t\t\t\t%d\n", SENSE_MAX_RANGE);
        printf("SENSE_SHOW_PLAYER_BARS\t\t\t\t\t%s\n", SENSE_SHOW_PLAYER_BARS ? "YES" : "NO");
        printf("SENSE_SHOW_PLAYER_DISTANCES\t\t\t\t%s\n", SENSE_SHOW_PLAYER_DISTANCES ? "YES" : "NO");
        printf("SENSE_SHOW_PLAYER_NAMES\t\t\t\t\t%s\n", SENSE_SHOW_PLAYER_NAMES ? "YES" : "NO");
        printf("SENSE_SHOW_PLAYER_LEVELS\t\t\t\t%s\n", SENSE_SHOW_PLAYER_LEVELS ? "YES" : "NO");
        printf("SENSE_TEXT_BOTTOM\t\t\t\t\t%s\n", SENSE_TEXT_BOTTOM ? "YES" : "NO");
        printf("SENSE_SHOW_DEAD\t\t\t\t\t\t%s\n", SENSE_SHOW_DEAD ? "YES" : "NO");
        printf("SENSE_SHOW_FOV\t\t\t\t\t\t%s\n", SENSE_SHOW_FOV ? "YES" : "NO");
        printf("SENSE_SHOW_TARGET\t\t\t\t\t%s\n", SENSE_SHOW_TARGET ? "YES" : "NO");
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        // TriggerBot
//        printf("TRIGGERBOT_ZOOMED_RANGE\t\t\t\t\t%d\n", TRIGGERBOT_ZOOMED_RANGE);
        printf("TRIGGERBOT_HIPFIRE_RANGE\t\t\t\t%d\n", TRIGGERBOT_HIPFIRE_RANGE);
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        // AimBot
        printf("AIMBOT_DELAY\t\t\t\t\t\t%d\n", AIMBOT_DELAY);
        printf("AIMBOT_SPEED\t\t\t\t\t\t%.4f\n", AIMBOT_SPEED);
        printf("AIMBOT_SMOOTH\t\t\t\t\t\t%.4f\n", AIMBOT_SMOOTH);
        printf("AIMBOT_SMOOTH_EXTRA_BY_DISTANCE\t\t\t\t%.4f\n", AIMBOT_SMOOTH_EXTRA_BY_DISTANCE);
        printf("AIMBOT_FOV\t\t\t\t\t\t%.2f\n", AIMBOT_FOV);
        printf("AIMBOT_FOV_EXTRA_BY_ZOOM\t\t\t\t%.2f\n", AIMBOT_FOV_EXTRA_BY_ZOOM);
        printf("AIMBOT_FAST_AREA\t\t\t\t\t%.2f\n", AIMBOT_FAST_AREA);
        printf("AIMBOT_SLOW_AREA\t\t\t\t\t%.2f\n", AIMBOT_SLOW_AREA);
        printf("AIMBOT_WEAKEN\t\t\t\t\t\t%.2f\n", AIMBOT_WEAKEN);
        printf("AIMBOT_SPECTATORS_WEAKEN\t\t\t\t%s\n", AIMBOT_SPECTATORS_WEAKEN ? "YES" : "NO");
        printf("AIMBOT_PREDICT_BULLETDROP\t\t\t\t%s\n", AIMBOT_PREDICT_BULLETDROP ? "YES" : "NO");
        printf("AIMBOT_PREDICT_MOVEMENT\t\t\t\t\t%s\n", AIMBOT_PREDICT_MOVEMENT ? "YES" : "NO");
//        printf("AIMBOT_ALLOW_TARGET_SWITCH\t\t\t\t%s\n", AIMBOT_ALLOW_TARGET_SWITCH ? "YES" : "NO");
        printf("AIMBOT_FRIENDLY_FIRE\t\t\t\t\t%s\n", AIMBOT_FRIENDLY_FIRE ? "YES" : "NO");
        printf("AIMBOT_LEGACY_MODE\t\t\t\t\t%s\n", AIMBOT_LEGACY_MODE ? "YES" : "NO");
        printf("AIMBOT_MAX_DISTANCE\t\t\t\t\t%d\n", AIMBOT_MAX_DISTANCE);
        printf("AIMBOT_MIN_DISTANCE\t\t\t\t\t%d\n", AIMBOT_MIN_DISTANCE);
        printf("AIMBOT_ZOOMED_MAX_MOVE\t\t\t\t\t%d\n", AIMBOT_ZOOMED_MAX_MOVE);
        printf("AIMBOT_HIPFIRE_MAX_MOVE\t\t\t\t\t%d\n", AIMBOT_HIPFIRE_MAX_MOVE);
        printf("AIMBOT_MAX_DELTA\t\t\t\t\t%d\n", AIMBOT_MAX_DELTA);
        printf("AIMBOT_ACTIVATED_BY_ADS\t\t\t\t\t%s\n", AIMBOT_ACTIVATED_BY_ADS ? "YES" : "NO");
        printf("AIMBOT_ACTIVATED_BY_MOUSE\t\t\t\t%s\n", AIMBOT_ACTIVATED_BY_MOUSE ? "YES" : "NO");
        printf("AIMBOT_ACTIVATED_BY_KEY\t\t\t\t\t%s\n", AIMBOT_ACTIVATED_BY_KEY ? "YES" : "NO");
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        // Keys
        printf("AIMBOT_ACTIVATION_KEY\t\t\t\t\t%s\n", AIMBOT_ACTIVATION_KEY.c_str());
        printf("AIMBOT_FIRING_KEY\t\t\t\t\t%s\n", AIMBOT_FIRING_KEY.c_str());
        printf("SUPER_GLIDE_ACTIVATION_KEY\t\t\t\t%s\n", SUPER_GLIDE_ACTIVATION_KEY.c_str());
        printf("====================================================================\n\n");
    }

    void printLogo() {
        std::cout << "\033[1;33m";
        std::cout << " .--..--..--..--..--..--..--..--..--..--..--..--..--..--.\n";
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(/ .. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(\ \/\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( \/ /`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'\/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( / /\                                                / /\)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(/ /\ \          ,--.             ,--.               / /\ \)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(\ \/ /        ,--.'|  ,---,  ,--/  /|  ,---,,       \ \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( \/ /     ,--,:  : ,`--.' ,---,': / ' '  .'  :       \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( / /\  ,`--.'`|  ' |   :  :   : '/ / /  ;     \      / /\)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(/ /\ \ |   :  :  | :   |  |   '   , :  :       :    / /\ \)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(\ \/ / :   |   \ | |   :  '   |  /  :  |   /\   \   \ \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( \/ /  |   : '  '; '   '  |   ;  ;  |  :  ' ;.   :   \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( / /\  '   ' ;.    |   |  :   '   \ |  |  ;/  \   \  / /\)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(/ /\ \ |   | | \   '   :  |   |    ''  :  | \  \ ,' / /\ \)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(\ \/ / '   : |  ; .|   |  '   : |.  |  |  '  '--'   \ \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( \/ /  |   | '`--' '   :  |   | '_\.|  :  :          \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( / /\  '   : |     ;   |.''   : |   |  | ,'          / /\)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(/ /\ \ ;   |.'     '---'  ;   |,'   `--''           / /\ \)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(\ \/ / '---'              '---'                     \ \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( \/ /                                                \/ /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( / /\.--..--..--..--..--..--..--..--..--..--..--..--./ /\)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(/ /\ \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \/\ \)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"(\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `' /)" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(69));
        std::cout << R"( `--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--')" << std::endl;
        std::cout << "\033[0m"; 
    }

    void reloadFile() {
        if (loadFileIntoVector()) {
            parseLines();
            print(); 
            printLogo();
        }
    }
};
