# Nika Read Only

- Apex Legends external cheat for Linux.

## Introduction

- The goal of this project is to have a working Linux cheat that can run alongside Apex Legends on my i5-6600K 4c/4t Linux PC.
- This is a considerable improvement of: Pesci-Apu/Nika
- With an overlay taken from: Gerosity/zap-client-Read-Only-
- The code remains simple and clean. You can read it out and understand how the overlay is added.

## Credits

- [x] (UC) **Acknowledge**
- [x] (UC) **Gerosity**

![Screenshot.jpg](Screenshot.jpg)

## Features

* [x] Window title **spoofing** (webpage title mimic)
* [x] Memory writing Glow ESP was replaced with overlay based ESP
* [x] Map radar (overlay based)
* [x] Spectators list (overlay or CLI based)
* [x] Added _AIMBOT_ZOOMED_MAX_MOVE_ / _AIMBOT_HIPFIRE_MAX_MOVE_ / _AIMBOT_MAX_DELTA_ to limit mouse speed
* [x] Hold SHIFT to **lock on target** and **triggerbot** auto fire
* [x] Hold CAPS_LOCK to **super glide**
* [x] Increase/decrease **aimbot** strength with CURSOR_LEFT; "**<**" symbol in the upper left corner of the screen
* [x] Toggle **ADS locking** with CURSOR_RIGHT; "**>**" symbol in the upper left corner of the screen
* [x] Disable/enable **triggerbot** auto fire with CURSOR_UP; "**^**" symbol in the upper left corner of the screen
- **Bind X in-game to fire, triggerbot will use that key** (default AIMBOT_FIRING_KEY)
- **Unbind LMB (Left Mouse Button) in-game from fire, so that the cheat will fire for you instead** (AIMBOT_ACTIVATED_BY_MOUSE default YES)
* [x] Toggle hitbox with CURSOR_DOWN; `body`/`neck`/`head` text in the upper left corner of the screen
* [x] Efficient entities cache, enabling Crypto drone targeting
* [x] Press RIGHT_SHIFT to select Item ESP
* [x] Press INSERT / DELETE / HOME / END / PAGE_UP / PAGE_DOWN to cycle LIGHT / ENERGY / SHOTGUN / HEAVY / SNIPER / GEAR items
* [x] Terminate process with F9

## Notes

- Open the cheat in match; and always terminate process with F9.

### 1. Environment set up in Linux (choose one)

<details>
<summary>Install dependencies <b>Fedora (Nobara Linux)</b>:</summary>

    sudo yum install cmake wayland-devel libxkbcommon-devel libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel
    sudo yum install g++ libXtst-devel mesa-libGLU-devel libudev-devel
</details>

<details>
<summary>Install dependencies <b>Arch (EndeavourOS / CachyOS)</b>:</summary>

    sudo pacman -Syu cmake
</details>

<details>
<summary>Install dependencies <b>Debian</b>:</summary>

    ,-.  ,--. ,-.  ,  ,.  .  .   ,  ,-.    ;-.   ,-.   ,-.  ;-. 
    |  \ |    |  ) | /  \ |\ |   | (   `   |  ) /   \ /   \ |  )
    |  | |-   |-<  | |--| | \|   |  `-.    |-'  |   | |   | |-' 
    |  / |    |  ) | |  | |  |   | .   )   |    \   / \   / |   
    `-'  `--' `-'  ' '  ' '  '   '  `-'    '     `-'   `-'  '   
</details>

### 2. Build & Install GLFW

- For **compatible** GLFW:

``` shell
su
chmod 700 /root
cd /root
git clone https://github.com/glfw/glfw.git
cd glfw
mkdir build
cd build
cmake ..
make
make install
```

or

- For **secure** GLFW (exclusively using **Wayland**):

``` shell
su
chmod 700 /root
cd /root
git clone https://github.com/glfw/glfw.git
cd glfw
nano src/egl_context.c
mkdir build
cd build
cmake .. -D GLFW_BUILD_X11=0
make
make install
```

IMPORTANT: When using `nano src/egl_context.c` above, you must change:

``` shell
    _glfw.egl.EXT_present_opaque =
        extensionSupportedEGL("EGL_EXT_present_opaque");
```

into

``` shell
    _glfw.egl.EXT_present_opaque = GLFW_FALSE;
        //extensionSupportedEGL("EGL_EXT_present_opaque");
```

### 3. Install

``` shell
cd path/to/extracted/repository
chmod +x install.sh
./install.sh
```

### 4. Run

``` shell
su
cd /root
./main.sh
```

### 5. Configure

Change settings with:

``` shell
sudo nano /root/nika.ini
```

### 6. HWID unban (optional, Fedora / Arch, GRUB bootloader, no dual boot)

- My storage serial numbers were collected most likely from **dbus**. Widely adopted Linux **systemd** `init` as currently being distributed has the security profile of an internet **meme**.
- Run `spoof.sh` then reboot.
- The following command is run by the game in this context: `dbus-send --system --dest=org.freedesktop.UDisks2 --type=method_call --print-reply  /org/freedesktop/UDisks2 org.freedesktop.DBus.ObjectManager.GetManagedObjects`

### 7. EndeavourOS / CachyOS

- Set to "**Borderless Window**" in-game, press ESC >> Settings >> Video >> Display Mode
- For KDE desktop environment (Wayland), open System Settings >> Window Management >> Window Rules >> Import... >> glfw.kwinrule
    - Also check in System Settings >> Display & Monitor >> Scale: 100%
- For Xfce desktop environment (X11), go to Settings >> Window Manager Tweaks >> Accessibility >> Key used to grab and move windows: None

### 8. Update

- Go to the (UC) Apex Legends Reversal, Structs and Offsets thread and copy the usual pastebin to `apexdumper.txt`
- With `apexdumper.txt` in the same folder as `apexdumper.sh`:

``` shell
cd path/to/extracted/repository
chmod +x apexdumper.sh
./apexdumper.sh
```

- If your pastebin is missing GameVersion, open Offsets.hpp and change:

`constexpr char OFF_GAME_VERSION[] = ""; //[Miscellaneous]->GameVersion`

into (input your current GameVersion)

`constexpr char OFF_GAME_VERSION[] = "v3.0.78.32"; //[Miscellaneous]->GameVersion`

- Install update:

```
cd path/to/extracted/repository
chmod +x install.sh
./install.sh
```
