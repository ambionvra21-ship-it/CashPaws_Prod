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

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      appBar: AppBar(
        backgroundColor: CashPawsColors.backgroundMidnight,
        elevation: 0,
        title: const Text('🐾 CASHPAWS HUB', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: CashPawsColors.neonGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CashPawsPayoutScreen(
                    currentCoins: _totalPawCoins,
                    currentUserId: widget.userId,
                    onBalanceChanged: (newBalance) {
                      setState(() => _totalPawCoins = newBalance);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Coin Balance Tracker Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CashPawsColors.cardNavy, 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Balance:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text('$_totalPawCoins PawCoins', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Virtual Pet Growth & Evolutionary Avatar Display Module
              const Text('VIRTUAL PET COMPANION', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CashPawsColors.cardNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Renders a styled icon silhouette matching the active pet category
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CashPawsColors.backgroundMidnight,
                            shape: BoxShape.circle,
                            border: Border.all(color: CashPawsColors.neonGreen, width: 2),
                          ),
                          child: Icon(
                            _petType == 'Cat' ? Icons.pets : Icons.cruelty_free,
                            color: CashPawsColors.neonGreen,
                            size: 40,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Status: $_petStage', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Growth Points: $_petGrowthPoints XP', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 6),
                            // Quick toggle button layout allowing users to swap companions smoothly
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _petType = _petType == 'Cat' ? 'Dog' : 'Cat';
                                });
                              },
                              child: Text(
                                'Swap Companion Profile (Active: $_petType)',
                                style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 11, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Visual progress indicator tracking growth progression bar layers
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_petGrowthPoints % 200) / 200.0,
                        backgroundColor: CashPawsColors.backgroundMidnight,
                        valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3-Hour Tap to Earn Cloud Miner Section
              const Text('TAP TO EARN MINER', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CashPawsColors.cardNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_isMiningActive) ...[
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen)),
                      const SizedBox(height: 15),
                      Text('Mining Active: ${_formatDuration(_miningDurationRemaining)}', style: const TextStyle(color: Colors.white, fontSize: 15)),
                    ] else if (_canClaimMiningCoins) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen, minimumSize: const Size(double.infinity, 44)),
                        onPressed: _claimMiningRewards,
                        child: const Text('CLAIM 150 PAWCOINS (WATCH AD)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ] else ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, minimumSize: const Size(double.infinity, 44)),
                        onPressed: _startMiningSession,
                        child: const Text('START 3-HOUR MINING SESSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Embedded Live Daily Bounties Tasks Panel Sub-Widget Reference
              CashPawsTasksPanel(
                currentCoins: _totalPawCoins,
                onCoinsEarned: _updateCoinsFromTasks,
              ),
              const SizedBox(height: 24),

              // Passive Background Step Counter Quick-Link Router Entry Card
              const Text('PASSIVE TRACKERS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  _showSuccessSnackBar('Syncing background step ledger stream sensors...');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CashPawsColors.cardNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_walk, color: CashPawsColors.neonGreen, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Background Step Counter', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text('Syncing live phone sensors...', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
