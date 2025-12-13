import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/notification_service.dart';

class WaterIntake {
  final DateTime date;
  final int amount;

  WaterIntake({required this.date, required this.amount});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
      };

  factory WaterIntake.fromJson(Map<String, dynamic> json) => WaterIntake(
        date: DateTime.parse(json['date']),
        amount: json['amount'],
      );
}

class WaterProvider with ChangeNotifier {
  int _goal = 2500;
  List<WaterIntake> _intakes = [];
  bool _remindersEnabled = false;
  TimeOfDay? _reminderTime;

  int get goal => _goal;
  List<WaterIntake> get intakes => _intakes;
  bool get remindersEnabled => _remindersEnabled;
  TimeOfDay? get reminderTime => _reminderTime;

  int get todayIntake {
    final now = DateTime.now();
    return _intakes
        .where((intake) =>
            intake.date.year == now.year &&
            intake.date.month == now.month &&
            intake.date.day == now.day)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get progress => todayIntake / _goal;

  WaterProvider() {
    _loadData();
  }

  void addIntake(int amount) {
    _intakes.add(WaterIntake(date: DateTime.now(), amount: amount));
    _saveData();
    notifyListeners();
  }

  void setGoal(int newGoal) {
    _goal = newGoal;
    _saveData();
    notifyListeners();
  }

  void setRemindersEnabled(bool enabled) {
    _remindersEnabled = enabled;
    if (enabled && _reminderTime != null) {
      NotificationService().scheduleNotification(_reminderTime!.hour, _reminderTime!.minute);
    } else {
      NotificationService().cancelAllNotifications();
    }
    _saveData();
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
    if (_remindersEnabled) {
      NotificationService().scheduleNotification(time.hour, time.minute);
    }
    _saveData();
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _goal = prefs.getInt('goal') ?? 2500;
    final intakesJson = prefs.getStringList('intakes') ?? [];
    _intakes = intakesJson
        .map((json) => WaterIntake.fromJson(jsonDecode(json)))
        .toList();
    _remindersEnabled = prefs.getBool('remindersEnabled') ?? false;
    final reminderHour = prefs.getInt('reminderHour');
    final reminderMinute = prefs.getInt('reminderMinute');
    if (reminderHour != null && reminderMinute != null) {
      _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', _goal);
    final intakesJson =
        _intakes.map((intake) => jsonEncode(intake.toJson())).toList();
    await prefs.setStringList('intakes', intakesJson);
    await prefs.setBool('remindersEnabled', _remindersEnabled);
    if (_reminderTime != null) {
      await prefs.setInt('reminderHour', _reminderTime!.hour);
      await prefs.setInt('reminderMinute', _reminderTime!.minute);
    }
  }
}
