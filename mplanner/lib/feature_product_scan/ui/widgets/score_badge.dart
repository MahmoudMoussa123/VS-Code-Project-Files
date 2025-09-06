import 'package:flutter/material.dart';
import '../../../shared/models/score.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score});
  final Score? score;

  Color _color(double v) {
    if (v >= 80) return Colors.green;
    if (v >= 60) return Colors.lightGreen;
    if (v >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final v = score!.total;
    return Semantics(
      label: 'Health score $v',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _color(v),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          v.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}