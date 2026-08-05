# Flosu

<img width="1920" height="1055" alt="image" src="https://github.com/user-attachments/assets/0686ba67-a8b0-42e8-b095-0540438e3189" />

An **osu!** clone built from scratch using vanilla Flutter and Dart (leveraging Flutter's core framework, custom `Canvas` rendering, and a based `Ticker` `GameLoop` instead of game engines like Flame).

> [!WARNING]
> **Project status: WIP**
> 
> Flosu is currently in active development. Although it has base features, the project is functional but unstable and prone to errors.

---

## Gallery

<details>
    <summary>Click to expand</summary>
    <h2>Song Select (WIP)</h2>
    <img width="1920" height="1055" alt="image" src="https://github.com/user-attachments/assets/41ddb37b-4408-4de8-929a-19627b598fc6" />
    <h2>Mod Selection (WIP)</h2>
    <img width="1920" height="1058" alt="image" src="https://github.com/user-attachments/assets/b1d1f2da-3b13-4e75-9d68-a6b33b838b6e" />
    <h2>Replay Selection (WIP, Intended to be an internal picker)</h2>
    <img width="1920" height="1058" alt="image" src="https://github.com/user-attachments/assets/8691f45c-e330-4ed5-9173-72ff6287af1f" />
    <h2>Gameplay</h2>
    <img width="1920" height="1058" alt="image" src="https://github.com/user-attachments/assets/6295731e-0a43-4fe6-a001-4964beae5b9a" />
    <h2>Results</h2>
<img width="1920" height="1053" alt="image" src="https://github.com/user-attachments/assets/6e81ac97-742a-40cc-a622-08b2d8d22d7d" />
</details>

---

## Key Features

*   ⏰ **Framed events** (`GameLoop`, `GameLoopListener` mixin)
*   🎵 **Low latency audio** (`AudioService`, `TrackService`, `AudioClock`)
*   ⌨️ **Low latency input** (`InputService`, `*Handler` mixins)
*   🧵 **Isolate-based file parsing** (`IoService`, `IoParser`´s)
*   📊 **Rich HUD** (WIP)
*   🛠️ **Debugging tools** (WIP) (`DebugOverlay`)

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
    *   If you have installed osu!(stable), visit [Client / osu!stable program files](https://osu.ppy.sh/wiki/en/Client/Program_files) for information on the installation folder.
*   **Manual method**:
    1.  Create a folder intended to hold the osu! beatmap files.
    2.  Visit [Osu! beatmap listing](https://osu.ppy.sh/beatmapsets) if you have an osu! account, or [osu.direct](https://osu.direct) otherwise.
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
| **Web** | ❌ | Not compatible because of `dart:io` library |

---

## Controls and Shortcuts

### General
| Shortcut | Function | Note |
| :--- | :--- | :--- |
| `Control` + `T` | Toggle top bar | Invisible in Splash and Gameplay |
| `Control` + `O` | Toggle settings | |
| `Control` + `N` | Toggle notifications | |
| `Control` + `F9` | Toggle logs | |
| `Control` + `F11` | Toggle performance statistics | |
| `Control` + `Alt` + `F4` | Forced restart | |

### Gameplay
| Shortcut | Function | Note |
| :--- | :--- | :--- |
| `Z` / `X` | osu! buttons | No-op |
| `Escape` | Pause game | |

### Song Select
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

---

Made by [imbserch](https://github.com/imbserch) with love ❤️ (Oct 2025 - now)
