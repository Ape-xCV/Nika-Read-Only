#include "includes.hpp"
//_begin
#include "Utils/Overlay.hpp"
#include "Utils/Camera.hpp"
Overlay OverlayWindow = Overlay();
Camera* GameCamera = new Camera();
ImDrawList* Canvas;

const void SetStyle() {
    ImGuiStyle& style = ImGui::GetStyle();
    //
    style.WindowPadding                             = ImVec2(8.00f, 8.00f);
    style.FramePadding                              = ImVec2(5.00f, 2.00f);
    style.CellPadding                               = ImVec2(6.00f, 6.00f);
    style.ItemSpacing                               = ImVec2(6.00f, 6.00f);
    style.ItemInnerSpacing                          = ImVec2(6.00f, 6.00f);
    style.TouchExtraPadding                         = ImVec2(0.00f, 0.00f);
    style.IndentSpacing                             = 25;
    style.ScrollbarSize                             = 15;
    style.GrabMinSize                               = 10;
    style.WindowBorderSize                          = 1;
    style.ChildBorderSize                           = 1;
    style.PopupBorderSize                           = 1;
    style.FrameBorderSize                           = 1;
    style.TabBorderSize                             = 1;
    style.WindowRounding                            = 7;
    style.ChildRounding                             = 4;
    style.FrameRounding                             = 3;
    style.PopupRounding                             = 4;
    style.ScrollbarRounding                         = 9;
    style.GrabRounding                              = 3;
    style.LogSliderDeadzone                         = 4;
    style.TabRounding                               = 4;
    style.Colors[ImGuiCol_Text]                     = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    style.Colors[ImGuiCol_TextDisabled]             = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
    style.Colors[ImGuiCol_WindowBg]                 = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
    style.Colors[ImGuiCol_ChildBg]                  = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    style.Colors[ImGuiCol_PopupBg]                  = ImVec4(0.19f, 0.19f, 0.19f, 0.92f);
    style.Colors[ImGuiCol_Border]                   = ImVec4(0.19f, 0.19f, 0.19f, 0.29f);
    style.Colors[ImGuiCol_BorderShadow]             = ImVec4(0.00f, 0.00f, 0.00f, 0.24f);
    style.Colors[ImGuiCol_FrameBg]                  = ImVec4(0.05f, 0.05f, 0.05f, 0.54f);
    style.Colors[ImGuiCol_FrameBgHovered]           = ImVec4(0.19f, 0.19f, 0.19f, 0.54f);
    style.Colors[ImGuiCol_FrameBgActive]            = ImVec4(0.20f, 0.22f, 0.23f, 1.00f);
    style.Colors[ImGuiCol_TitleBg]                  = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_TitleBgActive]            = ImVec4(0.06f, 0.06f, 0.06f, 1.00f);
    style.Colors[ImGuiCol_TitleBgCollapsed]         = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_MenuBarBg]                = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
    style.Colors[ImGuiCol_ScrollbarBg]              = ImVec4(0.05f, 0.05f, 0.05f, 0.54f);
    style.Colors[ImGuiCol_ScrollbarGrab]            = ImVec4(0.34f, 0.34f, 0.34f, 0.54f);
    style.Colors[ImGuiCol_ScrollbarGrabHovered]     = ImVec4(0.40f, 0.40f, 0.40f, 0.54f);
    style.Colors[ImGuiCol_ScrollbarGrabActive]      = ImVec4(0.56f, 0.56f, 0.56f, 0.54f);
    style.Colors[ImGuiCol_CheckMark]                = ImVec4(0.33f, 0.67f, 0.86f, 1.00f);
    style.Colors[ImGuiCol_SliderGrab]               = ImVec4(0.34f, 0.34f, 0.34f, 0.54f);
    style.Colors[ImGuiCol_SliderGrabActive]         = ImVec4(0.56f, 0.56f, 0.56f, 0.54f);
    style.Colors[ImGuiCol_Button]                   = ImVec4(0.05f, 0.05f, 0.05f, 0.54f);
    style.Colors[ImGuiCol_ButtonHovered]            = ImVec4(0.19f, 0.19f, 0.19f, 0.54f);
    style.Colors[ImGuiCol_ButtonActive]             = ImVec4(0.20f, 0.22f, 0.23f, 1.00f);
    style.Colors[ImGuiCol_Header]                   = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
    style.Colors[ImGuiCol_HeaderHovered]            = ImVec4(0.00f, 0.00f, 0.00f, 0.36f);
    style.Colors[ImGuiCol_HeaderActive]             = ImVec4(0.20f, 0.22f, 0.23f, 0.33f);
    style.Colors[ImGuiCol_Separator]                = ImVec4(0.28f, 0.28f, 0.28f, 0.29f);
    style.Colors[ImGuiCol_SeparatorHovered]         = ImVec4(0.44f, 0.44f, 0.44f, 0.29f);
    style.Colors[ImGuiCol_SeparatorActive]          = ImVec4(0.40f, 0.44f, 0.47f, 1.00f);
    style.Colors[ImGuiCol_ResizeGrip]               = ImVec4(0.28f, 0.28f, 0.28f, 0.29f);
    style.Colors[ImGuiCol_ResizeGripHovered]        = ImVec4(0.44f, 0.44f, 0.44f, 0.29f);
    style.Colors[ImGuiCol_ResizeGripActive]         = ImVec4(0.40f, 0.44f, 0.47f, 1.00f);
    style.Colors[ImGuiCol_Tab]                      = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
    style.Colors[ImGuiCol_TabHovered]               = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
    style.Colors[ImGuiCol_TabActive]                = ImVec4(0.20f, 0.20f, 0.20f, 0.36f);
    style.Colors[ImGuiCol_TabUnfocused]             = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
    style.Colors[ImGuiCol_TabUnfocusedActive]       = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
    //style.Colors[ImGuiCol_DockingPreview]         = ImVec4(0.33f, 0.67f, 0.86f, 1.00f);
    //style.Colors[ImGuiCol_DockingEmptyBg]         = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_PlotLines]                = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_PlotLinesHovered]         = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_PlotHistogram]            = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_PlotHistogramHovered]     = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_TableHeaderBg]            = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
    style.Colors[ImGuiCol_TableBorderStrong]        = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
    style.Colors[ImGuiCol_TableBorderLight]         = ImVec4(0.28f, 0.28f, 0.28f, 0.29f);
    style.Colors[ImGuiCol_TableRowBg]               = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    style.Colors[ImGuiCol_TableRowBgAlt]            = ImVec4(1.00f, 1.00f, 1.00f, 0.06f);
    style.Colors[ImGuiCol_TextSelectedBg]           = ImVec4(0.20f, 0.22f, 0.23f, 1.00f);
    style.Colors[ImGuiCol_DragDropTarget]           = ImVec4(0.33f, 0.67f, 0.86f, 1.00f);
    style.Colors[ImGuiCol_NavHighlight]             = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    style.Colors[ImGuiCol_NavWindowingHighlight]    = ImVec4(1.00f, 0.00f, 0.00f, 0.70f);
    style.Colors[ImGuiCol_NavWindowingDimBg]        = ImVec4(1.00f, 0.00f, 0.00f, 0.20f);
    style.Colors[ImGuiCol_ModalWindowDimBg]         = ImVec4(1.00f, 0.00f, 0.00f, 0.35f);
}

