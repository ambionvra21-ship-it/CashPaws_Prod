import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'payout_screen.dart';
import 'home_tasks_panel.dart';

class CashPawsHomeScreen extends StatefulWidget {
  final String userId;
  final int initialCoins;

  const CashPawsHomeScreen({
    super.key,
    required this.userId,
    required this.initialCoins,
  });

  @override
  State<CashPawsHomeScreen> createState() => _CashPawsHomeScreenState();
}

class _CashPawsHomeScreenState extends State<CashPawsHomeScreen> {
  int _totalPawCoins = 0;
  
  Timer? _miningTimer;
  Duration _miningDurationRemaining = const Duration(hours: 3);
  bool _isMiningActive = false;
  bool _canClaimMiningCoins = false;

  int _petGrowthPoints = 0;
  String _petStage = 'Kitten/Baby';
  String _petType = 'Cat';

  RewardedAd? _homeRewardedAd;
  bool _isAdLoading = false;
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void initState() {
    super.initState();
    _totalPawCoins = widget.initialCoins;
    _loadRewardedAdCache();
    _evaluatePetEvolutionStage();
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    _homeRewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAdCache() {
    if (_isAdLoading || _homeRewardedAd != null) return;
    setState(() => _isAdLoading = true);

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _homeRewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (err) {
          _homeRewardedAd = null;
          _isAdLoading = false;
          debugPrint('Dashboard ad cache failed: $err');
        },
      ),
    );
  }

  void _evaluatePetEvolutionStage() {
    if (_petGrowthPoints >= 500) {
      _petStage = 'Fully Grown Adult';
    } else if (_petGrowthPoints >= 200) {
      _petStage = 'Juvenile/Teen';
    } else {
      _petStage = 'Kitten/Baby';
    }
  }

  void _updateCoinsFromTasks(int earnedAmount) {
    setState(() {
      _totalPawCoins += earnedAmount;
      _petGrowthPoints += (earnedAmount ~/ 2);
      _evaluatePetEvolutionStage();
    });
  }

  void _startMiningSession() {
    if (_isMiningActive) return;

    setState(() {
      _isMiningActive = true;
      _canClaimMiningCoins = false;
      _miningDurationRemaining = const Duration(hours: 3);
    });

    _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_miningDurationRemaining.inSeconds > 0) {
          _miningDurationRemaining = _miningDurationRemaining - const Duration(seconds: 1);
        } else {
          _miningTimer?.cancel();
          _isMiningActive = false;
          _canClaimMiningCoins = true;
        }
      });
    });
  }

  void _claimMiningRewards() {
    if (!_canClaimMiningCoins) return;

    if (_homeRewardedAd != null) {
      _homeRewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(() {
          _totalPawCoins += 150;
          _canClaimMiningCoins = false;
          _petGrowthPoints += 50;
          _evaluatePetEvolutionStage();
        });
        _loadRewardedAdCache();
        _showSuccessSnackBar('🎉 Earned 150 PawCoins!');
      });
    } else {
      _showSuccessSnackBar('Synchronizing ad ledger... Please try again.');
      _loadRewardedAdCache();
    }
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
