import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Timer? _reminderTimer;

  int get goal => _goal;
  List<WaterIntake> get intakes => _intakes;

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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _goal = prefs.getInt('goal') ?? 2500;
    final intakesJson = prefs.getStringList('intakes') ?? [];
    _intakes = intakesJson
        .map((json) => WaterIntake.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', _goal);
    final intakesJson = _intakes.map((intake) => jsonEncode(intake.toJson())).toList();
    await prefs.setStringList('intakes', intakesJson);
  }

  void setReminder(bool enabled, Duration interval) {
    if (enabled) {
      _reminderTimer = Timer.periodic(interval, (timer) {
        // In a real app, this would show a notification.
        print("Time to drink water!");
      });
    } else {
      _reminderTimer?.cancel();
    }
  }
}
