import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flosu/core/constants.dart';
import 'package:lzma/lzma.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flosu/models/replay/replay_frame.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/io/parser.dart';

/// A parser for `.osr` (osu! replay) files.
///
/// It handles both stable and lazer replay formats, extracting metadata,
/// hit statistics, and cursor movement frames.
class ReplayParser extends Parser<Replay> {
  ReplayParser(super.file);
  int _off = 0;
  late ByteData _data;

  /// Loads the file into memory and calculates the MD5 hash.
  @override
  Future<bool> init() async {
    try {
      final builder = BytesBuilder();

      if (await file.exists()) {
        final read = file.openRead();
        await for (final chunk in read) {
          builder.add(chunk);
        }

        _data = builder.takeBytes().buffer.asByteData();
        md5Hash = md5.convert(builder.takeBytes()).toString();
        return true;
      }
      return false;
    } catch (_) {
      // TODO: ADD THROW
      return false;
    }
  }

  /// Parses the binary data into a [Replay] object.
  @override
  Replay? parse() {
    final mode = readByte();

    // Exit if mode isn't 0 (Standard osu! mode).
    // Other modes like Taiko (1), Catch (2), and Mania (3) are not supported.
    if (mode != 0) return null;

    final version = readInt();
    final beatmapMd5 = readString();
    final playerName = readString();

    // ignore: unused_local_variable
    final replayMd5 = readString(); // replay md5

    final greats = readShort();
    final oks = readShort();
    final mehs = readShort();

    final gekis = readShort();
    final katus = readShort();

    final misses = readShort();
    final score = readInt();

    final maxCombo = readShort();
    final perfect = readByte() == 1;

    final bitMods = readInt();

    final lifeGraph = readString(); // life graph
    final timestamp = readLong(); // timestamp

    final length = readInt();
    // Extract the LZMA compressed replay data block.
    final compressed = Uint8List.sublistView(
      _data,
    ).sublist(_off, _off + length);

    final decompressed = lzma.decode(compressed);
    // Replay data is a string of comma-separated frames: "time|x|y|buttons,..."
    final replayData = String.fromCharCodes(decompressed);

    final rawFrames = replayData
        .split(',')
        .where((e) => e.isNotEmpty)
        .map((e) => e.split('|'))
        .toList();

    List<ReplayFrame> frames = [];
    int time = 0;

    for (final f in rawFrames) {
      final delta = int.parse(f[0]);

      // Skip seed used in Random mod
      if (delta == RANDOM_SEED_DELTA) continue;

      final x = double.parse(f[1]);
      final y = double.parse(f[2]);
      final btns = int.parse(f[3]);

      final keys = OsuKey.pressed(btns);

      time += delta;
      frames.add(ReplayFrame(time, Offset(x, y), keys));
    }

    // Ensure frames are sorted by time
    frames.sortByCompare((frame) => frame.time, (a, b) => a.compareTo(b));

    _off += length + 8;

    Set<ConfigurableMod> mods = {};

    // Try to parse Lazer-specific extra data (JSON) if available.
    try {
      final extraLength = readInt();

      final extrasCompressed = Uint8List.sublistView(
        _data,
      ).sublist(_off, _off + extraLength);
      final extrasDecompressed = lzma.decode(extrasCompressed);

      final extraData = String.fromCharCodes(extrasDecompressed);
      final lazerPayload = jsonDecode(extraData) as Map<String, dynamic>;

      mods = ConfigurableMod.fromLazerPayload(lazerPayload);
    } catch (e) {
      // Replay file is from osu!stable
      mods = ConfigurableMod.fromStableBit(bitMods);
    }

    return Replay(
      version,
      beatmapMd5,
      playerName,
      ReplayHitStats(
        greats,
        oks,
        mehs,
        gekis,
        katus,
        misses,
        score,
        maxCombo,
        perfect,
      ),
      mods,
      lifeGraph,
      timestamp,
      frames,
    );
  }

  /// Reads a single byte (8-bit) from the current offset.
  int readByte() => _data.getUint8(_off++);

  /// Reads a 16-bit integer in little-endian format.
  int readShort() {
    final v = _data.getInt16(_off, Endian.little);
    _off += 2;
    return v;
  }

  /// Reads a 32-bit integer in little-endian format.
  int readInt() {
    final v = _data.getInt32(_off, Endian.little);
    _off += 4;
    return v;
  }

  /// Reads a 64-bit integer in little-endian format.
  int readLong() {
    final v = _data.getInt64(_off, Endian.little);
    _off += 8;
    return v;
  }

  /// Reads an osu! encoded string.
  ///
  /// Strings start with a byte indicating presence (0x0b),
  /// followed by a ULEB128 length and the UTF-8 bytes.
  String readString() {
    if (readByte() == 0x00) return "";
    int shift = 0, result = 0;
    while (true) {
      // Decode ULEB128 length
      int b = readByte();
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) break;
      shift += 7;
    }

    final str = String.fromCharCodes(
      Uint8List.sublistView(_data).sublist(_off, _off + result),
    );
    _off += result;
    return str;
  }
}
