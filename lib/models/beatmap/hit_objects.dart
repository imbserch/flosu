import 'package:flutter/material.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/math/geometry.dart';
import 'package:flosu/models/beatmap/beatmap.dart';

//Clase para los objetos
sealed class HitObject {
  // Clase contenedor de un objeto cualquiera en osu!
  HitObject({
    required this.pos,
    required this.hitTime,
    required this.color,
    required this.comboIdx,
  });

  /// Posición del objeto con relación al playfield
  ///
  /// Los [Spinner] ignoran esta propiedad
  final Offset pos;

  /// Posición del objeto con respecto al tiempo
  final int hitTime;

  /// Color del elemento (calculado en la carga de mapas)
  ///
  /// Vease [BeatmapLoader.scanBeatmap] y [BeatmapLoader.loadBeatmap]
  final Color color;

  /// Index del combo del elemento (calculado en la carga de mapas)
  ///
  /// Vease [BeatmapLoader.scanBeatmap] y [BeatmapLoader.loadBeatmap]
  final int comboIdx;

  int stackIdx = 0;

  static HitObject? fromList(
    List<String> row,
    Color color,
    int index,
    TimingPoint timing,
    double baseBeatLength,
    double sliderMultiplier,
    double sliderTickRate,
  ) {
    final double x = double.tryParse(row[0]) ?? 0;
    final double y = double.tryParse(row[1]) ?? 0;
    final Offset pos = Offset(x, y);
    final int hitTime = int.tryParse(row[2]) ?? 0;
    final int typeBitmask = int.tryParse(row[3]) ?? 0;

    /// [HitObject] selection
    if (HitObjectType.slider.existsIn(typeBitmask)) {
      final sliderData = row[5].split('|');
      final double length = double.tryParse(row[7]) ?? 0;
      final int repeats = int.tryParse(row[6]) ?? 1;

      // SV
      double velocityMult = 1.0;
      if (timing is ITimingPoint) {
        velocityMult = timing.beatMultiplier;
      }

      // Duration formula: (length / (multiplier * 100 * SV)) * BPM * slides
      final pixelsPerBeat = 100 * sliderMultiplier * velocityMult;
      final beats = length / pixelsPerBeat;
      final duration = beats * baseBeatLength * repeats;

      final tickDistance = pixelsPerBeat / sliderTickRate;
      final ticksPerSlide = ((length - 0.01) / tickDistance).ceil() - 1;

      return Slider(
        pos: pos,
        hitTime: hitTime,
        color: color,
        comboIdx: index,
        duration: duration,
        slides: repeats,
        ticksPerSlide: ticksPerSlide,
        props: SliderProps(
          curveType: SliderCurve.parse(sliderData[0]),
          points: [pos, ..._parseControlPoints(sliderData.sublist(1))],
          length: length,
        ),
      );
    }

    if (HitObjectType.spinner.existsIn(typeBitmask)) {
      final int endTime = int.tryParse(row[5]) ?? hitTime;

      return Spinner(
        pos: const Offset(256, 192),
        hitTime: hitTime,
        color: color,
        comboIdx: index,
        duration: endTime - hitTime,
      );
    }

    return HitCircle(pos: pos, hitTime: hitTime, color: color, comboIdx: index);
  }

  static List<Offset> _parseControlPoints(List<String> points) {
    return points.map((p) {
      final coords = p.split(':');
      if (coords.length < 2) return Offset.zero;
      return Offset(
        double.tryParse(coords[0]) ?? 0,
        double.tryParse(coords[1]) ?? 0,
      );
    }).toList();
  }

  /// Función auxiliar para decidir cuándo mostrar el elemento en el [Playfield]
  bool canShow(int position, BeatmapDifficulty diff);
}

class HitCircle extends HitObject {
  /// Un elemento circular contenido de un [Playfield] al cual se debe apuntar
  /// y hacer click o presionar cualquier tecla al mismo tiempo
  HitCircle({
    required super.pos,
    required super.hitTime,
    required super.color,
    required super.comboIdx,
  });

  /// Un elemento circular contenido de un [Playfield] obtenido de la posición
  /// inicial de un [Slider] el cual tiene la misma mecánica en este caso, el
  /// resto del [Slider] debe mantenerse pulsado
  HitCircle.fromSlider(Slider slider)
    : this(
        pos: slider.pos,
        hitTime: slider.hitTime,
        color: slider.color,
        comboIdx: slider.comboIdx,
      );

  @override
  bool canShow(int position, BeatmapDifficulty difficulty) =>
      (hitTime - position) < difficulty.preempt &&
      (position - hitTime) < difficulty.hit50;

  @override
  String toString() =>
      "Circle: $pos with hitTime at $hitTime ($comboIdx -> ${color.toARGB32()})";
}

class Slider extends HitObject {
  /// Una linea colocada en un [Playfield] al cual se debe
  /// seguir con respecto a un deslizador siguiendo las mecánicas de [HitCircle]
  Slider({
    required super.pos,
    required super.hitTime,
    required this.duration,
    required super.color,
    required super.comboIdx,
    required this.slides,
    required this.ticksPerSlide,
    required this.props,
  }) {
    _loadPath();
  }

