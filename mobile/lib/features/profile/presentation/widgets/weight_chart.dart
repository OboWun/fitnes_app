import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/weight_record.dart';
import '../../../../design_system/design_system.dart';

class WeightChart extends StatelessWidget {
  final List<WeightRecord>? _records;
  final WeightPeriod _period;

  const WeightChart({
    super.key,
    required List<WeightRecord> records,
    required WeightPeriod period,
  })  : _records = records,
        _period = period;

  const WeightChart.loading({super.key, required WeightPeriod period})
      : _records = null,
        _period = period;

  @override
  Widget build(BuildContext context) {
    if (_records == null || _records.isEmpty) {
      return _WeightChartEmpty(period: _period);
    }
    return _WeightChartData(records: _records, period: _period);
  }
}

class _WeightChartData extends StatelessWidget {
  final List<WeightRecord> records;
  final WeightPeriod period;

  const _WeightChartData({required this.records, required this.period});

  @override
  Widget build(BuildContext context) {
    final sorted = List<WeightRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Динамика веса',
          style:
              AppTypography.largeTextSemiBold.copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: _WeightChartPainter(
              records: sorted,
              lineColor: const Color(0xFF92A3FD),
              gradientColors: const [
                Color(0xFF92A3FD),
                Color(0xFF9DCEFF),
              ],
              dotColor: const Color(0xFF92A3FD),
              textColor: AppColors.gray2,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final Color lineColor;
  final List<Color> gradientColors;
  final Color dotColor;
  final Color textColor;

  _WeightChartPainter({
    required this.records,
    required this.lineColor,
    required this.gradientColors,
    required this.dotColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final weights = records.map((r) => r.weight).toList();
    final minWeight = weights.reduce(min);
    final maxWeight = weights.reduce(max);
    final weightRange = maxWeight - minWeight;
    final padding = weightRange == 0 ? 1.0 : weightRange * 0.15;
    final effectiveMin = minWeight - padding;
    final effectiveMax = maxWeight + padding;
    final range = effectiveMax - effectiveMin;

    const leftPadding = 40.0;
    const bottomPadding = 24.0;
    const topPadding = 8.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    final yLabels = <double>[];
    final yStep = range / 4;
    for (int i = 0; i <= 4; i++) {
      yLabels.add(effectiveMin + yStep * i);
    }

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final label in yLabels) {
      labelPainter.text = TextSpan(
        text: label.toStringAsFixed(1),
        style: TextStyle(color: textColor, fontSize: 9),
      );
      labelPainter.layout();
      final y =
          topPadding + chartHeight - ((label - effectiveMin) / range) * chartHeight;
      labelPainter.paint(
          canvas, Offset(leftPadding - labelPainter.width - 4, y - 5));
    }

    final points = <Offset>[];
    for (int i = 0; i < records.length; i++) {
      final x = leftPadding + (i / max(records.length - 1, 1)) * chartWidth;
      final y = topPadding +
          chartHeight -
          ((records[i].weight - effectiveMin) / range) * chartHeight;
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final cpx = (prev.dx + curr.dx) / 2;
        path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
      }

      final fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, size.height - bottomPadding);
      fillPath.lineTo(points.first.dx, size.height - bottomPadding);
      fillPath.close();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColors.first.withValues(alpha: 0.3),
          gradientColors.last.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(
        fillPath,
        Paint()..shader = gradient,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()..color = dotColor,
      );
      canvas.drawCircle(
        point,
        2,
        Paint()..color = AppColors.whiteColor,
      );
    }

    final datePainter = TextPainter(textDirection: TextDirection.ltr);
    final step = records.length <= 5 ? 1 : (records.length / 5).ceil();
    for (int i = 0; i < records.length; i += step) {
      final d = records[i].date;
      datePainter.text = TextSpan(
        text: '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}',
        style: TextStyle(color: textColor, fontSize: 9),
      );
      datePainter.layout();
      final x = leftPadding +
          (i / max(records.length - 1, 1)) * chartWidth -
          datePainter.width / 2;
      datePainter.paint(
          canvas, Offset(x, size.height - bottomPadding + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.records != records;
  }
}

class _WeightChartEmpty extends StatelessWidget {
  final WeightPeriod period;

  const _WeightChartEmpty({required this.period});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Динамика веса',
          style: AppTypography.largeTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: Center(
            child: Text(
              'Недостаточно данных',
              style: AppTypography.mediumTextRegular
                  .copyWith(color: AppColors.gray2),
            ),
          ),
        ),
      ],
    );
  }
}
