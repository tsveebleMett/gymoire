import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'format.dart';
import 'theme.dart';

/// A number field with large minus and plus buttons for one-handed use with
/// sweaty fingers. The text stays editable for exact values.
class NumberStepper extends StatefulWidget {
  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.step,
    required this.onChanged,
    this.decimals = true,
    this.unit,
  });

  final String label;
  final double value;
  final double step;
  final bool decimals;
  final String? unit;
  final ValueChanged<double> onChanged;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late final _controller = TextEditingController(text: _format(widget.value));

  String _format(double v) => widget.decimals ? formatKg(v) : v.round().toString();

  @override
  void didUpdateWidget(NumberStepper old) {
    super.didUpdateWidget(old);
    // Only rewrite the text when the value really differs, so typing "82,"
    // is not replaced by "82" mid-edit.
    if (parseKg(_controller.text) != widget.value) _controller.text = _format(widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bump(double delta) {
    // The field text is the latest value even before the parent rebuilt.
    final current = parseKg(_controller.text) ?? widget.value;
    final next = ((current + delta) * 100).round() / 100;
    final clamped = next.clamp(0.0, 9999.0);
    _controller.text = _format(clamped);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: text.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _RoundButton(key: Key('${widget.label}-minus'), icon: Icons.remove_rounded, onTap: () => _bump(-widget.step)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: Key('${widget.label}-field'),
                controller: _controller,
                textAlign: TextAlign.center,
                style: text.headlineMedium,
                keyboardType: TextInputType.numberWithOptions(decimal: widget.decimals),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(widget.decimals ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(suffixText: widget.unit),
                onChanged: (t) {
                  final v = parseKg(t);
                  if (v != null) widget.onChanged(v);
                },
              ),
            ),
            const SizedBox(width: 12),
            _RoundButton(key: Key('${widget.label}-plus'), icon: Icons.add_rounded, onTap: () => _bump(widget.step)),
          ],
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: furLight,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(dimension: 56, child: Icon(icon, color: cocoa, size: 30)),
        ),
      );
}