bool InitializeOverlayWindow(const char* OverlayTitle) {
    if (!OverlayWindow.InitializeOverlay(OverlayTitle)) {
        OverlayWindow.DestroyOverlay();
        return false;
    }
    OverlayWindow.CaptureInput(false);
    int screenWidth;
    int screenHeight;
    OverlayWindow.GetScreenResolution(screenWidth, screenHeight);
    GameCamera->Initialize(screenWidth, screenHeight);
    std::cout << "Overlay Initialized!" << std::endl;
    SetStyle();
    return true;
}

ConfigLoader* cl = new ConfigLoader();
Level* map = new Level();
LocalPlayer* localPlayer = new LocalPlayer(cl);
std::vector<Player*>* players = new std::vector<Player*>;
std::vector<Player*>* playersCache = new std::vector<Player*>;
Sense* sense = new Sense(cl, map, localPlayer, players, GameCamera);
int counter;
int processingTime;
std::vector<int> processingTimes;
double averageProcessingTime;
int frameCountPrev;
std::vector<int> frameCountDiffs;
std::vector<int> frameCountTimes;
double averageFPS;
int readError = 1000;
bool leftLock = true;
bool rightLock = cl->AIMBOT_ACTIVATED_BY_ADS;
bool autoFire = cl->FEATURE_TRIGGERBOT_ON;
int boneID = 0;
int TotalSpectators = 0;
std::vector<std::string> Spectators;

