import 'package:material_ui/material_ui.dart';

/// The mascot, a bear and gym strongman who keeps your training memoirs
/// (internally called Bench Mark), is built from interchangeable parts, so
/// new variants (seasons, achievements, premium looks) are a new
/// [MarkLook], not a new drawing. He is drawn from the front like an ink
/// sketch in a book.
enum MarkPose {
  /// Fists on the hips, lats spread.
  stand,

  /// A log on the shoulder.
  carry,

  /// A log pressed overhead with both arms.
  lift,

  /// Double biceps.
  flex,

  /// Arms hanging relaxed.
  rest,
}

/// [determined] is a confident grin; [joy] the open-mouthed roar;
/// [focused] gritted teeth for effort.
enum MarkFace { determined, joy, focused, sleepy }

enum MarkEffect { none, sparkles, sweat, zzz }

class MarkLook {
  const MarkLook({
    this.pose = MarkPose.stand,
    this.face = MarkFace.determined,
    this.effect = MarkEffect.none,
    this.belt = true,
    this.quill = false,
    this.shorts = const Color(0xFF3A3530),
    this.gear = const Color(0xFFA8322A),
  });

  final MarkPose pose;
  final MarkFace face;
  final MarkEffect effect;

  /// Leather lifting belt with a gold buckle.
  final bool belt;

  /// A writing quill tucked behind his ear.
  final bool quill;

  /// Color of the gym shorts.
  final Color shorts;

  /// Wrist wraps and the stripe on the shorts.
  final Color gear;

  MarkLook copyWith({
    MarkPose? pose,
    MarkFace? face,
    MarkEffect? effect,
    bool? belt,
    bool? quill,
    Color? shorts,
    Color? gear,
  }) =>
      MarkLook(
        pose: pose ?? this.pose,
        face: face ?? this.face,
        effect: effect ?? this.effect,
        belt: belt ?? this.belt,
        quill: quill ?? this.quill,
        shorts: shorts ?? this.shorts,
        gear: gear ?? this.gear,
      );

  @override
  bool operator ==(Object other) =>
      other is MarkLook &&
      other.pose == pose &&
      other.face == face &&
      other.effect == effect &&
      other.belt == belt &&
      other.quill == quill &&
      other.shorts == shorts &&
      other.gear == gear;

  @override
  int get hashCode => Object.hash(pose, face, effect, belt, quill, shorts, gear);
}
