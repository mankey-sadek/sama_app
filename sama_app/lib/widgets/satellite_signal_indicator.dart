import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// نفس مؤشر أعمدة الإشارة اللي في النموذج الأولي (HTML) — بيتلوّن حسب
/// جودة الاتصال المُمررة له.
class SatelliteSignalIndicator extends StatelessWidget {
  final Color color;
  final double barHeight;

  const SatelliteSignalIndicator({
    super.key,
    this.color = AppColors.statusGood,
    this.barHeight = 11,
  });

  static const List<double> _heights = [0.3, 0.55, 0.75, 1.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _heights
          .map(
            (h) => Container(
              margin: const EdgeInsetsDirectional.only(end: 2),
              width: 3,
              height: barHeight * h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          )
          .toList(),
    );
  }
}
