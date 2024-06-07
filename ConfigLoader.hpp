#pragma once
struct ConfigLoader {
    const std::string FILE_NAME = "nika.ini";
    std::vector<std::string>* lines = new std::vector<std::string>;
    long m_lastTimeFileEdited = 0;

    ConfigLoader() {
        reloadFile();
    }

    //features
    bool FEATURE_AIMBOT_ON = true;
    bool FEATURE_SENSE_ON = true;
    bool FEATURE_ITEM_GLOW_ON = true;
    bool FEATURE_QUICKTURN_ON = true;
    bool FEATURE_SPECTATOR_ON = true;
    bool FEATURE_SUPER_GLIDE_ON = true;
    bool FEATURE_SKINCHANGER_ON = true;
    bool FEATURE_TRIGGERBOT_ON = true;
    bool FEATURE_NORECOIL_ON = true;
    bool FEATURE_PRINT_LEVELS_ON = true;
    bool FEATURE_MAP_RADAR_ON = true;
    
    //noRecoil    
    int NORECOIL_PITCH_REDUCTION = 15;
    int NORECOIL_YAW_REDUCTION = 17;
    //triggerBot
    int TRIGGERBOT_ZOOMED_RANGE = 180;
    int TRIGGERBOT_HIPFIRE_RANGE = 25;
    //sense
    int SENSE_MAXRANGE = 250;
    int SENSE_MAXRANGE_OVERWALL = 250;
    //aimbot
    bool AIMBOT_ACTIVATED_BY_ATTACK = true;
    bool AIMBOT_ACTIVATED_BY_ADS = false;
    bool AIMBOT_ACTIVATED_BY_KEY = false;
    float AIMBOT_SMOOTH = 20.211;
    float AIMBOT_SPEED = 40.211;
    float AIMBOT_SMOOTH_EXTRA_BY_DISTANCE = 1000;
    float AIMBOT_FOV = 5.0000;
    bool AIMBOT_PREDICT_BULLETDROP = true;
    bool AIMBOT_PREDICT_MOVEMENT = true;
    bool AIMBOT_ALLOW_TARGET_SWITCH = true;
    int AIMBOT_MAX_DISTANCE = 100;
    int AIMBOT_MIN_DISTANCE = 1;
    int AIMBOT_ZOOMED_MAX_MOVE = 15; //_add
    int AIMBOT_HIPFIRE_MAX_MOVE = 30; //_add
    //keys
    std::string AIMBOT_ACTIVATION_KEY = "XK_Shift_L";
    std::string FEATURE_QUICKTURN_BUTTON = "XK_f";
    std::string FEATURE_PRINT_LEVELS_BUTTON = "XK_p";
    std::string FEATURE_MAP_RADAR_BUTTON = "XK_m";
    std::string TRIGGERBOT_PAUSE_BUTTON = "XK_z";

