#pragma once

struct XDisplay {
private:
    Display* display = XOpenDisplay(NULL);

public:
    XDisplay() {
        display = XOpenDisplay(NULL);
        if (!display) throw std::invalid_argument("Could not open XDisplay");
    }

    void moveMouseRelative(int yawMovement, int pitchMovement) {
        XTestFakeRelativeMotionEvent(display, yawMovement, pitchMovement, CurrentTime);
        XFlush(display);
    }

    void mouseClickLeft() {
        XTestFakeButtonEvent(display, Button1, True, 0);
        XTestFakeButtonEvent(display, Button1, False, 0);
        XFlush(display);
    }

    void kbPress(std::string XK_keyName) {
        KeySym ksKeyCode = XStringToKeysym(trimXKPrefix(XK_keyName).c_str());
        unsigned int uKeyCode = XKeysymToKeycode(display, ksKeyCode);
        XTestFakeKeyEvent(display, uKeyCode, True, 0);
        XFlush(display);
    }

    void kbRelease(std::string XK_keyName) {
        KeySym ksKeyCode = XStringToKeysym(trimXKPrefix(XK_keyName).c_str());
        unsigned int uKeyCode = XKeysymToKeycode(display, ksKeyCode);
        XTestFakeKeyEvent(display, uKeyCode, False, 0);
        XFlush(display);
    }

    bool isLeftMouseButtonDown() {
        Window root, child;
        int root_x, root_y, win_x, win_y;
        unsigned int mask;
        if (XQueryPointer(display, XRootWindow(display, DefaultScreen(display)), &root, &child, &root_x, &root_y, &win_x, &win_y, &mask))
            return (mask & Button1Mask) != 0;
        return false;
    }

    std::string trimXKPrefix(const std::string& keyName) {
        if (keyName.compare(0, 3, "XK_") == 0)
            return keyName.substr(3);
        return keyName;
    }

    bool isKeyDown(int keySym) {
        char keys_return[32];
        XQueryKeymap(display, keys_return);
        KeyCode keyCode = XKeysymToKeycode(display, keySym);
        return !!(keys_return[keyCode >> 3] & (1 << (keyCode & 7)));
    }

    bool isKeyDown(std::string XK_keyName) {
        KeySym keySym = XStringToKeysym(trimXKPrefix(XK_keyName).c_str());
        return isKeyDown(keySym);
    }
};
