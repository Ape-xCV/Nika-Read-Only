#pragma once

struct Sense {
    ConfigLoader* cl;
    LocalPlayer* lp;
    std::vector<Player*>* players;
    Camera* gameCamera;
    AimBot* aimBot;

    Sense(ConfigLoader* in_cl, LocalPlayer* in_lp, std::vector<Player*>* in_players, Camera* in_gameCamera, AimBot* in_aimBot) {
        this->cl = in_cl;
        this->lp = in_lp;
        this->players = in_players;
        this->gameCamera = in_gameCamera;
        this->aimBot = in_aimBot;
    }

    void renderStatus(bool leftLock, bool rightLock, bool autoFire, int boneId, double averageProcessingTime, double averageFPS, int cache) {
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

        const ImVec4 leftLockColor = leftLock ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        const ImVec4 rightLockColor = rightLock ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        const ImVec4 autoFireColor = autoFire ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        const ImVec4 boneIdColor = ImVec4(1, 1, 0.343, 1);
        const ImVec4 processingTimeColor = averageProcessingTime < 20 ? ImVec4(0.4, 1, 0.343, 1) : ImVec4(1, 0.343, 0.475, 1);
        ImGui::TextColored(leftLockColor, "< ");
        ImGui::SameLine();
        ImGui::TextColored(autoFireColor, "^ ");
        ImGui::SameLine();
        ImGui::TextColored(rightLockColor, "> ");
        ImGui::SameLine();
        ImGui::Text("hitbox: ");
        ImGui::SameLine();
        if (boneId == 0) ImGui::TextColored(boneIdColor, "HEAD ");
        else if (boneId == 1) ImGui::TextColored(boneIdColor, "NECK ");
        else ImGui::TextColored(boneIdColor, "BODY ");
        ImGui::SameLine();
        ImGui::Text("interval: ");
        ImGui::SameLine();
        ImGui::TextColored(processingTimeColor, "%.2fms ", averageProcessingTime);
        if (cl->FEATURE_SUPER_GLIDE_ON) {
            ImGui::SameLine();
            ImGui::Text("fps: %.2f ", averageFPS);
        }
        ImGui::SameLine();
        ImGui::Text("esp: %s ", data::items[data::selectedRadio][0].c_str());
        ImGui::SameLine();
        ImGui::Text("cache: %d", cache);
        ImGui::End();
    }

    void drawText(ImDrawList* canvas, Vector2D textPosition, const char* text, ImVec4 color) {
        int textX = textPosition.x;
        int textY = textPosition.y;
        char buffer[16];
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
        canvas->AddText({ textPosition.x - horizontalOffset, textPosition.y - verticalOffset }, textColor, buffer);
    }

    void renderESP(ImDrawList* canvas) {
        Vector2D drawPosition;
        Vector2D screenSize = gameCamera->getResolution();
        bool drawVisibleWarning = false;
        bool drawDroneWarning = false;
        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!p->isItem && !cl->SENSE_SHOW_DEAD && !p->currentHealth > 0) continue;

            Vector2D localOriginW2S, headPositionW2S, aboveHeadW2S;
            Vector3D localOrigin3D = p->localOrigin;
            Vector3D headPosition3D;
            if (!p->isPlayer && !p->isDrone && !p->isDummie) {
                headPosition3D = localOrigin3D;
                headPosition3D.z += 10.0f;
            } else { headPosition3D = p->getBonePosition(HitboxType::Head); }
//            Vector3D headPosition3D = p->getBonePosition(HitboxType::Head);
            Vector3D aboveHead3D = headPosition3D;
            aboveHead3D.z += 10.0f;

            bool isLocalOriginW2SValid = gameCamera->worldToScreen(localOrigin3D, localOriginW2S);
            bool isHeadPositionW2SValid = gameCamera->worldToScreen(headPosition3D, headPositionW2S);
            gameCamera->worldToScreen(aboveHead3D, aboveHeadW2S);

