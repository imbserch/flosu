part of "beatmap.dart";

enum EventType { background, video, sound }

sealed class Event {
  const Event(this.type, this.startTime);

  final EventType type;
  final int startTime;
}

class BackgroundEvent extends Event {
  BackgroundEvent(String path, int startTime)
    : assert(
        File(path).existsSync(),
        "A background event's file doesn't exists",
      ),
      file = File(path),
      super(EventType.background, startTime);

  final File file;
}

class VideoEvent extends Event {
  VideoEvent(String path, int startTime)
    : assert(File(path).existsSync(), "A video event's file doesn't exists"),
      file = File(path),
      super(EventType.video, startTime);

  final File file;
}
