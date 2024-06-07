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
    int TotalSpectators = 0; //_add
    std::vector<std::string> Spectators; //_add
    Camera* GameCamera; //_add

//_    Sense(ConfigLoader* configLoada, Level* level, LocalPlayer* localPlayer, std::vector<Player*>* all_players) {
    Sense(ConfigLoader* configLoada, Level* level, LocalPlayer* localPlayer, std::vector<Player*>* all_players, Camera* GameCamera) { //_add
        this->cl = configLoada;
        this->map = level;
        this->lp = localPlayer;
        this->players = all_players;
        this->GameCamera = GameCamera; //_add
    }

//_begin
    void RenderStatus(double averageProcessingTime, bool leftLock, bool rightLock, bool autoFire) {
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
        const ImVec4 processingTimeColor = averageProcessingTime < 20 ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        ImGui::TextColored(leftLockColor, "< ");
        ImGui::SameLine();
        ImGui::TextColored(autoFireColor, "^ ");
        ImGui::SameLine();
        ImGui::TextColored(rightLockColor, "> ");
        ImGui::SameLine();
        ImGui::Text("interval: ");
        ImGui::SameLine();
        ImGui::TextColored(processingTimeColor, "%.2fms", averageProcessingTime);
        ImGui::End();
    }

    void SpectatorsList(int counter) {
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

        if (counter % 100 == 0) {
            int TempTotalSpectators = 0;
            std::vector<std::string> TempSpectators;
            for (int i = 0; i < players->size(); i++) {
                Player* p = players->at(i);
                if (p->base == lp->base)
                    continue;
                if (p->isSpectating()) {
                    TempTotalSpectators++;
                    TempSpectators.push_back(p->getPlayerName());
                } //else if (p->dead) {
//                    TempTotalSpectators++;
//                    TempSpectators.push_back("DEAD: " + p->getPlayerName());
//                }
            }
            TotalSpectators = TempTotalSpectators;
            Spectators = TempSpectators;
        }
        ImGui::Text("Spectators: ");
        ImGui::SameLine(); ImGui::TextColored(TotalSpectators > 0 ? ImVec4(1, 0.343, 0.475, 1) : ImVec4(0.4, 1, 0.343, 1), "%d", TotalSpectators);
        if (static_cast<int>(Spectators.size()) > 0) {
            ImGui::Separator();
            for (int i = 0; i < static_cast<int>(Spectators.size()); i++)
                ImGui::TextColored(ImVec4(1, 0.343, 0.475, 1), "> %s", Spectators.at(i).c_str());
        }
        ImGui::End();
    }

    void RenderESP(ImDrawList* Canvas, Overlay OverlayWindow) {
        int screenWidth;
        int screenHeight;
        OverlayWindow.GetScreenResolution(screenWidth, screenHeight);

        bool DrawVisibleWarning = false;
        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);

            Vector2D LocalOriginW2S, HeadPositionW2S, AboveHeadW2S;
            Vector3D LocalOrigin3D = p->localOrigin;
            Vector3D Head3D = p->GetBonePosition(HitboxType::Head);
            Vector3D AboveHead3D = Head3D;
            AboveHead3D.z += 10.f; // Y Offset

            bool bLocalOriginW2SValid = GameCamera->WorldToScreen(LocalOrigin3D, LocalOriginW2S);
            bool bHeadPositionW2SValid = GameCamera->WorldToScreen(Head3D, HeadPositionW2S);
            GameCamera->WorldToScreen(AboveHead3D, AboveHeadW2S);

            // Colors - Players (Enemy)
            ImVec4 EnemyBoxColor, EnemyDistanceColor;
            if (!p->knocked && p->visible) {
                EnemyBoxColor = ImVec4(0, 0.99, 0, 0.99);
                EnemyDistanceColor = ImVec4(0, 0.99, 0, 0.99);
            } else if (!p->knocked && !p->visible) {
                EnemyBoxColor = ImVec4(0.99, 0, 0, 0.99);
                EnemyDistanceColor = ImVec4(0.99, 0, 0, 0.99);
            } else if (p->knocked) {
                EnemyBoxColor = ImVec4(0.990, 0.671, 0.119, 0.99);
                EnemyDistanceColor = ImVec4(0.990, 0.671, 0.119, 0.99);
            }

            double distance = math::calculateDistanceInMeters(
                lp->localOrigin.x,
                lp->localOrigin.y,
                lp->localOrigin.z,
                p->localOrigin.x,
                p->localOrigin.y,
                p->localOrigin.z);
            if (!p->local && p->enemy && p->isValid() && distance < cl->SENSE_MAXRANGE) {

                // Draw Boxes
                if (bLocalOriginW2SValid && bHeadPositionW2SValid) {
                    Vector2D foot = LocalOriginW2S;
                    Vector2D head = HeadPositionW2S;
                    float height = head.y - foot.y;
                    float width = height / 2;
                    float BoxThickness = 1.50f;
                    Canvas->AddRect(ImVec2(foot.x - (width / 2), foot.y), ImVec2(head.x + (width / 2), head.y + (height / 5)), ImColor(EnemyBoxColor), 0.0f, 0, 2);
                }

                // Draw Distance
                if (bLocalOriginW2SValid && bHeadPositionW2SValid && !LocalOriginW2S.IsZeroVector()) {
                    Vector2D distancePosition = AboveHeadW2S.Subtract(Vector2D(0, 30));
                    int textX = distancePosition.x;
                    int textY = distancePosition.y;
                    const char* txtDistance = std::to_string((int)distance).c_str();
                    const char* txtPrefix = "[";
                    const char* txtSuffix = " M]";
                    char buffer[256];
                    strncpy(buffer, txtPrefix, sizeof(buffer));
                    strncat(buffer, txtDistance, sizeof(buffer));
                    strncat(buffer, txtSuffix, sizeof(buffer));
                    const auto textSize = ImGui::CalcTextSize(buffer);
                    const auto horizontalOffset = textSize.x / 2;
                    const auto verticalOffset = textSize.y - 20;
                    const auto textColor = ImColor(EnemyDistanceColor);

                    glColor3f(0, 0, 0);
                    glBegin(GL_QUADS);
                    glVertex2f(textX - horizontalOffset - 3, textY + 3);
                    glVertex2f(textX + horizontalOffset + 1, textY + 3);
                    glVertex2f(textX + horizontalOffset + 1, textY + textSize.y - 1);
                    glVertex2f(textX - horizontalOffset - 3, textY + textSize.y - 1);
                    glEnd();
                    Canvas->AddText({ distancePosition.x - horizontalOffset, distancePosition.y - verticalOffset }, textColor, buffer);
                }

                // Draw Warning
                if (p->visible && !p->knocked)
                    DrawVisibleWarning = true;
            }
        }

        if (DrawVisibleWarning) {
            int textX = screenWidth / 2;
            int textY = screenHeight * 3/4;
            const char* buffer = "VISIBLE WARNING";
            const auto textSize = ImGui::CalcTextSize(buffer);
            const auto horizontalOffset = textSize.x / 2;
            const auto verticalOffset = textSize.y - 20;
            const auto textColor = ImColor(ImVec4(0, 0.99, 0, 0.99));

            glColor3f(0, 0, 0);
            glBegin(GL_QUADS);
            glVertex2f(textX - horizontalOffset - 3, textY + 3);
            glVertex2f(textX + horizontalOffset + 1, textY + 3);
            glVertex2f(textX + horizontalOffset + 1, textY + textSize.y - 1);
            glVertex2f(textX - horizontalOffset - 3, textY + textSize.y - 1);
            glEnd();
            Canvas->AddText({ textX - horizontalOffset, textY - verticalOffset }, textColor, buffer);
        }
    }