            // Colors - Players (Enemy)
            ImVec4 enemyBoxColor;
            if (p->isDrone || p->isItem) enemyBoxColor = ImVec4(1.00f, 0.00f, 1.00f, 1.00f);
            else if (p->isKnocked) enemyBoxColor =       ImVec4(1.00f, 0.67f, 0.17f, 1.00f);
            else if (p->isVisible) enemyBoxColor =       ImVec4(0.00f, 1.00f, 0.00f, 1.00f);
            else enemyBoxColor =                         ImVec4(1.00f, 0.00f, 0.00f, 1.00f);

            float distance = util::inchesToMeters(p->distance2DToLocalPlayer);
            if (p->isEnemy && p->isValid() && !p->isLocal && distance < cl->SENSE_MAX_RANGE) {

                // Draw Boxes
                if (isLocalOriginW2SValid && isHeadPositionW2SValid) {
                    Vector2D foot = localOriginW2S;
                    Vector2D head = headPositionW2S;
                    float height = head.y - foot.y;
                    float width = height / 2;
                    glColor3f(enemyBoxColor.x, enemyBoxColor.y, enemyBoxColor.z);
                    glLineWidth(1.5f);
                    glBegin(GL_LINE_LOOP);
                    glVertex2f(foot.x - width/2, foot.y);
                    glVertex2f(foot.x - width/2, head.y + height/5);
                    glVertex2f(head.x + width/2, head.y + height/5);
                    glVertex2f(head.x + width/2, foot.y);
                    glEnd();
                    //canvas->AddRect(ImVec2(foot.x - (width / 2), foot.y), ImVec2(head.x + (width / 2), head.y + (height / 5)), ImColor(enemyBoxColor), 0.0f, 0, 2);

                    // Draw bar
                    if (cl->SENSE_SHOW_PLAYER_BARS && !p->isItem) {
                        int life = p->currentHealth;
                        int evo = p->currentShield;
                        if (evo > 100)     glColor3f(1.00f, 0.25f, 0.00f); // Red shield
                        else if (evo > 75) glColor3f(1.00f, 0.25f, 1.00f); // Purple shield
                        else if (evo > 50) glColor3f(0.00f, 0.75f, 1.00f); // Blue shield
                        else if (evo > 0)  glColor3f(1.00f, 1.00f, 1.00f); // White shield
                        else               glColor3f(1.00f, 1.00f, 0.00f); // No shield

                        glLineWidth(5.0f);
                        glBegin(GL_LINES);
                        glVertex2f(head.x + width/2 - 5.0f, foot.y);
                        glVertex2f(head.x + width/2 - 5.0f, foot.y + (height + height/5) * life/100);
                        glEnd();
                    }

                    if (cl->SENSE_TEXT_BOTTOM)
                        drawPosition = localOriginW2S.Subtract(Vector2D(0, 10));
                    else
                        drawPosition = aboveHeadW2S.Subtract(Vector2D(0, 10));
                    // Draw Distance
                    if (cl->SENSE_SHOW_PLAYER_DISTANCES) {
                        if (cl->SENSE_TEXT_BOTTOM)
                            drawPosition = drawPosition.Add(Vector2D(0, 20));
                        else
                            drawPosition = drawPosition.Subtract(Vector2D(0, 20));
                        const char* txtPrefix = "[";
                        const char* txtDistance = std::to_string((int)distance).c_str();
                        const char* txtSuffix = " M]";
                        char distanceText[256];
                        strncpy(distanceText, txtPrefix, sizeof(distanceText));
                        strncat(distanceText, txtDistance, sizeof(distanceText));
                        strncat(distanceText, txtSuffix, sizeof(distanceText));
                        drawText(canvas, drawPosition, distanceText, enemyBoxColor);
                    }
                    // Draw Name
                    if (cl->SENSE_SHOW_PLAYER_NAMES || p->isItem) {
                        if (cl->SENSE_TEXT_BOTTOM)
                            drawPosition = drawPosition.Add(Vector2D(0, 20));
                        else
                            drawPosition = drawPosition.Subtract(Vector2D(0, 20));
                        const char* txtName;
                        if (p->isPlayer)
                            txtName = p->getPlayerName().c_str();
                        else
                            if (p->isDrone)
                                txtName = "Drone";
                            else
                                if (p->isDummie)
                                    txtName = "Dummie";
                                else
                                    for (int arraySize = sizeof(data::items) / sizeof(data::items[0]), i = 0; i < arraySize; i++)
                                        if (p->itemId == stoi(data::items[i][1])) { txtName = data::items[i][0].c_str(); break; }
                                    //txtName = data::items[data::selectedRadio][0].c_str();
                        char nameText[256];
                        strncpy(nameText, txtName, sizeof(nameText));
                        drawText(canvas, drawPosition, nameText, enemyBoxColor);
                    }
                    // Draw Level
                    if (cl->SENSE_SHOW_PLAYER_LEVELS && p->isPlayer) {
                        if (cl->SENSE_TEXT_BOTTOM)
                            drawPosition = drawPosition.Add(Vector2D(0, 20));
                        else
                            drawPosition = drawPosition.Subtract(Vector2D(0, 20));
                        const char* txtPrefix = "Lv ";
                        const char* txtLevel = std::to_string(p->GetPlayerLevel()).c_str();
                        //const char* txtSuffix = "";
                        char levelText[256];
                        strncpy(levelText, txtPrefix, sizeof(levelText));
                        strncat(levelText, txtLevel, sizeof(levelText));
                        //strncat(levelText, txtSuffix, sizeof(levelText));
                        drawText(canvas, drawPosition, levelText, enemyBoxColor);
                    }
                }

                // Draw Warning
                if (p->isDrone)
                    drawDroneWarning = true;
                else
                    if (p->isVisible && !p->isKnocked)
                        drawVisibleWarning = true;
            }
        }

        if (drawVisibleWarning) {
            ImVec4 warningColor = ImColor(ImVec4(0.00f, 1.00f, 0.00f, 1.00f));
            drawPosition = Vector2D(screenSize.x / 2, screenSize.y * 3/4);
            const char* txtWarning;
            txtWarning = "VISIBLE WARNING";
            char warningText[256];
            strncpy(warningText, txtWarning, sizeof(warningText));
            drawText(canvas, drawPosition, warningText, warningColor);
        }

        if (drawDroneWarning) {
            ImVec4 warningColor = ImColor(ImVec4(1.00f, 0.00f, 1.00f, 1.00f));
            drawPosition = Vector2D(screenSize.x / 2, screenSize.y * 3/4 + 20);
            const char* txtWarning;
            txtWarning = "DRONE WARNING";
            char warningText[256];
            strncpy(warningText, txtWarning, sizeof(warningText));
            drawText(canvas, drawPosition, warningText, warningColor);
        }

        // Draw FOV circle
        if (cl->SENSE_SHOW_FOV && lp->inZoom) {
            ImVec2 center(screenSize.x / 2, screenSize.y / 2);
            int radius = screenSize.y / 60 * cl->AIMBOT_FOV;
            radius += radius * (60/lp->zoomFov - 1) * cl->AIMBOT_FOV_EXTRA_BY_ZOOM;
            canvas->AddCircle(center, radius, ImColor(ImVec4(1.00f, 1.00f, 1.00f, 1.00f)));
        }

        // Draw target line
        if (cl->SENSE_SHOW_TARGET && aimBot->targetSelected) {
            Vector2D targetBoneW2S;
            gameCamera->worldToScreen(aimBot->targetBone3DCache, targetBoneW2S);
            glColor3f(1.00f, 1.00f, 1.00f);
            glLineWidth(1.0f);
            glBegin(GL_LINES);
            glVertex2f(screenSize.x / 2, screenSize.y / 2);
            glVertex2f(targetBoneW2S.x, targetBoneW2S.y);
            glEnd();
        }
    }

    static Vector3D rotatePoint(Vector3D localPlayerPos, Vector3D playerPos, int posX, int posY, int sizeX, int sizeY, float angle, float zoom, bool* viewCheck) {
        float r_1, r_2;
        float x_1, y_1;

        r_1 = -(playerPos.y - localPlayerPos.y);
        r_2 = playerPos.x - localPlayerPos.x;

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

    void renderRadar(ImDrawList* canvas) {
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

        glColor3f(1.00f, 1.00f, 1.00f);
        glLineWidth(1.0f);
        glBegin(GL_LINES);
        glVertex2f(startHorizontal.x, midRadar.y);
        glVertex2f(endHorizontal.x, midRadar.y);
        glVertex2f(midRadar.x, startVertical.y);
        glVertex2f(midRadar.x, endVertical.y);
        glEnd();

        for (int i = 0; i < players->size(); i++) {
            Player* p = players->at(i);
            if (!p->isEnemy || !p->isValid() || p->isLocal)
                continue;

            float radarDistance = util::inchesToMeters(p->distance2DToLocalPlayer);
            if (radarDistance >= 0.0f && radarDistance < cl->SENSE_MAX_RANGE) {
                bool viewCheck = false;
                Vector3D single = rotatePoint(lp->localOrigin, p->localOrigin, drawPos.x, drawPos.y, drawSize.x, drawSize.y, p->viewAngles.y, 0.3f, &viewCheck);

                ImVec2 center(single.x, single.y);
                int radius = 5;
                if (p->isItem)
                    canvas->AddCircleFilled(center, radius, ImColor(ImVec4(0, 0.99, 0.99, 0.99)));
                else
                    canvas->AddCircleFilled(center, radius, ImColor(ImVec4(0.99, 0, 0.99, 0.99)));
                if (p->isVisible)
                    canvas->AddCircle(center, radius + 2, ImColor(ImVec4(0.99, 0.99, 0, 0.99)));

                // Draw a line pointing in the direction of each player's aim
                float angle = (360.0f - p->viewYaw) * (M_PI / 180.0f);
                ImVec2 endpoint(center.x + radius * cos(angle), center.y + radius * sin(angle));
                canvas->AddLine(center, endpoint, ImColor(ImVec4(0, 0, 0, 0.99)));
            }
        }
        ImGui::End();
    }

    void renderSpectators(int totalSpectators, std::vector<std::string> spectators) {
        ImVec2 center = ImGui::GetMainViewport()->GetCenter();
        ImGui::SetNextWindowPos(ImVec2(0.0f, center.y), ImGuiCond_Once, ImVec2(0.02f, 0.5f));
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
        ImGui::SameLine(); ImGui::TextColored(totalSpectators > 0 ? ImVec4(1, 0.343, 0.475, 1) : ImVec4(0.4, 1, 0.343, 1), "%d", totalSpectators);
        if (static_cast<int>(spectators.size()) > 0) {
            ImGui::Separator();
            for (int i = 0; i < static_cast<int>(spectators.size()); i++)
                ImGui::TextColored(ImVec4(1, 0.343, 0.475, 1), "> %s", spectators.at(i).c_str());
        }
        ImGui::End();
    }

    void renderMenu() {
        ImVec2 center = ImGui::GetMainViewport()->GetCenter();
        ImGui::SetNextWindowPos(center, ImGuiCond_Appearing, ImVec2(0.5f, 0.5f));
        ImGui::SetNextWindowBgAlpha(0.67f);
        ImGui::Begin("Items", nullptr,
            //ImGuiWindowFlags_NoTitleBar |
            ImGuiWindowFlags_NoResize |
            ImGuiWindowFlags_NoMove |
            ImGuiWindowFlags_NoScrollbar |
            ImGuiWindowFlags_NoCollapse |
            ImGuiWindowFlags_NoSavedSettings);

        ImGui::BeginTable("Rows", 5);
        for (int i = 0; i < static_cast<int>(sizeof data::items / sizeof data::items[0]); i++) {
            ImGui::TableNextColumn();
            std::string id = data::items[i][0];
            if (ImGui::RadioButton(id.c_str(), &data::selectedRadio, i)) printf("%d\n", data::selectedRadio);
        }
        ImGui::EndTable();
        ImGui::End();
    }
};
