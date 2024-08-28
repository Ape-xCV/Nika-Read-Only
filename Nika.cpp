#include "includes.hpp"

// Create basic objects
ConfigLoader* configLoader = new ConfigLoader();
XDisplay* myDisplay = new XDisplay();
Level* map = new Level();
LocalPlayer* localPlayer = new LocalPlayer(configLoader);
std::vector<Player*>* humanPlayers = new std::vector<Player*>;
std::vector<Player*>* dummyPlayers = new std::vector<Player*>;
std::vector<Player*>* players = new std::vector<Player*>;
std::vector<Player*>* playersCache = new std::vector<Player*>;
Overlay overlayWindow = Overlay();
Camera* gameCamera = new Camera();
ImDrawList* canvas;

// Create features
AimBot* aimBot = new AimBot(configLoader, myDisplay, localPlayer, players, gameCamera);
Sense* sense = new Sense(configLoader, localPlayer, players, gameCamera, aimBot);
Other* other = new Other(configLoader, myDisplay, map, localPlayer, players);

int counter = 1;
int readError = 1000;
int processingTime;
std::vector<int> processingTimes;
double averageProcessingTime;
int frameCountPrev;
std::vector<int> frameCountDiffs;
std::vector<int> frameCountTimes;
double averageFps;
bool leftLock = true;
bool rightLock = configLoader->AIMBOT_ACTIVATED_BY_ADS;
bool autoFire = configLoader->FEATURE_TRIGGERBOT_ON;
int boneId = 2;
int totalSpectators = 0;
std::vector<std::string> spectators;

bool initializeOverlayWindow(const char* overlayTitle) {
    if (!overlayWindow.InitializeOverlay(overlayTitle)) {
        overlayWindow.DestroyOverlay();
        return false;
    }
    overlayWindow.SetStyle();
    overlayWindow.CaptureInput(false);
    int screenWidth;
    int screenHeight;
    overlayWindow.GetScreenResolution(screenWidth, screenHeight);
    gameCamera->initialize(screenWidth, screenHeight);
    std::cout << "Overlay Initialized!" << std::endl;
    return true;
}

void renderUI() {
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
    canvas = ImGui::GetWindowDrawList();
    if (readError > 0) {
        sense->renderStatus(0.0f, 0.0f, leftLock, rightLock, autoFire, boneId);
    } else {
        sense->renderStatus(averageProcessingTime, averageFps, leftLock, rightLock, autoFire, boneId);
        sense->renderESP(canvas);
        if (configLoader->FEATURE_MAP_RADAR_ON) sense->renderRadar(canvas);
        if (configLoader->FEATURE_SPECTATORS_ON) sense->renderSpectators(totalSpectators, spectators);
    }
    ImGui::End();
}