//_end
    void update(int counter){
        if (!map->playable)
            return;
        if(!cl->FEATURE_SENSE_ON)
            return;
        for (std::size_t i = 0; i < players->size(); i++) {
            Player *p = players->at(i);
            if (!p->isValid())
                continue;
            if (p->friendly) 
                continue;

            double distance = math::calculateDistanceInMeters(
                lp->localOrigin.x,
                lp->localOrigin.y, 
                lp->localOrigin.z,
                p->localOrigin.x,
                p->localOrigin.y,
                p->localOrigin.z);
            if (!p->visible && !p->knocked && distance < cl->SENSE_MAXRANGE) {
                p->setGlowEnable(1);
                p->setGlowThroughWall(1);
                int healthShield = p->currentHealth + p->currentShields;
                p->setCustomGlow(healthShield, true, false);
            } else if (distance <  cl->SENSE_MAXRANGE) {
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
        if (!map->playable)
            return;
        if (!cl->FEATURE_ITEM_GLOW_ON)
            return;
        for (int highlightId = 15; highlightId < 65; highlightId++) {
            const GlowMode newGlowMode = { 137,0,0,127 };
            const GlowMode oldGlowMode = mem::Read<GlowMode>(lp->highlightSettingsPtr + (HIGHLIGHT_TYPE_SIZE * highlightId) + 0, "Player oldGlowMode");
            if (newGlowMode != oldGlowMode)
                mem::Write<GlowMode>(lp->highlightSettingsPtr + (HIGHLIGHT_TYPE_SIZE * highlightId) + 0, newGlowMode);
        }
    }
};
