import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/stats_provider.dart';
import '../widgets/stat_mini_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const _categoryColors = {
    'Healthy': Color(0xFF4CAF50),
    'Design': Color(0xFFFF9800),
    'Job': Color(0xFF2196F3),
    'Education': Color(0xFF9C27B0),
    'Sport': Color(0xFFF44336),
  };

  Color _colorFor(String name) =>
      _categoryColors[name] ?? AppTheme.primary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<StatsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary));
            }
            final categoryDist = provider.categoryDistribution;
            final categoryTotals = provider.categoryTotals;
            final dailyProgress = provider.weeklyDailyProgress;
            final maxDaily = dailyProgress.isEmpty
                ? 1
                : dailyProgress.reduce((a, b) => a > b ? a : b);
            final totalCompleted = categoryDist.values.fold(0, (a, b) => a + b);

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => provider.loadStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estadísticas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mini cards row
                    Row(
                      children: [
                        Expanded(
                          child: StatMiniCard(
                            value: provider.completed,
                            label: 'Completadas',
                            valueColor: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatMiniCard(
                            value: provider.pending,
                            label: 'Pendientes',
                            valueColor: const Color(0xFFE8A035),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatMiniCard(
                            value: provider.overdue,
                            label: 'Vencidas',
                            valueColor: AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Donut chart
                    if (categoryDist.isNotEmpty) ...[
                      const Text(
                        'Por Categoría',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 36,
                                sections: categoryDist.entries.map((e) {
                                  return PieChartSectionData(
                                    value: e.value.toDouble(),
                                    color: _colorFor(e.key),
                                    radius: 22,
                                    showTitle: false,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: categoryDist.entries.map((e) {
                                final pct = totalCompleted > 0
                                    ? (e.value / totalCompleted * 100).round()
                                    : 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _colorFor(e.key),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          e.key,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$pct%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],
                    // Weekly bar chart
                    const Text(
                      'Progreso Semanal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          maxY: (maxDaily + 1).toDouble(),
                          barGroups: List.generate(7, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: dailyProgress[i].toDouble(),
                                  color: dailyProgress[i] > 0
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'Lun', 'Mar', 'Mié',
                                    'Jue', 'Vie', 'Sáb', 'Dom'
                                  ];
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Category horizontal bars
                    if (categoryTotals.isNotEmpty) ...[
                      const Text(
                        'Total por Categoría',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...() {
                        final maxCount = categoryTotals.values.isEmpty
                            ? 1
                            : categoryTotals.values.reduce((a, b) => a > b ? a : b);
                        final sorted = categoryTotals.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        return sorted.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _colorFor(e.key),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: e.value / maxCount,
                                      backgroundColor: AppTheme.border,
                                      valueColor: AlwaysStoppedAnimation(
                                          _colorFor(e.key)),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  e.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      }(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
