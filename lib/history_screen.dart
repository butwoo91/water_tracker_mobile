import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/theme.dart';
import 'package:myapp/water_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration History'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer<WaterProvider>(
            builder: (context, waterProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Review your water intake over the last week or month.',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    _buildDateRangeToggle(),
                    const SizedBox(height: 32),
                    Expanded(
                      child: _buildChart(context, waterProvider, constraints),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateRangeToggle() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _selectedDays = 7),
            style: TextButton.styleFrom(
              backgroundColor: _selectedDays == 7
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryColor,
              foregroundColor:
                  _selectedDays == 7 ? Colors.white : AppTheme.primaryColor,
            ),
            child: const Text('Last 7 Days'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _selectedDays = 30),
            style: TextButton.styleFrom(
              backgroundColor: _selectedDays == 30
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryColor,
              foregroundColor:
                  _selectedDays == 30 ? Colors.white : AppTheme.primaryColor,
            ),
            child: const Text('Last 30 Days'),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, WaterProvider waterProvider, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final now = DateTime.now();
    final intakesByDay = <DateTime, int>{};

    final today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < _selectedDays; i++) {
      final day = today.subtract(Duration(days: i));
      intakesByDay[day] = 0;
    }

    for (var intake in waterProvider.intakes) {
      final day =
          DateTime(intake.date.year, intake.date.month, intake.date.day);
      if (intakesByDay.containsKey(day)) {
        intakesByDay[day] = intakesByDay[day]! + intake.amount;
      }
    }

    final sortedEntries = intakesByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final chartData = sortedEntries.map((entry) {
      return BarChartGroupData(
        x: entry.key.millisecondsSinceEpoch,
        barRods: [
          BarChartRodData(
            toY: (entry.value.toDouble() / 1000).clamp(0, 3), // Convert to Liters and clamp to 3L
            color: AppTheme.primaryColor,
            width: _selectedDays == 7 ? (isSmallScreen ? 12 : 22) : (isSmallScreen ? 4 : 8),
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 3, // Set max Y to 3L
        barGroups: chartData,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > 3) return Container();
                return Text('${value.toInt()}L',
                    style: Theme.of(context).textTheme.bodySmall);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1000 * 60 * 60 * 24, // Check every day
              getTitlesWidget: (value, meta) {
                final day = DateTime.fromMillisecondsSinceEpoch(value.toInt());

                if (_selectedDays == 7) {
                  final text = DateFormat.E().format(day);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
                  );
                }

                if (_selectedDays == 30) {
                  final index = sortedEntries.indexWhere((entry) => entry.key.millisecondsSinceEpoch == value.toInt());
                  // Show a label every 8 days to get 4 labels in the 30-day view
                  if (index != -1 && index % 8 == 0) {
                     final text = DateFormat.d().format(day);
                     return SideTitleWidget(
                       axisSide: meta.axisSide,
                       space: 8.0,
                       child: Text(text, style: Theme.of(context).textTheme.bodySmall),
                     );
                  }
                  return const SizedBox.shrink();
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppTheme.secondaryColor,
              strokeWidth: 0.8,
            );
          },
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppTheme.secondaryColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = DateTime.fromMillisecondsSinceEpoch(group.x.toInt());
              return BarTooltipItem(
                '${DateFormat.MMMEd().format(day)}\n',
                Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppTheme.primaryColor),
                children: <TextSpan>[
                  TextSpan(
                    text: '${(rod.toY * 1000).toInt()} ml',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppTheme.primaryColor),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
