#pragma once

struct Other {
    ConfigLoader* cl;
    XDisplay* myDisplay;
    Level* map;
    LocalPlayer* lp;
    std::vector<Player*>* players;
    float traversalStartTimePrev;

    Other(ConfigLoader* in_cl, XDisplay* in_myDisplay, Level* in_map, LocalPlayer* in_lp, std::vector<Player*>* in_players) {
        cl = in_cl;
        myDisplay = in_myDisplay;
        map = in_map;
        lp = in_lp;
        players = in_players;
    }

    void superGlide(double averageFPS) {
        if (cl->FEATURE_SUPER_GLIDE_ON
            && ((cl->SUPER_GLIDE_ACTIVATION_KEY == "" || cl->SUPER_GLIDE_ACTIVATION_KEY == "NONE")
            || ((cl->SUPER_GLIDE_ACTIVATION_KEY != "" || "NONE") && myDisplay->isKeyDown(cl->SUPER_GLIDE_ACTIVATION_KEY)))) {
            float traversalStartTime = lp->traversalStartTime;
            float traversalProgress = lp->traversalProgress;

            float time = lp->worldTime;
            float hangOnWall = time - traversalStartTime;

            if (traversalStartTimePrev < traversalStartTime && traversalProgress > 0.85f && hangOnWall < 1.5f) {
                traversalStartTimePrev = traversalStartTime;
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
