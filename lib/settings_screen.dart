import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/water_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);
    _goalController = TextEditingController(text: waterProvider.goal.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<WaterProvider>(
                  builder: (context, waterProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust your daily hydration goals.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _goalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Daily Goal (ml)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        final newGoal = int.tryParse(value);
                        if (newGoal != null) {
                          waterProvider.setGoal(newGoal);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
