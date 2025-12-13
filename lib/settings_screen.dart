import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/theme.dart';
import 'package:myapp/water_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _goalController;
  bool _remindersEnabled = false;
  String _reminderInterval = 'Every 1 hour';

  @override
  void initState() {
    super.initState();
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);
    _goalController =
        TextEditingController(text: waterProvider.goal.toString());
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
                        'Adjust your daily hydration goals and reminder preferences.',
                        style: Theme.of(context).textTheme.bodyMedium),
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
                    SwitchListTile(
                      title: Text('Reminders',
                          style: Theme.of(context).textTheme.titleMedium),
                      value: _remindersEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _remindersEnabled = value;
                          waterProvider.setReminder(
                              value, _getIntervalDuration());
                        });
                      },
                      activeThumbColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth > 600 ? 16 : 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_remindersEnabled)
                      DropdownButtonFormField<String>(
                        initialValue: _reminderInterval,
                        decoration: InputDecoration(
                          labelText: 'Interval',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: <String>[
                          'Every 30 minutes',
                          'Every 1 hour',
                          'Every 1.5 hours',
                          'Every 2 hours'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _reminderInterval = newValue!;
                            waterProvider.setReminder(
                                _remindersEnabled, _getIntervalDuration());
                          });
                        },
                      ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Duration _getIntervalDuration() {
    switch (_reminderInterval) {
      case 'Every 30 minutes':
        return const Duration(minutes: 30);
      case 'Every 1 hour':
        return const Duration(hours: 1);
      case 'Every 1.5 hours':
        return const Duration(minutes: 90);
      case 'Every 2 hours':
        return const Duration(hours: 2);
      default:
        return const Duration(hours: 1);
    }
  }
}