    void loadVariables(std::string key, std::string val) {
        //features
        FEATURE_AIMBOT_ON = (key.compare("FEATURE_AIMBOT_ON") != 0) ? FEATURE_AIMBOT_ON : toBool(val);
        FEATURE_SENSE_ON = (key.compare("FEATURE_SENSE_ON") != 0) ? FEATURE_SENSE_ON : toBool(val);
        FEATURE_ITEM_GLOW_ON = (key.compare("FEATURE_ITEM_GLOW_ON") != 0) ? FEATURE_ITEM_GLOW_ON : toBool(val);
        FEATURE_TRIGGERBOT_ON = (key.compare("FEATURE_TRIGGERBOT_ON") != 0) ? FEATURE_TRIGGERBOT_ON : toBool(val);
        FEATURE_NORECOIL_ON = (key.compare("FEATURE_NORECOIL_ON") != 0) ? FEATURE_NORECOIL_ON : toBool(val);
        //noRecoil        
        NORECOIL_PITCH_REDUCTION = (key.compare("NORECOIL_PITCH_REDUCTION") != 0) ? NORECOIL_PITCH_REDUCTION : stoi(val);
        NORECOIL_YAW_REDUCTION = (key.compare("NORECOIL_YAW_REDUCTION") != 0) ? NORECOIL_YAW_REDUCTION : stoi(val);
        //triggerBot
        TRIGGERBOT_ZOOMED_RANGE = (key.compare("TRIGGERBOT_ZOOMED_RANGE") != 0) ? TRIGGERBOT_ZOOMED_RANGE : stoi(val);
        TRIGGERBOT_HIPFIRE_RANGE = (key.compare("TRIGGERBOT_HIPFIRE_RANGE") != 0) ? TRIGGERBOT_HIPFIRE_RANGE : stoi(val);
        TRIGGERBOT_PAUSE_BUTTON = (key.compare("TRIGGERBOT_PAUSE_BUTTON") != 0) ? TRIGGERBOT_PAUSE_BUTTON : trimConstructive(val);
        //sense
        SENSE_MAXRANGE = (key.compare("SENSE_MAXRANGE") != 0) ? SENSE_MAXRANGE : stoi(val);
        //aimbot
        AIMBOT_ACTIVATED_BY_ATTACK = (key.compare("AIMBOT_ACTIVATED_BY_ATTACK") != 0) ? AIMBOT_ACTIVATED_BY_ATTACK : toBool(val);
        AIMBOT_ACTIVATED_BY_ADS = (key.compare("AIMBOT_ACTIVATED_BY_ADS") != 0) ? AIMBOT_ACTIVATED_BY_ADS : toBool(val);
        AIMBOT_ACTIVATED_BY_KEY = (key.compare("AIMBOT_ACTIVATED_BY_KEY") != 0) ? AIMBOT_ACTIVATED_BY_KEY : toBool(val);
        AIMBOT_ACTIVATION_KEY = (key.compare("AIMBOT_ACTIVATION_KEY") != 0) ? AIMBOT_ACTIVATION_KEY : trimConstructive(val);
        AIMBOT_SMOOTH = (key.compare("AIMBOT_SMOOTH") != 0) ? AIMBOT_SMOOTH : stod(val);
        AIMBOT_SPEED = (key.compare("AIMBOT_SPEED") != 0) ? AIMBOT_SPEED : stod(val);
        AIMBOT_SMOOTH_EXTRA_BY_DISTANCE = (key.compare("AIMBOT_SMOOTH_EXTRA_BY_DISTANCE") != 0) ? AIMBOT_SMOOTH_EXTRA_BY_DISTANCE : stod(val);
        AIMBOT_FOV = (key.compare("AIMBOT_FOV") != 0) ? AIMBOT_FOV : stod(val);
        AIMBOT_PREDICT_BULLETDROP = (key.compare("AIMBOT_PREDICT_BULLETDROP") != 0) ? AIMBOT_PREDICT_BULLETDROP : toBool(val);
        AIMBOT_PREDICT_MOVEMENT = (key.compare("AIMBOT_PREDICT_MOVEMENT") != 0) ? AIMBOT_PREDICT_MOVEMENT : toBool(val);
        AIMBOT_ALLOW_TARGET_SWITCH = (key.compare("AIMBOT_ALLOW_TARGET_SWITCH") != 0) ? AIMBOT_ALLOW_TARGET_SWITCH : toBool(val);
        AIMBOT_MAX_DISTANCE = (key.compare("AIMBOT_MAX_DISTANCE") != 0) ? AIMBOT_MAX_DISTANCE : stoi(val);
        AIMBOT_MIN_DISTANCE = (key.compare("AIMBOT_MIN_DISTANCE") != 0) ? AIMBOT_MIN_DISTANCE : stoi(val);
        AIMBOT_ZOOMED_MAX_MOVE = (key.compare("AIMBOT_ZOOMED_MAX_MOVE") != 0) ? AIMBOT_ZOOMED_MAX_MOVE : stoi(val); //_add
        AIMBOT_HIPFIRE_MAX_MOVE = (key.compare("AIMBOT_HIPFIRE_MAX_MOVE") != 0) ? AIMBOT_HIPFIRE_MAX_MOVE : stoi(val); //_add
        //random
        FEATURE_SPECTATOR_ON = (key.compare("FEATURE_SPECTATOR_ON") != 0) ? FEATURE_SPECTATOR_ON : toBool(val);
        FEATURE_SUPER_GLIDE_ON = (key.compare("FEATURE_SUPER_GLIDE_ON") != 0) ? FEATURE_SUPER_GLIDE_ON : toBool(val);
        FEATURE_SKINCHANGER_ON = (key.compare("FEATURE_SKINCHANGER_ON") != 0) ? FEATURE_SKINCHANGER_ON : toBool(val);
        FEATURE_QUICKTURN_ON = (key.compare("FEATURE_QUICKTURN_ON") != 0) ? FEATURE_QUICKTURN_ON : toBool(val);    
        FEATURE_QUICKTURN_BUTTON = (key.compare("FEATURE_QUICKTURN_BUTTON") != 0) ? FEATURE_QUICKTURN_BUTTON : trimConstructive(val);
        FEATURE_PRINT_LEVELS_ON = (key.compare("FEATURE_PRINT_LEVELS_ON") != 0) ? FEATURE_PRINT_LEVELS_ON : toBool(val); 
        FEATURE_PRINT_LEVELS_BUTTON = (key.compare("FEATURE_PRINT_LEVELS_BUTTON") != 0) ? FEATURE_PRINT_LEVELS_BUTTON : trimConstructive(val);
        FEATURE_MAP_RADAR_ON = (key.compare("FEATURE_MAP_RADAR_ON") != 0) ? FEATURE_MAP_RADAR_ON : toBool(val); 
        FEATURE_MAP_RADAR_BUTTON = (key.compare("FEATURE_MAP_RADAR_BUTTON") != 0) ? FEATURE_MAP_RADAR_BUTTON : trimConstructive(val);
        }

