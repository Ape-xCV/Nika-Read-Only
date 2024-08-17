#pragma once
#include "imgui/imgui.h" //_add
#include "imgui/imgui_impl_glfw.h" //_add
#include "imgui/imgui_impl_opengl3.h" //_add
#include "Utils/Overlay.hpp" //_add
#include "Utils/Camera.hpp" //_add
struct Sense {
    ConfigLoader* cl;
    Level* map;
    LocalPlayer* lp;
    std::vector<Player*>* players;
    Camera* GameCamera; //_add
    int TotalSpectators = 0; //_add
    std::vector<std::string> Spectators; //_add
    Vector2D DrawPosition; //_add

//_    Sense(ConfigLoader* configLoada, Level* level, LocalPlayer* localPlayer, std::vector<Player*>* all_players) {
    Sense(ConfigLoader* configLoada, Level* level, LocalPlayer* localPlayer, std::vector<Player*>* all_players, Camera* GameCamera) { //_add
        this->cl = configLoada;
        this->map = level;
        this->lp = localPlayer;
        this->players = all_players;
        this->GameCamera = GameCamera; //_add
    }

//_begin
    void RenderStatus(double averageProcessingTime, double averageFPS, bool leftLock, bool rightLock, bool autoFire, int boneID) {
        ImGui::SetNextWindowPos(ImVec2(10.0f, 25.0f), ImGuiCond_Once, ImVec2(0.02f, 0.5f));
        ImGui::SetNextWindowBgAlpha(0.50f);
        ImGui::Begin("Status", nullptr,
            ImGuiWindowFlags_NoTitleBar |
            ImGuiWindowFlags_NoMove |
            ImGuiWindowFlags_NoScrollbar |
            ImGuiWindowFlags_NoCollapse |
            ImGuiWindowFlags_AlwaysAutoResize |
            ImGuiWindowFlags_NoSavedSettings |
            ImGuiWindowFlags_NoInputs);
        const ImGuiStyle& style = ImGui::GetStyle();

        const ImVec4 leftLockColor = leftLock ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        const ImVec4 rightLockColor = rightLock ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        const ImVec4 autoFireColor = autoFire ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        const ImVec4 boneIDColor = ImVec4(1, 1, 0.343, 1);
        const ImVec4 processingTimeColor = averageProcessingTime < 20 ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        ImGui::TextColored(leftLockColor, "< ");
        ImGui::SameLine();
        ImGui::TextColored(autoFireColor, "^ ");
        ImGui::SameLine();
        ImGui::TextColored(rightLockColor, "> ");
        ImGui::SameLine();
        ImGui::Text("hitbox: ");
        ImGui::SameLine();
        if (boneID == 0) ImGui::TextColored(boneIDColor, "BODY ");
        else if (boneID == 1) ImGui::TextColored(boneIDColor, "NECK ");
        else ImGui::TextColored(boneIDColor, "HEAD ");
        ImGui::SameLine();
        ImGui::Text("interval: ");
        ImGui::SameLine();
        ImGui::TextColored(processingTimeColor, "%.2fms ", averageProcessingTime);
        ImGui::SameLine();
        ImGui::Text("fps: %.2f", averageFPS);
        ImGui::End();
    }

    void RenderSpectators(int counter, int TotalSpectators, std::vector<std::string> Spectators) {
        ImVec2 Center = ImGui::GetMainViewport()->GetCenter();
        ImGui::SetNextWindowPos(ImVec2(0.0f, Center.y), ImGuiCond_Once, ImVec2(0.02f, 0.5f));
        ImGui::SetNextWindowBgAlpha(0.3f);
        ImGui::Begin("Spectators", nullptr,
            ImGuiWindowFlags_NoTitleBar |
            ImGuiWindowFlags_NoMove |
            ImGuiWindowFlags_NoScrollbar |
            ImGuiWindowFlags_NoCollapse |
            ImGuiWindowFlags_AlwaysAutoResize |
            ImGuiWindowFlags_NoSavedSettings |
            ImGuiWindowFlags_NoInputs);

        ImGui::Text("Spectators: ");
        ImGui::SameLine(); ImGui::TextColored(TotalSpectators > 0 ? ImVec4(1, 0.343, 0.475, 1) : ImVec4(0.4, 1, 0.343, 1), "%d", TotalSpectators);
        if (static_cast<int>(Spectators.size()) > 0) {
            ImGui::Separator();
            for (int i = 0; i < static_cast<int>(Spectators.size()); i++)
                ImGui::TextColored(ImVec4(1, 0.343, 0.475, 1), "> %s", Spectators.at(i).c_str());
        }
        ImGui::End();
    }

