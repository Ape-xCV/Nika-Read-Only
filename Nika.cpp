#include "includes.hpp"
//_begin
#include "Utils/Overlay.hpp"
#include "Utils/Camera.hpp"
Overlay OverlayWindow = Overlay();
Camera* GameCamera = new Camera();
ImDrawList* Canvas;

const void SetStyle() {
    ImGuiStyle& style = ImGui::GetStyle();
    //https://github.com/ocornut/imgui/issues/707#issuecomment-917151020
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

bool InitializeOverlayWindow() {
    if (!OverlayWindow.InitializeOverlay()) {
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
LocalPlayer* localPlayer = new LocalPlayer();
std::vector<Player*>* players = new std::vector<Player*>;
Sense* sense = new Sense(cl, map, localPlayer, players, GameCamera);
int counter;
int processingTime;
std::vector<int> processingTimes;
double averageProcessingTime;
bool readError;
bool leftLock = true;
bool rightLock = false;
bool autoFire = false;

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
    if (map->playable && localPlayer->isValid() && !readError) {
        sense->SpectatorsList(counter);
        sense->RenderESP(Canvas, OverlayWindow);
    }
    sense->RenderStatus(averageProcessingTime, leftLock, rightLock, autoFire);
    if (readError) {
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
        readError = false;
    }
    ImGui::End();
}

//_end
int main() {
    if (getuid()) { std::cout << "RUN AS SUDO!\n"; return -1; }
    if (mem::GetPID() == 0) { std::cout << "OPEN APEX LEGENDS!\n"; return -1; }

//_    ConfigLoader* cl = new ConfigLoader();
    MyDisplay* display = new MyDisplay();
//_    Level* map = new Level();
//_    LocalPlayer* localPlayer = new LocalPlayer();
    std::vector<Player*>* humanPlayers = new std::vector<Player*>;
    std::vector<Player*>* dummyPlayers = new std::vector<Player*>;
//_    std::vector<Player*>* players = new std::vector<Player*>;

    //fill in slots for players, dummies and items
    for (int i = 0; i < 60; i++) humanPlayers->push_back(new Player(i, localPlayer, cl));
    for (int i = 0; i < 15000; i++) dummyPlayers->push_back(new Player(i, localPlayer, cl));

    //create features     
    NoRecoil* noRecoil = new NoRecoil(cl, display, map, localPlayer);
    TriggerBot* triggerBot = new TriggerBot(cl, display, localPlayer, players);
//_    Sense* sense = new Sense(cl, map, localPlayer, players);
//_    Random* random = new Random(cl, display, map, localPlayer, players);
    Aim* aim = new Aim(display, localPlayer, players, cl);

//_    int counter = 0;
    counter = 1; //_add
    if (!InitializeOverlayWindow()) //_add
        return -1; //_add

    //while (!glfwWindowShouldClose(OverlayWindow)) { //_add
    while (true) {
        try {
            long startTime = util::currentEpochMillis();
            if (display->keyDown("XK_Left")) { //_add
                leftLock = !leftLock; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add
            if (display->keyDown("XK_Right")) { //_add
                rightLock = !rightLock; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add
            if (display->keyDown("XK_Up")) { //_add
                autoFire = !autoFire; //_add
                std::this_thread::sleep_for(std::chrono::milliseconds(250)); //_add
            } //_add

//_            if (counter % 20 == 0) cl->reloadFile();
            map->readFromMemory();
            if (!map->playable) {
                printf("Player in Lobby - Sleep 35 sec\n");
//_                std::this_thread::sleep_for(std::chrono::seconds(35));
                readError = true; //_add
                OverlayWindow.Render(&RenderUI); //_add
                continue;
            }

            localPlayer->readFromMemory(map);
//_            if (!localPlayer->isValid()) throw std::invalid_argument("Select Legend");
            if (!localPlayer->isValid()) { //_add
                printf("Select Legend\n"); //_add
                readError = true; //_add
                OverlayWindow.Render(&RenderUI); //_add
                continue; //_add
            } //_add

            //read players
            players->clear();
            if (map->trainingArea)
                for (int i = 0; i < dummyPlayers->size(); i++) {
                    Player* p = dummyPlayers->at(i);
                    p->readFromMemory();
//_                    if (p->isValid()) players->push_back(p);
                    if (p->isValid() && p->currentHealth > 0) players->push_back(p); //_add
                }
            else
                for (int i = 0; i < humanPlayers->size(); i++) {
                    Player* p = humanPlayers->at(i);
                    p->readFromMemory();
                    
                    if (p->isValid()) players->push_back(p);
                }

            GameCamera->Update(); //_add
            noRecoil->controlWeapon();
//_            triggerBot->shootAtEnemy(counter);
            triggerBot->shootAtEnemy(counter, autoFire);
//_            sense->update(counter);
//_            sense->itemGlow(counter);
//_            aim->update(counter);
            aim->update(counter, leftLock, rightLock); //_add
//_            random->runAll(counter);
            OverlayWindow.Render(&RenderUI); //_add

//_            int processingTime = static_cast<int>(util::currentEpochMillis() - startTime);
            processingTime = static_cast<int>(util::currentEpochMillis() - startTime); //_add
            int goalSleepTime = 6.97; // 16.67ms=60HZ | 6.97ms=144HZ
            int timeLeftToSleep = std::max(0, goalSleepTime - processingTime);
            std::this_thread::sleep_for(std::chrono::milliseconds(timeLeftToSleep));

            if (counter % 100 == 0) { //_add
                cl->reloadFile(); //_add
                processingTimes.push_back(processingTime); //_add
                if (processingTimes.size() > 10) //_add
                    processingTimes.erase(processingTimes.begin()); //_add
                averageProcessingTime = std::accumulate(processingTimes.begin(), processingTimes.end(), 0.0) / processingTimes.size(); //_add
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
            readError = true; //_add
        }
        catch (...) {
            printf("[-] UNKNOWN ERROR - SLEEP 3 SEC [-]\n");
//_            std::this_thread::sleep_for(std::chrono::seconds(3));
            readError = true; //_add
        }
    }
    //DestroyOverlay(); //_add
}
