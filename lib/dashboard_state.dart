import 'dart:async';
import 'package:flutter/material.dart';
import 'revenue_controller.dart';

class DashboardState extends ChangeNotifier {
  // Mining state variables
  Duration _timeLeft = const Duration(hours: 2, minutes: 18, seconds: 39);
  bool _canCollect = false;
  Timer? _miningTimer;

  // Currency and task counters
  double _userCpPoints = 95240.0;
  int _stepCount = 8412;
  double _totalPlatformProfitUsd = 0.0; // Track your 90% ad cut locally

  // Getters
  String get formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(_timeLeft.inHours);
    String minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    String seconds = twoDigits(_timeLeft.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds Left";
  }

  bool get canCollect => _canCollect;
  double get userCpPoints => _userCpPoints;
  int get stepCount => _stepCount;
  double get totalPlatformProfitUsd => _totalPlatformProfitUsd;

  void startMiningTimer() {
    _miningTimer?.cancel();
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        _timeLeft -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        _canCollect = true;
        _miningTimer?.cancel();
        notifyListeners();
      }
    });
  }

  void collectMiningRewards() {
    if (_canCollect) {
      _userCpPoints += 500; // Reward bonus
      _timeLeft = const Duration(hours: 4, minutes: 0, seconds: 0); // Reset timer
      _canCollect = false;
      startMiningTimer();
      notifyListeners();
    }
  }

  // Simulated ad engine executing your strict 90/10 layout rule
  void watchAdAndEarn() {
    double sampleAdRevenueUsd = 0.05; // Every ad generates 5 cents raw value

    // Process split calculation cleanly via separate controller rules
    final distribution = RevenueController.processAdRevenue(sampleAdRevenueUsd);

    _totalPlatformProfitUsd += distribution['platformProfitUsd']!;
    
    // Convert the user's 10% cash value split safely into game currency (e.g. $1 = 100,000 CP)
    double userCashShare = distribution['userPayoutUsd']!;
    double conversionRateToCp = 100000;
    _userCpPoints += (userCashShare * conversionRateToCp);

    notifyListeners();
  }

  void simulateSteps() {
    if (_stepCount < 10000) {
      _stepCount += 150;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    super.dispose();
  }
}
