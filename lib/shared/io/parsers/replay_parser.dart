import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:collection/collection.dart';
import 'package:flosu/core/constants.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flosu/models/replay/replay_frame.dart';
import 'package:flosu/shared/io/io_exceptions.dart';
import 'package:flosu/shared/io/parsers/io_parser.dart';
import 'package:lzma/lzma.dart';

class ReplayIncompatibleRulesetException implements Exception {
  ReplayIncompatibleRulesetException();

  @override
  String toString() => "Tried to parse an incompatible ruleset";
}

class ReplayParser extends IoParser<Replay> {
  ReplayParser(super.path);

  int _off = 0;
  late ByteData _data;

  @override
  Future<Replay> parse() async {
    final file = File(path);

    if (!(await file.exists())) {
      throw IoFileReadException("File not found: $path");
    }

    final builder = BytesBuilder();
    final read = file.openRead();

    await for (final chunk in read) {
      builder.add(chunk);
    }

    _data = builder.takeBytes().buffer.asByteData();

    final mode = _readByte();

    // Exit if mode isn't 0 (Standard osu! mode).
    // Other modes like Taiko (1), Catch (2), and Mania (3) are not supported.
    if (mode != 0) throw ReplayIncompatibleRulesetException();

    final version = _readInt();
    final beatmapMd5 = _readString();
    final playerName = _readString();

    _readString(); // replay md5

    final greats = _readShort();
    final oks = _readShort();
    final mehs = _readShort();

    final gekis = _readShort();
    final katus = _readShort();

    final misses = _readShort();
    final score = _readInt();

    final maxCombo = _readShort();
    final perfect = _readByte() == 1;

    final bitMods = _readInt();

    final lifeGraph = _readString(); // life graph
    final timestamp = _readLong(); // timestamp

    final length = _readInt();
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
      final extraLength = _readInt();

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
  int _readByte() => _data.getUint8(_off++);

  /// Reads a 16-bit integer in little-endian format.
  int _readShort() {
    final v = _data.getInt16(_off, Endian.little);
    _off += 2;
    return v;
  }

  /// Reads a 32-bit integer in little-endian format.
  int _readInt() {
    final v = _data.getInt32(_off, Endian.little);
    _off += 4;
    return v;
  }

  /// Reads a 64-bit integer in little-endian format.
  int _readLong() {
    final v = _data.getInt64(_off, Endian.little);
    _off += 8;
    return v;
  }

  /// Reads an osu! encoded string.
  ///
  /// Strings start with a byte indicating presence (0x0b),
  /// followed by a ULEB128 length and the UTF-8 bytes.
  String _readString() {
    if (_readByte() == 0x00) return "";
    int shift = 0, result = 0;
    while (true) {
      // Decode ULEB128 length
      int b = _readByte();
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
