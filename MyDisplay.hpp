#pragma once
struct MyDisplay {
private:
    Display* display = XOpenDisplay(NULL);

public:
    MyDisplay() {
        display = XOpenDisplay(NULL);
        if (!display) throw std::invalid_argument("Could not open display");
    }

    void mouseClickLeft() {
        XTestFakeButtonEvent(display, Button1, True, 0);
        XTestFakeButtonEvent(display, Button1, False, 0);
        XFlush(display);
    }
    void mouseClick(int button)
    {
        XEvent event;
        memset(&event, 0x00, sizeof(event));
        event.type = ButtonPress;
        event.xbutton.button = button;
        event.xbutton.same_screen = True;
        XQueryPointer(display, RootWindow(display, DefaultScreen(display)), &event.xbutton.root, &event.xbutton.window, &event.xbutton.x_root, &event.xbutton.y_root, &event.xbutton.x, &event.xbutton.y, &event.xbutton.state);
        event.xbutton.subwindow = event.xbutton.window;
        while (event.xbutton.subwindow)
        {
            event.xbutton.window = event.xbutton.subwindow;
            XQueryPointer(display, event.xbutton.window, &event.xbutton.root, &event.xbutton.subwindow, &event.xbutton.x_root, &event.xbutton.y_root, &event.xbutton.x, &event.xbutton.y, &event.xbutton.state);
        }
        if (XSendEvent(display, PointerWindow, True, 0xfff, &event) == 0)
            fprintf(stderr, "Error\n");
        XFlush(display);
        usleep(100000);
        event.type = ButtonRelease;
        event.xbutton.state = 0x100;
        if (XSendEvent(display, PointerWindow, True, 0xfff, &event) == 0)
            fprintf(stderr, "Error\n");
        XFlush(display);
    }
    void moveMouseRelative(int pitchMovement, int yawMovement) {
        XTestFakeRelativeMotionEvent(display, yawMovement, pitchMovement, CurrentTime);
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
//_begin
    bool isRightMouseButtonDown() {
        Window root, child;
        int root_x, root_y, win_x, win_y;
        unsigned int mask;
        if (XQueryPointer(display, XRootWindow(display, DefaultScreen(display)), &root, &child, &root_x, &root_y, &win_x, &win_y, &mask))
            return (mask & Button2Mask) != 0;
        return false;
    }
//_end
    bool keyDown(int keyCode) {
        char keys_return[32];
        XQueryKeymap(display, keys_return);
        KeyCode kc2 = XKeysymToKeycode(display, keyCode);
        bool buttonDown = !!(keys_return[kc2 >> 3] & (1 << (kc2 & 7)));
        return buttonDown;
    }
    bool keyDown(std::string XK_keyName) {
        KeySym keyCode = XStringToKeysym(trimXKPrefix(XK_keyName).c_str());
        return keyDown(keyCode);
    }
    std::string trimXKPrefix(const std::string& keyName) {
        if (keyName.compare(0, 3, "XK_") == 0)
            return keyName.substr(3);
        return keyName;
    }
};
