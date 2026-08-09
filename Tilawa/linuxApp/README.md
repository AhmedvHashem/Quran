# Tilawa GTK 4 C++ App

The GTK 4 / libadwaita C++ application shell for Tilawa. Consumes the KMP `:shared` core via C ABI functions (`shared_greet`, `shared_abi_version`, etc.).

## Multi-Platform Support

This application can be built natively on **Linux**, **macOS**, and **Windows**.

---

### 1. macOS Build

#### Prerequisites
```bash
brew install gtk4 libadwaita gtkmm4 cmake pkg-config
```

#### Build & Run
```bash
cd linuxApp
cmake -B build
cmake --build build
./build/tilawa-linux
```

---

### 2. Windows Build

#### Prerequisites (MSYS2 UCRT64)
Install MSYS2 and run the following in the UCRT64 shell:
```bash
pacman -S mingw-w64-ucrt-x86_64-gtk4 \
          mingw-w64-ucrt-x86_64-libadwaita \
          mingw-w64-ucrt-x86_64-gtkmm4 \
          mingw-w64-ucrt-x86_64-cmake \
          mingw-w64-ucrt-x86_64-pkg-config \
          mingw-w64-ucrt-x86_64-toolchain
```

#### Build & Run
Ensure `C:\msys64\ucrt64\bin` is added to your Windows `PATH` environment variable so GTK4 dynamic libraries (`libsigc-3.0-0.dll`, etc.) can be located:
```cmd
set PATH=C:\msys64\ucrt64\bin;%PATH%
cd linuxApp
cmake -B build
cmake --build build
.\build\tilawa-linux.exe
```

---

### 3. Linux Build (Ubuntu / Debian / Arch / Fedora)

#### Prerequisites (Ubuntu / Debian)
```bash
sudo apt update
sudo apt install cmake pkg-config libgtk-4-dev libadwaita-1-dev libgtkmm-4.0-dev build-essential
```

#### Build & Run
```bash
cd linuxApp
cmake -B build
cmake --build build
./build/tilawa-linux
```