  /// Duración del elemento después del [hitTime]
  final double duration;

  /// Cantidad de repeticiones en el slider
  final int slides;

  final int ticksPerSlide;

  /// Propiedades adicionales del slider
  final SliderProps props;

  final List<Offset> points = [];

  void _loadPath() {
    final stackOffset = Offset(4.0 * stackIdx, 4.0 * stackIdx);

    final resPoints = props.points.map((off) => off + stackOffset).toList();

    //Split into segments
    final List<List<Offset>> segments = [];
    List<Offset> currentSegment = [];

    for (int i = 0; i < resPoints.length; i++) {
      currentSegment.add(resPoints[i]);

      if (i + 1 < resPoints.length && resPoints[i] == resPoints[i + 1]) {
        segments.add(currentSegment);
        currentSegment = [];
      }
    }

    if (currentSegment.isNotEmpty) segments.add(currentSegment);

    const pointsDistance = 4.0;

    if (props.curveType == .catmull) {
      final spline = CatmullRomSpline.precompute(resPoints, tension: 0.25);

      //Tolerance: distance between points
      final samples = spline.generateSamples(tolerance: pointsDistance);
      points.addAll(samples.map((s) => s.value));
    } else {
      final List<Offset> curvePoints = [];

      for (final spline in segments) {
        List<Offset> splinePoints = [];

        switch (spline.length) {
          case 0:
            //Empty spline? Skip!
            break;
          case 1:
            final last = points.lastOrNull;

            if (last != null) {
              //If there's other point, connect it with a line
              final line = [last, spline[0]];

              final segments = (Line.getLength(line) / pointsDistance).ceil();
              splinePoints = Line.getSpline(line, segments);
            } else {
              //Only control point
              splinePoints = [spline[0]];
            }
            break;
          case 2:
            //Curve is a line
            ///One point aprox. [pointsDistance] pixels
            final segments = (Line.getLength(spline) / pointsDistance).ceil();
            splinePoints = Line.getSpline(spline, segments);
            break;
          case 3:
            if (props.curveType == .perfect) {
              final arcLen = Arc.getLength(spline);

              if (arcLen != null) {
                //Curve efectivelly is an arc
                ///One point aprox. [pointsDistance] pixels
                final segments = (arcLen / pointsDistance).ceil();
                splinePoints = Arc.getSpline(spline, segments, pointsDistance);
              } else {
                //Curve isn't arc
                //Convert into line
                final line = [spline[0], spline[2]];

                final segments = (Line.getLength(line) / pointsDistance).ceil();
                splinePoints = Line.getSpline(line, segments);
              }
            } else {
              //Curve is a bezier curve of 3rd grade
              final segments = (Bezier.getLength(spline) / pointsDistance)
                  .ceil();
              splinePoints = Bezier.getSpline(spline, segments, pointsDistance);
            }

            break;
          default:
            //Curve is a bezier curve of grade 4+
            final segments = (Bezier.getLength(spline) / pointsDistance).ceil();
            splinePoints = Bezier.getSpline(spline, segments, pointsDistance);
            break;
        }

        curvePoints.addAll(splinePoints);
      }

      //Remove duplicated points
      final filtered = Bezier.filter(curvePoints);
      points.addAll(filtered);
    }
  }

  @override
  bool canShow(int position, BeatmapDifficulty difficulty) {
    final remain = hitTime - position;
    final endSliderAt = hitTime + duration;

    return (remain <= difficulty.preempt && endSliderAt >= position);
  }

  @override
  String toString() =>
      "Slider: $pos with hitTime at $hitTime and $duration ms of duration ($comboIdx -> ${color.toARGB32()})";
}

class Spinner extends HitObject {
  /// Un elemento colocado en el centro de un [Playfield] al cual se debe girar
  Spinner({
    //Se ignora [pos] debido a que este elemento está centrado
    super.pos = Offset.zero,
    required super.hitTime,
    required this.duration,
    required super.color,
    required super.comboIdx,
  });

  /// Duración del elemento después del [hitTime]
  final int duration;

  @override
  bool canShow(int position, BeatmapDifficulty difficulty) {
    final remain = hitTime - position;
    final endSpinAt = hitTime + duration;

    return remain <= -difficulty.preempt || endSpinAt >= position;
  }

  @override
  String toString() =>
      "Spinner: HitTime at $hitTime and $duration ms of duration";
}

class SliderProps {
  SliderProps({
    required this.curveType,
    required this.points,
    required this.length,
  });

  /// Describe el tipo de curva tomada en el slider
  ///
  /// Las curvas marcadas como Bezier (B) aún pueden contar
  /// con secciones lineales (L)
  final SliderCurve curveType;

  /// La lista de puntos del slider
  final List<Offset> points;

  /// Referencia de tamaño del slider
  /// [SliderPainter] ignora esta propiedad parcialmente
  final double length;
}