    void drawText(ImDrawList* Canvas, Vector2D textPosition, const char* text, ImVec4 color) {
        int textX = textPosition.x;
        int textY = textPosition.y;
        char buffer[15];
        strncpy(buffer, text, sizeof(buffer));
        const auto textSize = ImGui::CalcTextSize(buffer);
        const auto horizontalOffset = textSize.x / 2;
        const auto verticalOffset = textSize.y - 20;
        const auto textColor = ImColor(color);

        glColor3f(0, 0, 0);
        glBegin(GL_QUADS);
        glVertex2f(textX - horizontalOffset - 3, textY + 3);
        glVertex2f(textX + horizontalOffset + 1, textY + 3);
        glVertex2f(textX + horizontalOffset + 1, textY + textSize.y - 1);
        glVertex2f(textX - horizontalOffset - 3, textY + textSize.y - 1);
        glEnd();
        Canvas->AddText({ textPosition.x - horizontalOffset, textPosition.y - verticalOffset }, textColor, buffer);
    }

    void RenderESP(ImDrawList* Canvas, Overlay OverlayWindow) {
        int screenWidth;
        int screenHeight;
        OverlayWindow.GetScreenResolution(screenWidth, screenHeight);

        bool DrawVisibleWarning = false;
        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!cl->SENSE_SHOW_DEAD && !p->currentHealth > 0) continue;

            Vector2D LocalOriginW2S, HeadPositionW2S, AboveHeadW2S;
            Vector3D LocalOrigin3D = p->localOrigin;
            Vector3D HeadPosition3D = p->GetBonePosition(HitboxType::Head);
            Vector3D AboveHead3D = HeadPosition3D;
            AboveHead3D.z += 10.f; // Y Offset

            bool bLocalOriginW2SValid = GameCamera->WorldToScreen(LocalOrigin3D, LocalOriginW2S);
            bool bHeadPositionW2SValid = GameCamera->WorldToScreen(HeadPosition3D, HeadPositionW2S);
            GameCamera->WorldToScreen(AboveHead3D, AboveHeadW2S);

            // Colors - Players (Enemy)
            ImVec4 EnemyBoxColor, EnemyDistanceColor;
            if (!p->isKnocked && p->visible) {
                EnemyBoxColor = ImVec4(0, 0.99, 0, 0.99);
                EnemyDistanceColor = ImVec4(0, 0.99, 0, 0.99);
            } else if (!p->isKnocked && !p->visible) {
                EnemyBoxColor = ImVec4(0.99, 0, 0, 0.99);
                EnemyDistanceColor = ImVec4(0.99, 0, 0, 0.99);
            } else if (p->isKnocked) {
                EnemyBoxColor = ImVec4(0.99, 0.671, 0.119, 0.99);
                EnemyDistanceColor = ImVec4(0.99, 0.671, 0.119, 0.99);
            }

