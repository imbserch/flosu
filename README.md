# Flosu

An **osu!** clone built from scratch using vanilla Flutter and Dart (leveraging Flutter's core framework, custom `Canvas` rendering, and `Ticker`s instead of game engines like Flame).

> [!WARNING]
> **Project status: WIP**
> 
> Flosu is currently in active development. Although it has base features, the project is functional but unstable and prone to errors.

---

## Key Features

*   🎵 **Low latency audio** (`AudioService`, `SampleService`)
*   ⌨️ **Low latency input** (`InputService`)
*   🧵 **Isolate-based file parsing** (`FileParserService`)
*   📊 **Rich HUD** (WIP)
*   🛠️ **Debugging tools** (WIP) (`FrameStats`, `LogConsole`)

---

## Stack

*   💻 **Framework**: Flutter (Dart SDK `^3.10.7`)
*   🧠 **State management**: Riverpod (`flutter_riverpod`) for scalable and decoupled reactive logic.
*   🗺️ **Navigation and routing**: GoRouter (`go_router`) for structured page transitions.
*   🔊 **Audio engine**: SoLoud (`flutter_soloud`) for real-time low latency audio processing.
*   📦 **File decompression**: `lzma` to extract replay files.

---

## Getting Started

### Prerequisites

*   Flutter SDK installed on your machine (`3.10.7` or higher)
*   Dart SDK configured

### Running the Project

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/imbserch1257/flosu.git
    cd flosu
    ```

2.  **Get dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the application**:
    ```bash
    flutter run
    ```

### Additional Steps

Flosu doesn't know where to find files, so you must provide a folder containing uncompressed beatmap files. This can be achieved in two ways:

*   **osu!(stable) installation**:
    *   If you have installed osu!(stable), visit https://osu.ppy.sh/wiki/en/Client/Program_files for information on the installation folder.
*   **Manual method**:
    1.  Create a folder intended to hold the osu! beatmap files.
    2.  Visit https://osu.ppy.sh/beatmapsets if you have an osu! account, or https://osu.direct/ otherwise.
    3.  Download all the maps you want!
    4.  Decompress the `.osz` files into the created folder.

> [!NOTE]
> Upon launching Flosu, open the settings by pressing `Control` + `O` and go to the `Maintenance` > `Import beatmaps` section. Select the directory created at the beginning in the pop-up window or the osu! Song folder.
>
> After doing this, Flosu will reload and songs will appear as they are parsed.

---

## Compatibility

| Platform | Compatibility | Note |
| :--- | :---: | :--- |
| **Android** | ✅ | |
| **Windows** | ✅ | |
| **Linux** | ⚠️ | Not tested |
| **Web** | ❌ | Not compatible (`dart:io` library) |


---

## Controls and Shortcuts

### General
| Shortcut | Function | Note |
| :--- | :--- | :--- |
| `Control` + `T` | Toggle top bar | Invisible in Splash and Gameplay |
| `Alt` + `Mouse Wheel` | Volume control | |
| `Control` + `O` | Toggle settings | |
| `Control` + `N` | Toggle notifications | |
| `Control` + `F9` | Toggle logs | |
| `Control` + `F11` | Toggle performance statistics | |
| `Control` + `Alt` + `F4` | Forced restart | |

### Gameplay
| Shortcut | Function | Note |
| :--- | :--- | :--- |
| `X` / `Y` | osu! buttons | No-op |
| `Escape` | Pause game | |

### SongSelect
| Shortcut | Function | Note |
| :--- | :--- | :--- |
| `F1` | Open Mods screen | |
| `F2` | Random Beatmap | |
| `F3` | Open replay | |




---

## Roadmap

- [x] Load `.osu` and `.osr` files
- [x] Configuration persistence
- [x] Low latency audio
- [x] Low latency input
- [ ] Gameplay (WIP)
- [ ] Implement Mod behaviors (WIP)
- [ ] Drag and drop of `.osu` and `.osr` files
- [ ] More features will be added soon