void RenderUI() {
    auto io = ImGui::GetIO();
    ImGui::SetNextWindowSize(io.DisplaySize);
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::Begin("##Overlay", nullptr,
        ImGuiSliderFlags_AlwaysClamp |
        ImGuiWindowFlags_NoTitleBar |
        ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoScrollbar |
        ImGuiWindowFlags_NoBackground |
        ImGuiWindowFlags_NoSavedSettings |
        ImGuiWindowFlags_NoInputs);
    Canvas = ImGui::GetWindowDrawList();
    if (readError > 0) {
        sense->RenderStatus(0.0f, 0.0f, leftLock, rightLock, autoFire, boneID);
    } else {
        sense->RenderStatus(averageProcessingTime, averageFPS, leftLock, rightLock, autoFire, boneID);
        sense->RenderESP(Canvas, OverlayWindow);
        if (cl->FEATURE_MAP_RADAR_ON) sense->RenderRadar(Canvas);
        if (cl->FEATURE_SPECTATORS_ON) sense->RenderSpectators(counter, TotalSpectators, Spectators);
    }
    ImGui::End();
}

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

#include <pwd.h>
std::string GameVersion = OFF_GAME_VERSION;
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
                if (version == GameVersion) {
                    return false;
                }
            }

            currentPos = pathEnd;
        }
    }

    return true;
}