            float distance = util::inchesToMeters(p->distance2DToLocalPlayer);
            if (!p->local && p->enemy && p->isValid() && distance < cl->SENSE_MAX_RANGE) {

                // Draw Boxes
                if (bLocalOriginW2SValid && bHeadPositionW2SValid) {
                    Vector2D foot = LocalOriginW2S;
                    Vector2D head = HeadPositionW2S;
                    float height = head.y - foot.y;
                    float width = height / 2;
                    glColor3f(EnemyBoxColor.x, EnemyBoxColor.y, EnemyBoxColor.z);
                    glLineWidth(1.5f);
                    glBegin(GL_LINE_LOOP);
                    glVertex2f(foot.x - width/2, foot.y);
                    glVertex2f(foot.x - width/2, head.y + height/5);
                    glVertex2f(head.x + width/2, head.y + height/5);
                    glVertex2f(head.x + width/2, foot.y);
                    glEnd();
                    //Canvas->AddRect(ImVec2(foot.x - (width / 2), foot.y), ImVec2(head.x + (width / 2), head.y + (height / 5)), ImColor(EnemyBoxColor), 0.0f, 0, 2);

                    int life = p->currentHealth;
                    int evo = p->currentShields;
                    if (evo > 100) glColor3f(1.0f, 0.25f, 0.0f); // red shield
                    else if (evo > 75) glColor3f(1.0f, 0.25f, 1.0f); // purple shield
                    else if (evo > 50) glColor3f(0.0f, 0.75f, 1.0f); // blue shield
                    else if (evo > 0) glColor3f(1.0f, 1.0f, 1.0f); // white shield
                    else glColor3f(1.0f, 1.0f, 0.0f); // no shield

                    glLineWidth(5.0f);
                    glBegin(GL_LINES);
                    glVertex2f(head.x + width/2 - 5.0f, foot.y);
                    glVertex2f(head.x + width/2 - 5.0f, foot.y + (height + height/5) * life/100);
                    glEnd();
                }

                DrawPosition = AboveHeadW2S.Subtract(Vector2D(0, 10));
                if (bLocalOriginW2SValid && bHeadPositionW2SValid && !LocalOriginW2S.IsZeroVector()) {
                    // Draw Distance
                    if (cl->SENSE_SHOW_PLAYER_DISTANCES) {
                        DrawPosition = DrawPosition.Subtract(Vector2D(0, 20));
                        const char* txtPrefix = "[";
                        const char* txtDistance = std::to_string((int)distance).c_str();
                        const char* txtSuffix = " M]";
                        char distanceText[256];
                        strncpy(distanceText, txtPrefix, sizeof(distanceText));
                        strncat(distanceText, txtDistance, sizeof(distanceText));
                        strncat(distanceText, txtSuffix, sizeof(distanceText));
                        drawText(Canvas, DrawPosition, distanceText, EnemyDistanceColor);
                    }

                    // Draw Name
                    if (cl->SENSE_SHOW_PLAYER_NAMES) {
                        DrawPosition = DrawPosition.Subtract(Vector2D(0, 20));
                        const char* txtName;
                        if (p->isPlayer())
                            txtName = p->getPlayerName().c_str();
                        else if (p->isDummie())
                            txtName = "Dummie";
                        char nameText[256];
                        strncpy(nameText, txtName, sizeof(nameText));
                        drawText(Canvas, DrawPosition, nameText, EnemyDistanceColor);
                    }

                    // Draw Level
                    if (cl->SENSE_SHOW_PLAYER_LEVELS && p->isPlayer()) {
                        DrawPosition = DrawPosition.Subtract(Vector2D(0, 20));
                        const char* txtPrefix = "Lv ";
                        const char* txtLevel = std::to_string(p->GetPlayerLevel()).c_str();
                        //const char* txtSuffix = "";
                        char levelText[256];
                        strncpy(levelText, txtPrefix, sizeof(levelText));
                        strncat(levelText, txtLevel, sizeof(levelText));
                        //strncat(levelText, txtSuffix, sizeof(levelText));
                        drawText(Canvas, DrawPosition, levelText, EnemyDistanceColor);
                    }
                }

                // Draw Warning
                if (p->visible && !p->isKnocked)
                    DrawVisibleWarning = true;
            }
        }

        if (DrawVisibleWarning) {
            ImVec4 warningColor = ImColor(ImVec4(0, 0.99, 0, 0.99));
            DrawPosition = Vector2D(screenWidth / 2, screenHeight * 3/4);
            const char* txtWarning;
            txtWarning = "VISIBLE WARNING";
            char warningText[256];
            strncpy(warningText, txtWarning, sizeof(warningText));
            drawText(Canvas, DrawPosition, warningText, warningColor);
        }

        // Draw FOV
        if (cl->SENSE_SHOW_FOV && lp->inZoom) {
            ImVec2 center(screenWidth / 2, screenHeight / 2);
            int radius = screenHeight / 60 * cl->AIMBOT_FOV;
            radius += radius * (60 / lp->zoomFOV) * cl->AIMBOT_FOV_EXTRA_BY_DISTANCE;
            Canvas->AddCircle(center, radius, ImColor(ImVec4(0.99, 0.99, 0.99, 0.99)));
        }
    }

    static Vector3D RotatePoint(Vector3D LocalPlayerPos, Vector3D PlayerPos, int posX, int posY, int sizeX, int sizeY, float angle, float zoom, bool* viewCheck) {
        float r_1, r_2;
        float x_1, y_1;

        r_1 = -(PlayerPos.y - LocalPlayerPos.y);
        r_2 = PlayerPos.x - LocalPlayerPos.x;

        float yawToRadian = angle * (float)(M_PI / 180.0f);
        x_1 = (float)(r_2 * (float)cos((double)(yawToRadian)) - r_1 * sin((double)(yawToRadian))) / 20;
        y_1 = (float)(r_2 * (float)sin((double)(yawToRadian)) + r_1 * cos((double)(yawToRadian))) / 20;

        *viewCheck = y_1 < 0;

        x_1 *= zoom;
        y_1 *= zoom;

        x_1 += sizeX / 2;
        y_1 += sizeY / 2;

        if (x_1 < 5)
            x_1 = 5;

        if (x_1 > sizeX - 5)
            x_1 = sizeX - 5;

        if (y_1 < 5)
            y_1 = 5;

        if (y_1 > sizeY - 5)
            y_1 = sizeY - 5;

        x_1 += posX;
        y_1 += posY;

        return Vector3D(x_1, y_1, 0);
    }

    void RenderRadar(ImDrawList* Canvas) {
        // 1920*1080: 215 x 215
        // 2560*1440: 335 x 335
        ImGui::SetNextWindowSize({ cl->FEATURE_MAP_RADAR_X, cl->FEATURE_MAP_RADAR_Y });
        ImGui::Begin("Radar", nullptr,
            ImGuiWindowFlags_NoTitleBar |
            ImGuiWindowFlags_NoResize |
            ImGuiWindowFlags_NoMove |
            ImGuiWindowFlags_NoScrollbar |
            ImGuiWindowFlags_NoCollapse |
            ImGuiWindowFlags_NoBackground |
            ImGuiWindowFlags_NoSavedSettings |
            ImGuiWindowFlags_NoBringToFrontOnFocus |
            ImGuiWindowFlags_NoInputs);

        ImVec2 drawPos = ImGui::GetCursorScreenPos();
        ImVec2 drawSize = ImGui::GetContentRegionAvail();
        ImVec2 midRadar = ImVec2(drawPos.x + (drawSize.x / 2), drawPos.y + (drawSize.y / 2));
        ImVec2 startHorizontal(midRadar.x - drawSize.x / 2, midRadar.y);
        ImVec2 endHorizontal(midRadar.x + drawSize.x / 2, midRadar.y);
        ImVec2 startVertical(midRadar.x, midRadar.y - drawSize.y / 2);
        ImVec2 endVertical(midRadar.x, midRadar.y + drawSize.y / 2);

        glColor3f(0.99, 0.99, 0.99);
        glLineWidth(1.0f);
        glBegin(GL_LINES);
        glVertex2f(startHorizontal.x, midRadar.y);
        glVertex2f(endHorizontal.x, midRadar.y);
        glVertex2f(midRadar.x, startVertical.y);
        glVertex2f(midRadar.x, endVertical.y);
        glEnd();

        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!p->enemy || !p->isValid() || p->base == lp->base)
                continue;

            float radarDistance = util::inchesToMeters(p->distance2DToLocalPlayer);
            if (radarDistance >= 0.0f && radarDistance < cl->SENSE_MAX_RANGE) {
                bool viewCheck = false;
                Vector3D single = RotatePoint(lp->localOrigin, p->localOrigin, drawPos.x, drawPos.y, drawSize.x, drawSize.y, p->viewAngles.y, 0.3f, &viewCheck);

                ImVec2 center(single.x, single.y);
                int radius = 5;
                Canvas->AddCircleFilled(center, radius, ImColor(ImVec4(0.99, 0, 0.99, 0.99)));
                if (p->visible)
                    Canvas->AddCircle(center, radius + 2, ImColor(ImVec4(0.99, 0.99, 0, 0.99)));

                // Draw a line pointing in the direction of each player's aim
                float angle = (360.0f - p->viewYaw) * (M_PI / 180.0f);
                ImVec2 endpoint(center.x + radius * cos(angle), center.y + radius * sin(angle));
                Canvas->AddLine(center, endpoint, ImColor(ImVec4(0, 0, 0, 0.99)));
            }
        }
        ImGui::End();
    }

