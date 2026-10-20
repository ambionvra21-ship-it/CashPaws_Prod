import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'payout_screen.dart';
// import 'walk_screen.dart'; // Uncomment once fully verified in your project tree

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
  
  // Mining Timer Controls
  Timer? _miningTimer;
  Duration _miningDurationRemaining = const Duration(hours: 3);
  bool _isMiningActive = false;
  bool _canClaimMiningCoins = false;

  // AdMob Handlers
  RewardedAd? _homeRewardedAd;
  bool _isAdLoading = false;
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  @override
  void initState() {
    super.initState();
    _totalPawCoins = widget.initialCoins;
    _loadRewardedAdCache();
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

  // Starts the 3-Hour Tap-To-Earn cloud miner node sequence
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
          _canClaimMiningCoins = true; // Unlocks the claim coin state layer
        }
      });
    });
  }

  // Intercepts the reward submission using your AdMob gating layer
  void _claimMiningRewards() {
    if (!_canClaimMiningCoins) return;

    if (_homeRewardedAd != null) {
      _homeRewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(() {
          _totalPawCoins += 150; // Secure distribution allocation rule amount
          _canClaimMiningCoins = false;
        });
        _loadRewardedAdCache(); // Refresh back-buffer ad cache thread
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Tracking Widget Panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: CashPawsColors.cardNavy, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Balance:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text('$_totalPawCoins PawCoins', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 3-Hour Tap to Earn / Cloud Mining Modular Interface
              const Text('TAP TO EARN MINER', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: CashPawsColors.cardNavy, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    if (_isMiningActive) ...[
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen)),
                      const SizedBox(height: 15),
                      Text('Mining Active: ${_formatDuration(_miningDurationRemaining)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ] else if (_canClaimMiningCoins) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen, minimumSize: const Size(double.infinity, 48)),
                        onPressed: _claimMiningRewards,
                        child: const Text('CLAIM 150 PAWCOINS (WATCH AD)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], minimumSize: const Size(double.infinity, 48)),
                        onPressed: _startMiningSession,
                        child: const Text('START 3-HOUR MINING SESSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Background Active Step Counter Route Quick-Link Panel
              const Text('PASSIVE TRACKERS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  // Navigation target route to your existing background walking logic screen
                  _showSuccessSnackBar('Syncing background step ledger stream...');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: CashPawsColors.cardNavy, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_walk, color: CashPawsColors.neonGreen, size: 32),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Background Step Counter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Syncing live phone sensors...', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
