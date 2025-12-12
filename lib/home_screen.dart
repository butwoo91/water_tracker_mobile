import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:myapp/theme.dart';
import 'package:myapp/water_provider.dart';
import 'package:myapp/water_intake_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).pushNamed('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHydrationCard(context, waterProvider),
                const SizedBox(height: 24),
                _buildLogWaterCard(context, waterProvider),
                const SizedBox(height: 24),
                _buildTodaysEntries(context, waterProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHydrationCard(BuildContext context, WaterProvider waterProvider) {
    return Card(
      elevation: 0,
      color: AppTheme.secondaryColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Hydration", style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Log your water intake and track your progress.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: waterProvider.progress,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(waterProvider.progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primaryColor),
                    ),
                    Text('achieved', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                progressColor: AppTheme.primaryColor,
                backgroundColor: Colors.white,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Goal', '${waterProvider.goal} ml', context),
                _buildInfoColumn('Intake', '${waterProvider.todayIntake} ml', context),
                _buildInfoColumn('Remaining', '${waterProvider.goal - waterProvider.todayIntake} ml', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogWaterCard(BuildContext context, WaterProvider waterProvider) {
    final customAmountController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Log Water', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWaterButton(250, context, waterProvider),
            _buildWaterButton(500, context, waterProvider),
            _buildWaterButton(750, context, waterProvider),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: customAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom amount (ml)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                final amount = int.tryParse(customAmountController.text);
                if (amount != null) {
                  waterProvider.addIntake(amount);
                  customAmountController.clear();
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => WaterIntakeDialog(waterProvider: waterProvider),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaysEntries(BuildContext context, WaterProvider waterProvider) {
    final todaysIntakes = waterProvider.intakes
        .where((intake) {
          final now = DateTime.now();
          return intake.date.year == now.year && intake.date.month == now.month && intake.date.day == now.day;
        })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Entries", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        if (todaysIntakes.isEmpty)
          const Text('No entries yet today.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todaysIntakes.length,
            itemBuilder: (context, index) {
              final intake = todaysIntakes[index];
              return ListTile(
                leading: const Icon(Icons.local_drink, color: AppTheme.primaryColor),
                title: Text('${intake.amount} ml'),
                trailing: Text(TimeOfDay.fromDateTime(intake.date).format(context)),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String value, BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildWaterButton(int amount, BuildContext context, WaterProvider waterProvider) {
    return OutlinedButton.icon(
      onPressed: () => waterProvider.addIntake(amount),
      icon: const Icon(Icons.local_drink_outlined),
      label: Text('${amount}ml'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(color: AppTheme.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}
