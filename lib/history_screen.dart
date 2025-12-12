import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/theme.dart';
import 'package:myapp/water_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration History'),
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review your water intake over the last week or month.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                _buildDateRangeToggle(),
                const SizedBox(height: 32),
                SizedBox(
                  height: 300,
                  child: _buildChart(waterProvider),
                ),
              ],
            ),
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
            style: TextButton.stylefrom(
              backgroundColor: _selectedDays == 7 ? AppTheme.primaryColor : AppTheme.secondaryColor,
              foregroundColor: _selectedDays == 7 ? Colors.white : AppTheme.primaryColor,
            ),
            child: const Text('Last 7 Days'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _selectedDays = 30),
            style: TextButton.stylefrom(
              backgroundColor: _selectedDays == 30 ? AppTheme.primaryColor : AppTheme.secondaryColor,
              foregroundColor: _selectedDays == 30 ? Colors.white : AppTheme.primaryColor,
            ),
            child: const Text('Last 30 Days'),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(WaterProvider waterProvider) {
    final now = DateTime.now();
    final intakesByDay = <DateTime, int>{};

    for (int i = 0; i < _selectedDays; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      intakesByDay[day] = 0;
    }

    for (var intake in waterProvider.intakes) {
      final day = DateTime(intake.date.year, intake.date.month, intake.date.day);
      if (intakesByDay.containsKey(day)) {
        intakesByDay[day] = intakesByDay[day]! + intake.amount;
      }
    }

    final chartData = intakesByDay.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.day,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble() / 1000, // Convert to Liters
            color: AppTheme.primaryColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: chartData,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value}L', style: Theme.of(context).textTheme.bodySmall);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final day = now.subtract(Duration(days: now.day - value.toInt()));
                return Text(DateFormat.E().format(day), style: Theme.of(context).textTheme.bodySmall);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
      ),
    );
  }
}
