import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/domain/mascot.dart';
import 'package:gymoire/ui/bench_mark.dart';
import 'package:gymoire/ui/mascot/bench_mark_painter.dart';

void main() {
  test('every mood has its own look', () {
    final looks = {for (final m in MascotMood.values) BenchMark.lookFor(m)};
    expect(looks.length, MascotMood.values.length);
    expect(BenchMark.lookFor(MascotMood.record).pose, MarkPose.lift);
    expect(BenchMark.lookFor(MascotMood.resting).effect, MarkEffect.zzz);
  });

  test('every combination of parts paints without errors', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (final pose in MarkPose.values) {
      for (final face in MarkFace.values) {
        for (final effect in MarkEffect.values) {
          for (final extras in [true, false]) {
            BenchMarkPainter(MarkLook(pose: pose, face: face, effect: effect, quill: extras, belt: !extras)).paint(canvas, const Size(100, 100));
          }
        }
      }
    }
    recorder.endRecording().dispose();
  });
}