int main(int argc, char* argv[]) {
    if (getuid()) { std::cout << "RUN AS ROOT!\n"; return -1; }
    printf("Offsets.hpp %s\n", OFF_GAME_VERSION.c_str());
    //if (util::isOutdated()) { std::cout << "Please update Offsets.hpp and run install.sh from path/to/extracted/repository!\n"; return -1; }
    if (util::isOutdated()) { std::cout << "Press ENTER to continue\n"; system("read"); }

    system("mount -o remount,rw,hidepid=0 /proc");
    while (mem::getPid() == 0) {
        std::cout << "OPEN APEX LEGENDS!\n";
        util::sleep(35000);
    }
    while (!map->isLobby && !map->isPlayable) {
        std::cout << "." << std::flush;
        util::sleep(3000);
        map->readFromMemory();
    }
    if (map->isLobby) {
        std::cout << "Start in Lobby - Sleep 35 sec\n";
        util::sleep(35000); // std::this_thread::sleep_for(std::chrono::seconds(35));
    }
    system("mount -o remount,rw,hidepid=2 /proc");

    // Fill in slots for players, dummies and items
    for (int i = 0; i < 70; i++) humanPlayers->push_back(new Player(i));
    for (int i = 0; i < 10000; i++) dummyPlayers->push_back(new Player(i));
    std::cout << "Core Initialized!" << std::endl;

    // Load config
    configLoader->reloadFile();

    if (!initializeOverlayWindow(argv[1])) return -1;
    if (configLoader->SENSE_VERBOSE < 2) overlayWindow.DestroyOverlay();

    // Begin main loop
    while (true) {
        try {
            long startTime = util::currentEpochMillis();
            if (readError > 0) {
                myDisplay->kbRelease(configLoader->AIMBOT_FIRING_KEY);
                keymap::AIMBOT_FIRING_KEY = false;
                playersCache->clear();
            }

            while (true) {
                if (myDisplay->isKeyDown("XK_Home")) { system("mount -o remount,rw,hidepid=0 /proc"); return -1; }
                if (myDisplay->isKeyDown("XK_Left")) { leftLock = !leftLock; util::sleep(250); }
                if (myDisplay->isKeyDown("XK_Right")) { rightLock = !rightLock; util::sleep(250); }
                if (myDisplay->isKeyDown("XK_Up")) { autoFire = !autoFire; util::sleep(250); }
                if (myDisplay->isKeyDown("XK_Down")) {
                    boneId--;
                    if (boneId < 0) boneId = 2;
                    util::sleep(250);
                }
                if (readError > 0) {
                    if (configLoader->SENSE_VERBOSE > 1) overlayWindow.Render(&renderUI);
                    util::sleep(50);
                    readError -= 50;
                } else { break; }
            }

            // Read map and make sure it is playable
            map->readFromMemory();
            if (!map->isPlayable) {
                std::cout << "Player in Lobby - Sleep 3 sec\n";
                readError = 3000;
                continue;
            }

            // Read localPlayer and make sure it is valid
            localPlayer->readFromMemory();
            if (!localPlayer->isValid()) {
                std::cout << "Select Legend - Sleep 3 sec\n";
                readError = 3000;
                continue;
            }

            if (configLoader->AIMBOT_ACTIVATED_BY_KEY && (configLoader->AIMBOT_ACTIVATION_KEY != "" || "NONE") && myDisplay->isKeyDown(configLoader->AIMBOT_ACTIVATION_KEY) ||
                configLoader->AIMBOT_ACTIVATED_BY_MOUSE && myDisplay->isLeftMouseButtonDown())
                keymap::AIMBOT_ACTIVATION_KEY = true;
            else
                keymap::AIMBOT_ACTIVATION_KEY = false;
            int weapon = localPlayer->weaponId;
            if (configLoader->AIMBOT_ACTIVATED_BY_MOUSE && myDisplay->isLeftMouseButtonDown() && (
                weapon == WEAPON_SENTINEL ||
                weapon == WEAPON_LONGBOW ||
                weapon == WEAPON_KRABER ||
                weapon == WEAPON_TRIPLE_TAKE)) {
                std::chrono::milliseconds timeNow = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
                if (timeNow > keymap::timeLastShot + std::chrono::milliseconds(125)) {
                    myDisplay->kbPress(configLoader->AIMBOT_FIRING_KEY);
                    myDisplay->kbRelease(configLoader->AIMBOT_FIRING_KEY);
                    keymap::AIMBOT_FIRING_KEY = false;
                    keymap::timeLastShot = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
                }
            }

            // Read players
            players->clear();
            if (counter % 99 == 0) {
                playersCache->clear();
                for (int i = 0; i < dummyPlayers->size(); i++) {
                    Player* p = dummyPlayers->at(i);
                    p->readFromMemory(configLoader, counter, localPlayer, map);
                    if (p->isValid()) { playersCache->push_back(p); players->push_back(p); }
                }

                if (configLoader->SENSE_VERBOSE > 0) {
                    printf("Entities: %d\n", playersCache->size());

                    if (configLoader->FEATURE_SPECTATORS_ON) {
                        int tempTotalSpectators = 0;
                        std::vector<std::string> tempSpectators;
                        for (int i = 0; i < players->size(); i++) {
                            Player* p = players->at(i);
                            if (p->base == localPlayer->base)
                                continue;
                            if (p->spctrBase == localPlayer->base) {
                                tempTotalSpectators++;
                                tempSpectators.push_back(p->getPlayerName());
                                } else if (configLoader->FEATURE_SPECTATORS_SHOW_DEAD && p->isDead) {
                                tempTotalSpectators++;
                                tempSpectators.push_back("DEAD: " + p->getPlayerName());
                            }
                        }
                        totalSpectators = tempTotalSpectators;
                        spectators = tempSpectators;
                        printf("Spectators: %d\n", static_cast<int>(spectators.size()));
                        if (static_cast<int>(spectators.size()) > 0)
                            for (int i = 0; i < static_cast<int>(spectators.size()); i++)
                                printf("> %s\n", spectators.at(i).c_str());
                    }
                }
            } else {
                for (int i = 0; i < playersCache->size(); i++) {
                    Player* p = playersCache->at(i);
                    p->readFromMemory(configLoader, counter, localPlayer, map);
                    if (p->isValid()) players->push_back(p);
                }
            }

            // Run features
            gameCamera->update();
            aimBot->update(leftLock, rightLock, autoFire, boneId, totalSpectators);
            other->superGlide(averageFps);

            if (configLoader->SENSE_VERBOSE > 1) overlayWindow.Render(&renderUI);
            processingTime = static_cast<int>(util::currentEpochMillis() - startTime);
            int goalSleepTime = 16.67; // 16.67ms=60Hz | 6.94ms=144Hz
            int timeLeftToSleep = std::max(0, goalSleepTime - processingTime);
            util::sleep(timeLeftToSleep);
            if (counter % 100 == 0) {
                if (configLoader->SENSE_VERBOSE > 0) {
                    printf("%d %d %d ", leftLock, autoFire, rightLock);
                    if (boneId == 0) printf("HEAD\n");
                    else if (boneId == 1) printf("NECK\n");
                    else printf("BODY\n");
                }
                processingTimes.push_back(processingTime);
                if (processingTimes.size() > 10) processingTimes.erase(processingTimes.begin());
                averageProcessingTime = std::accumulate(processingTimes.begin(), processingTimes.end(), 0.0f) / processingTimes.size();
                if (frameCountPrev != 0) {
                    frameCountDiffs.push_back(localPlayer->frameCount - frameCountPrev);
                    frameCountTimes.push_back(static_cast<int>(util::currentEpochMillis() - startTime));
                }
                if (frameCountDiffs.size() > 10)
                    frameCountDiffs.erase(frameCountDiffs.begin());
                if (frameCountTimes.size() > 10)
                    frameCountTimes.erase(frameCountTimes.begin());
                averageFps = std::accumulate(frameCountDiffs.begin(), frameCountDiffs.end(), 0.0f) / std::accumulate(frameCountTimes.begin(), frameCountTimes.end(), 0.0f) * 10;
                frameCountPrev = localPlayer->frameCount;
            }

            // Print loop info every now and then
            if (configLoader->SENSE_VERBOSE > 0 && counter % 500 == 0)
                printf("| [%04d] - Time: %02dms |\n", counter, processingTime);

            // Update counter
            counter = (counter >= 9999) ? counter = 0 : ++counter;
        }
        catch (std::invalid_argument& e) {
            printf("[-] %s - SLEEP 5 SEC [-]\n", e.what());
            readError = 5000;
        }
        catch (...) {
            printf("[-] UNKNOWN ERROR - SLEEP 3 SEC [-]\n");
            readError = 3000;
        }
    }
}
