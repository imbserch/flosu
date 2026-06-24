# Flosu

An **osu!** game client built from the ground up using **vanilla Flutter** & **Dart** (relying directly on Flutter's core framework, custom painters, and tickers instead of third-party game engines like Flame). Flosu focuses on high performance, smooth animations, and a modern architecture to deliver an authentic gameplay experience.

> [!WARNING]
> **Project Status (Active WIP)**: Flosu is currently in an early, active stage of development. While core features are present, the project is functional but **unstable, experimental, and prone to errors**. 

---

## 🚀 Key Features

*   **🎮 Phased Game Loop (`GameLoopService`) `[Early WIP]`**: Utilizing Flutter's `Ticker` system, the gameplay updates are partitioned into discrete phases (`input`, `logic`, and `visual`) to ensure frame-rate-independent movement. *Note: Gameplay and hit detection mechanics are currently in a very early stage of development.*
*   **⚙️ Gameplay & Scoring Controller (`GameplayController`) `[Early WIP]`**: State management for active game sessions, health calculation, and combo streaks. *Note: Currently a basic skeleton implementation under active development and highly unstable.*
*   **⌨️ Low-Latency Global Input Interception (`InputService`)**: In a rhythm game, input latency must be minimized. To bypass standard widget-focus delays and widget-tree traversal overhead, Flosu implements a highly customized input service. It intercepts mouse/pointer and keyboard events at the lowest engine level by subscribing directly to Flutter's framework singletons: `GestureBinding.instance.pointerRouter` and `HardwareKeyboard.instance`. This allows frame-perfect raw input capturing independent of the active widget state.
*   **⚡ High-Performance Slider Rendering**: By employing vertex-based triangle mesh generation (`VerticesUtils`), slider bodies are drawn directly onto the canvas using `Canvas.drawVertices`. This avoids the expensive CPU/GPU cost of standard stroked `Path` operations, enabling hundreds of slider components to be drawn without dropping frames.
*   **🧵 Isolate-Driven Parsing (`FileParserService`)**: Beatmap (`.osu`) and replay (`.osr`) decoding are processed entirely in a separate Dart Isolate (background thread). This keeps the main UI thread lightweight, completely eliminating frame stutters during file picking or loading transitions.
*   **🔄 Smooth Replay Playback**: Fully supports playing back `.osr` replay files. The cursor movement interpolates replay frames according to the audio track timing, showing smooth movement and customizable cursor trails.
*   **🎵 Audio Engine Integration**: Powered by `flutter_soloud` for low-latency audio playback, music volume control, and hit sample feedback.
*   **📊 Rich HUD & Performance Profiling `[WIP]`**:
    *   Live metrics including Combo, Accuracy (using the standard osu! formula), Health (0-200), and Avg Hit Error.
    *   A custom **`FrameStats` overlay** to monitor Build/Draw, Raster, and Input processing latencies in real-time. *Note: The profiling engine and overlays are undergoing frequent changes and testing.*
*   **🗂️ Song Selection Carousel**: A custom, scroll-positioned song select list that dynamically translates cards horizontally based on their proximity to the center, replicating the classic osu! wheel experience.

---

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.10.7`)
*   **State Management**: [Riverpod (`flutter_riverpod`)](https://riverpod.dev) for scalable, decoupled reactive logic.
*   **Navigation & Routing**: [GoRouter (`go_router`)](https://pub.dev/packages/go_router) for structured page transitions.
*   **Audio Engine**: [flutter_soloud](https://pub.dev/packages/flutter_soloud) for real-time low-latency audio processing.
*   **File Decompression**: `lzma` for extracting replay files.
*   **Layout & Scrolling**: `scrollable_positioned_list` for index-based viewport calculations in the song carousel.

---

## 🕹️ Controls & Shortcuts

During gameplay and navigation, several shortcuts and mouse gestures are supported globally:

| Action / Control | Shortcut | Description |
| :--- | :--- | :--- |
| **Adjust Volume** | `Alt + Mouse Wheel Scroll` | Adjusts the global music volume. |
| **Toggle Top Bar** | `Ctrl + T` | Toggles the visibility of the navigation top bar. |
| **Toggle Settings** | `Ctrl + O` | Opens/closes the settings drawer. |
| **Toggle Notifications** | `Ctrl + N` | Opens/closes the notifications drawer. |
| **Force Restart** | `Ctrl + Alt + F4` | Instantly reloads the client back to the splash screen. |
| **Pause Game** | `Escape` | Pauses/resumes active gameplay. |

---

## 🏁 Getting Started

### Prerequisites

*   Flutter SDK installed on your machine (`^3.10.7` or later).
*   Dart SDK configured.

### Running the Project

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/[username]/flosu.git
    cd flosu
    ```

2.  **Fetch dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the application**:
    ```bash
    flutter run
    ```
    *(For optimal performance and to test the vertex slider rendering at full speed, build in profile or release mode: `flutter run --profile`)*

---

## 📂 Project Structure

```text
lib/
├── core/             # Base configurations, constants, theme, and geometry math utilities
├── io/               # Beatmap and replay file format parsers
├── layout/           # Main scaffold and global overlay widgets
├── logic/            # State providers, controllers, and services (audio, input, gameloop, etc.)
├── models/           # Data models (beatmaps, inputs, replay files, mods, scores)
└── ui/               # Pages, custom painters, and widget components
```
