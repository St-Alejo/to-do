import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class WeeklyProgressRing extends StatelessWidget {
  final double progress;
  final int completed;
  final int pending;

  const WeeklyProgressRing({
    super.key,
    required this.progress,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 0,
                  centerSpaceRadius: 28,
                  sections: [
                    PieChartSectionData(
                      value: progress > 0 ? progress : 0.001,
                      color: AppTheme.primary,
                      radius: 10,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: progress < 1 ? (1 - progress) : 0.001,
                      color: AppTheme.border,
                      radius: 10,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Weekly Tasks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: AppTheme.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge(
                    value: completed,
                    bgColor: AppTheme.primaryLight,
                    textColor: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    value: pending,
                    bgColor: const Color(0xFFFEF3E0),
                    textColor: const Color(0xFFE8A035),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int value;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.value,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
