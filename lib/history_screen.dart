import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/theme.dart';
import 'package:myapp/water_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                        'Review your water intake over the last week.',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildChart(waterProvider, constraints),
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

  Widget _buildChart(WaterProvider waterProvider, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final now = DateTime.now();
    final intakesByDay = <DateTime, int>{};
    const selectedDays = 7;

    final today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < selectedDays; i++) {
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
            width: isSmallScreen ? 12 : 22,
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
              interval: 1, // Show labels at 0, 1, 2, 3
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
              getTitlesWidget: (value, meta) {
                final day = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(DateFormat.E().format(day), // Show day of the week
                      style: Theme.of(context).textTheme.bodySmall),
                );
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