import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EcosimRadarChart extends StatelessWidget {
  final List<double>? values;
  final List<double>? projectedValues;
  final List<List<double>>? multipleDatasets;
  final List<Color>? multipleColors;
  final List<String> labels;
  final double size;
  final Color? baselineColor;
  final Color? projectedColor;

  const EcosimRadarChart({
    super.key,
    this.values,
    this.projectedValues,
    this.multipleDatasets,
    this.multipleColors,
    this.labels = const [
      'Pengelolaan Limbah',
      'Kualitas Air',
      'Pengelolaan Lingkungan',
      'Ketahanan\nBencana',
    ],
    this.size = 220,
    this.baselineColor,
    this.projectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      child: CustomPaint(
        size: Size(size, size),
        painter: _RadarChartPainter(
          values: values,
          projectedValues: projectedValues,
          multipleDatasets: multipleDatasets,
          multipleColors: multipleColors,
          labels: labels,
          baselineColor: baselineColor,
          projectedColor: projectedColor,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<List<double>> datasets;
  final List<Color> colors;
  final List<String> labels;

  _RadarChartPainter({
    required List<double>? values,
    required List<double>? projectedValues,
    required List<List<double>>? multipleDatasets,
    required List<Color>? multipleColors,
    required this.labels,
    Color? baselineColor,
    Color? projectedColor,
  })  : datasets = multipleDatasets ??
            [
              values ?? [2.0, 2.0, 2.0, 2.0],
              if (projectedValues != null) projectedValues,
            ],
        colors = multipleColors ??
            [
              baselineColor ?? const Color(0xFFEBB629),
              if (projectedValues != null) projectedColor ?? const Color(0xFF0D6EFD),
            ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2.7;

    // Paints for grid/axis
    final gridPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    // Draw concentric diamond grid (4 levels: 1, 2, 3, 4)
    for (int i = 1; i <= 4; i++) {
      final r = maxRadius * (i / 4.0);
      final gridPath = Path()
        ..moveTo(center.dx, center.dy - r) // Top
        ..lineTo(center.dx + r, center.dy) // Right
        ..lineTo(center.dx, center.dy + r) // Bottom
        ..lineTo(center.dx - r, center.dy) // Left
        ..close();
      canvas.drawPath(gridPath, gridPaint);
    }

    // Draw the 4 axes
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), axisPaint); // Vertical
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), axisPaint); // Horizontal

    // Draw labels
    final labelStyles = [
      const TextStyle(color: AppTheme.textMedium, fontSize: 8.0, fontWeight: FontWeight.bold),
      const TextStyle(color: AppTheme.textMedium, fontSize: 8.0, fontWeight: FontWeight.bold),
      const TextStyle(color: AppTheme.textMedium, fontSize: 8.0, fontWeight: FontWeight.bold),
      const TextStyle(color: AppTheme.textMedium, fontSize: 8.0, fontWeight: FontWeight.bold),
    ];

    final labelPositions = [
      Offset(center.dx, center.dy - maxRadius - 12), // Top
      Offset(center.dx + maxRadius + 4, center.dy), // Right
      Offset(center.dx, center.dy + maxRadius + 4), // Bottom
      Offset(center.dx - maxRadius - 4, center.dy), // Left
    ];

    for (int i = 0; i < 4; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyles[i]),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      Offset adjustedOffset = labelPositions[i];
      if (i == 0) {
        adjustedOffset = Offset(adjustedOffset.dx - textPainter.width / 2, adjustedOffset.dy);
      } else if (i == 1) {
        adjustedOffset = Offset(adjustedOffset.dx, adjustedOffset.dy - textPainter.height / 2);
      } else if (i == 2) {
        adjustedOffset = Offset(adjustedOffset.dx - textPainter.width / 2, adjustedOffset.dy);
      } else if (i == 3) {
        adjustedOffset = Offset(adjustedOffset.dx - textPainter.width, adjustedOffset.dy - textPainter.height / 2);
      }

      textPainter.paint(canvas, adjustedOffset);
    }

    // Function to calculate polygon vertices from values
    Path getPolygonPath(List<double> vals) {
      final path = Path();
      // Level clamp: 1 to 4
      final tVal = vals[0].clamp(1.0, 4.0);
      final rVal = vals[1].clamp(1.0, 4.0);
      final bVal = vals[2].clamp(1.0, 4.0);
      final lVal = vals[3].clamp(1.0, 4.0);

      final tRadius = maxRadius * (tVal / 4.0);
      final rRadius = maxRadius * (rVal / 4.0);
      final bRadius = maxRadius * (bVal / 4.0);
      final lRadius = maxRadius * (lVal / 4.0);

      path.moveTo(center.dx, center.dy - tRadius);
      path.lineTo(center.dx + rRadius, center.dy);
      path.lineTo(center.dx, center.dy + bRadius);
      path.lineTo(center.dx - lRadius, center.dy);
      path.close();

      return path;
    }

    // Draw all datasets
    for (int idx = 0; idx < datasets.length; idx++) {
      final valList = datasets[idx];
      final color = colors[idx % colors.length];

      final fillPaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final path = getPolygonPath(valList);
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return true;
  }
}