    void print() {
        printf("\n==================== NIKA SETTINGS LOADED ==========================\n");
        //features
        printf("FEATURE_AIMBOT_ON\t\t\t\t\t%s\n", FEATURE_AIMBOT_ON ? "YES" : "NO");
        printf("FEATURE_NORECOIL_ON\t\t\t\t\t%s\n", FEATURE_NORECOIL_ON ? "YES" : "NO");
        printf("FEATURE_SENSE_ON\t\t\t\t\t%s\n", FEATURE_SENSE_ON ? "YES" : "NO");
        printf("FEATURE_ITEM_GLOW_ON\t\t\t\t\t%s\n", FEATURE_ITEM_GLOW_ON ? "YES" : "NO");
        printf("FEATURE_TRIGGERBOT_ON\t\t\t\t\t%s\n\n", FEATURE_TRIGGERBOT_ON ? "YES" : "NO");
        printf("FEATURE_SPECTATOR_ON\t\t\t\t\t%s\n", FEATURE_SPECTATOR_ON ? "YES" : "NO");
        printf("FEATURE_SUPER_GLIDE_ON\t\t\t\t\t%s\n", FEATURE_SUPER_GLIDE_ON ? "YES" : "NO");
        printf("FEATURE_SKINCHANGER_ON\t\t\t\t\t%s\n", FEATURE_SKINCHANGER_ON ? "YES" : "NO");
        printf("FEATURE_QUICKTURN_ON\t\t\t\t\t%s\n", FEATURE_QUICKTURN_ON ? "YES" : "NO");
        printf("FEATURE_QUICKTURN_BUTTON\t\t\t\t%s\n", FEATURE_QUICKTURN_BUTTON.c_str());
        printf("FEATURE_PRINT_LEVELS_ON\t\t\t\t\t%s\n", FEATURE_PRINT_LEVELS_ON ? "YES" : "NO");
        printf("FEATURE_PRINT_LEVELS_BUTTON\t\t\t\t%s\n", FEATURE_PRINT_LEVELS_BUTTON.c_str());
        printf("FEATURE_MAP_RADAR_ON\t\t\t\t\t%s\n", FEATURE_MAP_RADAR_ON ? "YES" : "NO");
        printf("FEATURE_MAP_RADAR_BUTTON\t\t\t\t%s\n", FEATURE_MAP_RADAR_BUTTON.c_str());
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        //norecoil
        printf("NORECOIL_PITCH_REDUCTION\t\t\t\t%d\n", NORECOIL_PITCH_REDUCTION);
        printf("NORECOIL_YAW_REDUCTION\t\t\t\t\t%d\n", NORECOIL_YAW_REDUCTION);
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        //triggerBot
        printf("TRIGGERBOT_ZOOMED_RANGE\t\t\t\t\t%d\n", TRIGGERBOT_ZOOMED_RANGE);
        printf("TRIGGERBOT_HIPFIRE_RANGE\t\t\t\t%d\n", TRIGGERBOT_HIPFIRE_RANGE);
        printf("TRIGGERBOT_PAUSE_BUTTON\t\t\t\t\t%s\n", TRIGGERBOT_PAUSE_BUTTON.c_str());
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        //sense
        printf("SENSE_MAXRANGE\t\t\t\t\t\t%d\n", SENSE_MAXRANGE);
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");        
        //aimbot
        printf("AIMBOT_ACTIVATED_BY_ATTACK\t\t\t\t%s\n", AIMBOT_ACTIVATED_BY_ATTACK ? "YES" : "NO");
        printf("AIMBOT_ACTIVATED_BY_ADS\t\t\t\t\t%s\n", AIMBOT_ACTIVATED_BY_ADS ? "YES" : "NO");
        printf("AIMBOT_ACTIVATED_BY_KEY\t\t\t\t\t%s\n", AIMBOT_ACTIVATED_BY_KEY ? "YES" : "NO");
        printf("AIMBOT_ACTIVATION_KEY\t\t\t\t\t%s\n", AIMBOT_ACTIVATION_KEY.c_str());
        printf("AIMBOT_SMOOTH\t\t\t\t\t\t%.10f\n", AIMBOT_SMOOTH);
        printf("AIMBOT_SPEED\t\t\t\t\t\t%.10f\n", AIMBOT_SPEED);
        printf("AIMBOT_SMOOTH_EXTRA_BY_DISTANCE\t\t\t\t%.4f\n", AIMBOT_SMOOTH_EXTRA_BY_DISTANCE);
        printf("AIMBOT_FOV\t\t\t\t\t\t%.4f\n", AIMBOT_FOV);
        printf("AIMBOT_PREDICT_BULLETDROP\t\t\t\t%s\n", AIMBOT_PREDICT_BULLETDROP ? "YES" : "NO");
        printf("AIMBOT_PREDICT_MOVEMENT\t\t\t\t\t%s\n", AIMBOT_PREDICT_MOVEMENT ? "YES" : "NO");
        printf("AIMBOT_ALLOW_TARGET_SWITCH\t\t\t\t%s\n", AIMBOT_ALLOW_TARGET_SWITCH ? "YES" : "NO");
        printf("AIMBOT_MAX_DISTANCE\t\t\t\t\t%d\n", AIMBOT_MAX_DISTANCE);
        printf("AIMBOT_MIN_DISTANCE\t\t\t\t\t%d\n", AIMBOT_MIN_DISTANCE);
        printf("AIMBOT_ZOOMED_MAX_MOVE\t\t\t\t\t%d\n", AIMBOT_ZOOMED_MAX_MOVE); //_add
        printf("AIMBOT_HIPFIRE_MAX_MOVE\t\t\t\t\t%d\n", AIMBOT_HIPFIRE_MAX_MOVE); //_add

        printf("=====================================================================\n\n");

    }
    void reloadFile() {
        if (loadFileIntoVector()) {
            parseLines();
            print(); 
            printLogo();          
        }
    }
    void parseLines() {
        for (int i = 0; i < lines->size(); i++) {
            std::vector<std::string> lineParts = split(lines->at(i));
            // line key
            std::string key(lineParts.at(0));
            trim(key);
            if (key.empty()) throw "Cannot parse the config. Bad key";
            // line value
            std::string value(lineParts.at(1));
            trim(value);
            if (value.empty()) throw "Cannot parse the config. Bad value";
            loadVariables(key, value);
        }
    }
    void trim(std::string& s) {
        ltrim(s);
        rtrim(s);
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
    std::vector<std::string> split(std::string s) {
        std::stringstream ss(s);
        std::istream_iterator<std::string> begin(ss);
        std::istream_iterator<std::string> end;
        std::vector<std::string> tokens(begin, end);
        return tokens;
    }
    std::string toLowerCase(const std::string& input) {
        std::string result = input;
        std::transform(result.begin(), result.end(), result.begin(), ::tolower);
        return result;
    }

    void printLogo(){
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
};
