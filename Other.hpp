#pragma once

struct Other
{
    ConfigLoader* cl;
    XDisplay* myDisplay;
    Level* map;
    LocalPlayer* lp;
    std::vector<Player*>* players;

    Other(ConfigLoader* in_cl, XDisplay* in_myDisplay, Level* in_map, LocalPlayer* in_lp, std::vector<Player*>* in_players) {
        cl = in_cl;
        myDisplay = in_myDisplay;
        map = in_map;
        lp = in_lp;
        players = in_players;
    }

    void superGlide(double averageFPS) {
        if (cl->FEATURE_SUPER_GLIDE_ON && (cl->AIMBOT_ACTIVATION_KEY != "" || "NONE") && myDisplay->isKeyDown(cl->AIMBOT_ACTIVATION_KEY)) {
            float traversalStartTime = lp->traversalStartTime;
            float traversalProgress = lp->traversalProgress;
            float traversalReleaseTime = lp->traversalReleaseTime;

            float time = lp->worldTime;
            float hangOnWall = time - traversalStartTime;

            if (traversalProgress > 0.85f && traversalReleaseTime == 0.0f && hangOnWall < 1.5f) {
                myDisplay->kbPress("XK_space");
                std::this_thread::sleep_for(std::chrono::milliseconds(static_cast<int>(1/averageFPS*1000)));
                myDisplay->kbPress("XK_c");
                std::this_thread::sleep_for(std::chrono::milliseconds(static_cast<int>(2/averageFPS*1000)));
                myDisplay->kbRelease("XK_space");
                myDisplay->kbRelease("XK_c");
            }
        }
    }
};