//_end
//_int main() {
int main(int argc, char* argv[]) { //_add
    if (getuid()) { std::cout << "RUN AS ROOT!\n"; return -1; }
    printf("Offsets.hpp %s\n", GameVersion.c_str()); //_add
    if (isOutdated()) { //_add
        printf("Please update Offsets.hpp and run install.sh from path/to/extracted/repository!\n"); //_add
        return -1; //_add
    } //_add
//_    if (mem::GetPID() == 0) { std::cout << "OPEN APEX LEGENDS!\n"; return -1; }
    system("mount -o remount,rw,hidepid=0 /proc"); //_add
    while (mem::GetPID() == 0) { //_add
        std::cout << "OPEN APEX LEGENDS!\n"; //_add
        std::this_thread::sleep_for(std::chrono::seconds(35)); //_add
    } //_add
    while (!map->isLobby && !map->isPlayable) { //_add
        std::cout << "." << std::flush; //_add
        std::this_thread::sleep_for(std::chrono::seconds(3)); //_add
        map->readFromMemory(); //_add
    } //_add
    if (map->isLobby) { //_add
        printf("Start in Lobby - Sleep 35 sec\n"); //_add
        std::this_thread::sleep_for(std::chrono::seconds(35)); //_add
    } //_add
    system("mount -o remount,rw,hidepid=2 /proc"); //_add

//_    ConfigLoader* cl = new ConfigLoader();
    MyDisplay* display = new MyDisplay();
//_    Level* map = new Level();
//_    LocalPlayer* localPlayer = new LocalPlayer();
    std::vector<Player*>* humanPlayers = new std::vector<Player*>;
    std::vector<Player*>* dummyPlayers = new std::vector<Player*>;
//_    std::vector<Player*>* players = new std::vector<Player*>;

    //fill in slots for players, dummies and items
//_    for (int i = 0; i < 60; i++) humanPlayers->push_back(new Player(cl, i, localPlayer));
//_    for (int i = 0; i < 15000; i++) dummyPlayers->push_back(new Player(cl, i, localPlayer));
    for (int i = 0; i < 70; i++) humanPlayers->push_back(new Player(cl, i, localPlayer)); //_add
    for (int i = 0; i < 10000; i++) dummyPlayers->push_back(new Player(cl, i, localPlayer)); //_add
    std::cout << "Core Initialized!" << std::endl; //_add

    //create features
//_    NoRecoil* noRecoil = new NoRecoil(cl, display, map, localPlayer);
//_    TriggerBot* triggerBot = new TriggerBot(cl, display, localPlayer, players);
//_    Sense* sense = new Sense(cl, map, localPlayer, players);
//_    Aim* aim = new Aim(cl, display, localPlayer, players);
    Aim* aim = new Aim(cl, display, localPlayer, players, GameCamera);
    Random* random = new Random(cl, display, map, localPlayer, players);

//_    int counter = 0;
    counter = 1; //_add
    cl->reloadFile(); //_add
    if (!InitializeOverlayWindow(argv[1])) //_add
        return -1; //_add
    if (cl->SENSE_VERBOSE < 2) OverlayWindow.DestroyOverlay(); //_add

    //while (!glfwWindowShouldClose(OverlayWindow)) { //_add
    while (true) {
        try {
            long startTime = util::currentEpochMillis();
            if (readError > 0) { //_add
                if (cl->SENSE_VERBOSE > 1) //_add
                    OverlayWindow.Render(&RenderUI); //_add
                display->kbRelease(cl->AIMBOT_FIRING_KEY); //_add
                keymap::AIMBOT_FIRING_KEY = false; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(readError)); //_add
                readError = 0; //_add
            } //_add
            if (cl->AIMBOT_ACTIVATED_BY_KEY && (cl->AIMBOT_ACTIVATION_KEY != "" || "NONE") && display->isKeyDown(cl->AIMBOT_ACTIVATION_KEY) || //_add
                cl->AIMBOT_ACTIVATED_BY_MOUSE && display->isLeftMouseButtonDown()) //_add
                keymap::AIMBOT_ACTIVATION_KEY = true; //_add
            else //_add
                keymap::AIMBOT_ACTIVATION_KEY = false; //_add
            int grenade = localPlayer->grenadeID; //_add
            int weapon = localPlayer->weaponIndex; //_add
            if (cl->AIMBOT_ACTIVATED_BY_MOUSE && display->isLeftMouseButtonDown() && ( //_add
                //grenade != -255 && grenade != -256 || //_add
                weapon == WEAPON_SENTINEL || //_add
                weapon == WEAPON_LONGBOW || //_add
                weapon == WEAPON_KRABER || //_add
                weapon == WEAPON_TRIPLE_TAKE)) { //_add
                std::chrono::milliseconds timeNow = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()); //_add
                if (timeNow > keymap::timeLastShot + std::chrono::milliseconds(125)) { //_add
                    display->kbPress(cl->AIMBOT_FIRING_KEY); //_add
                    display->kbRelease(cl->AIMBOT_FIRING_KEY); //_add
                    keymap::AIMBOT_FIRING_KEY = false; //_add
                    keymap::timeLastShot = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()); //_add
                } //_add
            } //_add
            if (display->isKeyDown("XK_Home")) { //_add
                system("mount -o remount,rw,hidepid=0 /proc"); //_add
                return -1; //_add
            } //_add
            if (display->isKeyDown("XK_Left")) { //_add
                leftLock = !leftLock; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add
            if (display->isKeyDown("XK_Right")) { //_add
                rightLock = !rightLock; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add
            if (display->isKeyDown("XK_Up")) { //_add
                autoFire = !autoFire; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add
            if (display->isKeyDown("XK_Down")) { //_add
                boneID++; //_add
                if (boneID > 2) boneID = 0; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add

//_            if (counter % 20 == 0) cl->reloadFile();
            map->readFromMemory();
            if (!map->isPlayable) {
//_                printf("Player in Lobby - Sleep 35 sec\n");
//_                std::this_thread::sleep_for(std::chrono::seconds(35));
                printf("Player in Lobby - Sleep 3 sec\n"); //_add
                readError = 3000; //_add
                continue;
            }

            localPlayer->readFromMemory(map);
//_            if (!localPlayer->isValid()) throw std::invalid_argument("Select Legend");
            if (!localPlayer->isValid()) { //_add
                printf("Select Legend - Sleep 3 sec\n"); //_add
                readError = 3000; //_add
                continue; //_add
            } //_add

            //read players
            players->clear();
            if (map->isTrainingArea)
                if (counter % 200 == 0) { //_add
                    playersCache->clear(); //_add
                    for (int i = 0; i < dummyPlayers->size(); i++) {
                        Player* p = dummyPlayers->at(i);
//_                        p->readFromMemory();
                        p->readFromMemory(counter); //_add
//_                        if (p->isValid()) players->push_back(p);
                        if (p->isValid()) { playersCache->push_back(p); players->push_back(p); } //_add
                    }
                } else { //_add
                    for (int i = 0; i < playersCache->size(); i++) { //_add
                        Player* p = playersCache->at(i); //_add
                        p->readFromMemory(counter); //_add
                        if (p->isValid()) players->push_back(p); //_add
                    } //_add
                } //_add
            else
                for (int i = 0; i < humanPlayers->size(); i++) {
                    Player* p = humanPlayers->at(i);
//_                    p->readFromMemory();
                    p->readFromMemory(counter); //_add
                    if (p->isValid()) players->push_back(p);
                }

//_            noRecoil->controlWeapon();
//_            triggerBot->shootAtEnemy(counter);
            GameCamera->Update(); //_add
//_            sense->update(counter);
//_            sense->itemGlow(counter);
//_            aim->update(counter);
            aim->update(counter, averageProcessingTime, leftLock, rightLock, autoFire, boneID, TotalSpectators); //_add
//_            random->runAll(counter);
            random->superGlide(averageFPS); //_add
            if (cl->SENSE_VERBOSE > 1) OverlayWindow.Render(&RenderUI); //_add

//_            int processingTime = static_cast<int>(util::currentEpochMillis() - startTime);
            processingTime = static_cast<int>(util::currentEpochMillis() - startTime); //_add
            int goalSleepTime = 16.67; // 16.67ms=60HZ | 6.97ms=144HZ
            int timeLeftToSleep = std::max(0, goalSleepTime - processingTime);
            std::this_thread::sleep_for(std::chrono::milliseconds(timeLeftToSleep));

            if (counter % 100 == 0) { //_add
                if (cl->SENSE_VERBOSE > 0) { //_add
                    if (cl->FEATURE_SPECTATORS_ON && !map->isTrainingArea) { //_add
                        int TempTotalSpectators = 0; //_add
                        std::vector<std::string> TempSpectators; //_add
                        for (int i = 0; i < players->size(); i++) { //_add
                            Player* p = players->at(i); //_add
                            if (p->base == localPlayer->base) //_add
                                continue; //_add
                            if (p->isSpectating()) { //_add
                                TempTotalSpectators++; //_add
                                TempSpectators.push_back(p->getPlayerName()); //_add
                                } else if (cl->FEATURE_SPECTATORS_SHOW_DEAD && p->isDead) { //_add
                                TempTotalSpectators++; //_add
                                TempSpectators.push_back("DEAD: " + p->getPlayerName()); //_add
                            } //_add
                        } //_add
                        TotalSpectators = TempTotalSpectators; //_add
                        Spectators = TempSpectators; //_add
                        printf("Spectators: %d\n", static_cast<int>(Spectators.size())); //_add
                        if (static_cast<int>(Spectators.size()) > 0) //_add
                            for (int i = 0; i < static_cast<int>(Spectators.size()); i++) //_add
                                printf("> %s\n", Spectators.at(i).c_str()); //_add
                    } //_add
                    printf("%d %d %d ", leftLock, autoFire, rightLock); //_add
                    if (boneID ==0) printf("BODY\n"); //_add
                    else if (boneID == 1) printf("NECK\n"); //_add
                    else printf("HEAD\n"); //_add
                } //_add
                //cl->reloadFile(); //_add
                processingTimes.push_back(processingTime); //_add
                if (processingTimes.size() > 10) //_add
                    processingTimes.erase(processingTimes.begin()); //_add
                averageProcessingTime = std::accumulate(processingTimes.begin(), processingTimes.end(), 0.0) / processingTimes.size(); //_add
                if (frameCountPrev != 0) { //_add
                    frameCountDiffs.push_back(localPlayer->frameCount - frameCountPrev); //_add
                    frameCountTimes.push_back(static_cast<int>(util::currentEpochMillis() - startTime)); //_add
                } //_add
                if (frameCountDiffs.size() > 10) //_add
                    frameCountDiffs.erase(frameCountDiffs.begin()); //_add
                if (frameCountTimes.size() > 10) //_add
                    frameCountTimes.erase(frameCountTimes.begin()); //_add
                averageFPS = std::accumulate(frameCountDiffs.begin(), frameCountDiffs.end(), 0.0) / std::accumulate(frameCountTimes.begin(), frameCountTimes.end(), 0.0) * 10; //_add
                frameCountPrev = localPlayer->frameCount; //_add
            } //_add
            //print loop info every now and then
            if (counter % 500 == 0)

                printf("| [%04d] - Time: %02dms |\n",
                    counter, processingTime);
            //update counter
//_            counter = (counter < 1000) ? ++counter : counter = 0;
            counter = (counter < 9999) ? ++counter : counter = 0; //_add
        }
        catch (std::invalid_argument& e) {
            printf("[-] %s - SLEEP 5 SEC [-]\n", e.what());
//_            std::this_thread::sleep_for(std::chrono::seconds(5));
            readError = 5000; //_add
        }
        catch (...) {
            printf("[-] UNKNOWN ERROR - SLEEP 3 SEC [-]\n");
//_            std::this_thread::sleep_for(std::chrono::seconds(3));
            readError = 3000; //_add
        }
    }
    //DestroyOverlay(); //_add
}