//_end
    void update(int counter){
        if (!map->isPlayable)
            return;
        if(!cl->FEATURE_SENSE_ON)
            return;
        for (std::size_t i = 0; i < players->size(); i++) {
            Player *p = players->at(i);
            if (!p->isValid())
                continue;
            if (p->friendly) 
                continue;

            float distance = util::inchesToMeters(p->distance2DToLocalPlayer);
            if (!p->visible && !p->isKnocked && distance < cl->SENSE_MAX_RANGE) {
                p->setGlowEnable(1);
                p->setGlowThroughWall(1);
//_                int healthShield = p->currentHealth + p->currentShields;
//_                p->setCustomGlow(healthShield, true, false);
            } else if (distance <  cl->SENSE_MAX_RANGE) {
                p->setGlowEnable(1);
                p->setGlowThroughWall(1);
                p->setCustomGlow(0, false, false);
            } else if (p->getGlowEnable() == 1 && p->getGlowThroughWall() == 1) {
                p->setGlowEnable(0);
                p->setGlowThroughWall(0);
            }
        }
    }

    void itemGlow(int counter){
        if (!map->isPlayable)
            return;
        if (!cl->FEATURE_ITEM_GLOW_ON)
            return;
        for (int highlightId = 15; highlightId < 65; highlightId++) {
            const GlowMode newGlowMode = { 137,0,0,127 };
//_            const GlowMode oldGlowMode = mem::Read<GlowMode>(lp->highlightSettingsPtr + (HIGHLIGHT_TYPE_SIZE * highlightId) + 0, "Player oldGlowMode");
//_            if (newGlowMode != oldGlowMode)
//_                mem::Write<GlowMode>(lp->highlightSettingsPtr + (HIGHLIGHT_TYPE_SIZE * highlightId) + 0, newGlowMode);
        }
    }
};
