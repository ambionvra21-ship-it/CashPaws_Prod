import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'payout_screen.dart';

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
  final int _targetCoinsThreshold = 100000; // 100,000 Coins = $10.00 Minimum Payout Tier

  // 1. Daily Check-in Streak Tracking Configurations
  bool _hasClaimedCheckInToday = false;
  int _consecutiveCheckInDays = 0;

  // 2. Paws Mining Background Engine Timers
  Timer? _miningCountDownTimer;
  Duration _miningTimeLeftLeft = const Duration(hours: 3);
  bool _isMiningSessionActive = false;
  bool _canClaimCompletedMining = false;
  String _activeCompanionType = 'Cat'; // Companion profile defaults to Cat

  // 3. Lucky Spin Wheel State Boundaries
  int _luckySpinsUsedCount = 0;
  final int _maxDailySpinsAllowed = 5;

  // 4. Premium Video Reward Tracker Limits
  int _premiumVideosWatchedCount = 0;
  final int _maxDailyVideosAllowed = 5;

  // 5. Paws Step Walking Passive Tracker Data
  int _mockLiveStepsWalked = 0;
  final int _dailyStepsTargetGoal = 5000;

  // 6. Paws Tap Coins Passive Clicking Variables
  int _tapAccumulationTracker = 0;

  // Google Mobile Ads Framework Integrations
  BannerAd? _topAdMobBanner;
  BannerAd? _bottomAdMobBanner;
  bool _isTopBannerAdLoaded = false;
  bool _isBottomBannerAdLoaded = false;

  // Official Test Ad Unit ID allocations to bypass device confirmation holds
  final String _testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _totalPawCoins = widget.initialCoins;
    _initializeUnifiedAdMobBanners();
  }

  @override
  void dispose() {
    _miningCountDownTimer?.cancel();
    _topAdMobBanner?.dispose();
    _bottomAdMobBanner?.dispose();
    super.dispose();
  }

  void _initializeUnifiedAdMobBanners() {
    // Allocates and loads top layout monetization bar
    _topAdMobBanner = BannerAd(
      adUnitId: _testBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isTopBannerAdLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Top Dashboard Banner failed to load: $err');
        },
      ),
    )..load();

    // Allocates and loads bottom layout monetization bar
    _bottomAdMobBanner = BannerAd(
      adUnitId: _testBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isBottomBannerAdLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Bottom Dashboard Banner failed to load: $err');
        },
      ),
    )..load();
  }

  // Feature 1 Execution Method
  void _executeDailyCheckInClaim() {
    if (_hasClaimedCheckInToday) return;
    setState(() {
      _hasClaimedCheckInToday = true;
      _consecutiveCheckInDays += 1;
      _totalPawCoins += 250; // Secures your profit distribution structure ratio
    });
    _showFeedbackToast('📆 Day $_consecutiveCheckInDays Claimed! +250 PawCoins added.');
  }

  // Feature 2 Execution Methods
  void _startThreeHourMiningLoop() {
    if (_isMiningSessionActive) return;
    setState(() {
      _isMiningSessionActive = true;
      _canClaimCompletedMining = false;
      _miningTimeLeftLeft = const Duration(hours: 3);
    });

    _miningCountDownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_miningTimeLeftLeft.inSeconds > 0) {
          _miningTimeLeftLeft = _miningTimeLeftLeft - const Duration(seconds: 1);
        } else {
          _miningCountDownTimer?.cancel();
          _isMiningSessionActive = false;
          _canClaimCompletedMining = true;
        }
      });
    });
  }

  void _claimCompletedMiningCoins() {
    if (!_canClaimCompletedMining) return;
    setState(() {
      _totalPawCoins += 500;
      _canClaimCompletedMining = false;
    });
    _showFeedbackToast('🎉 Cloud Mining complete! +500 PawCoins added.');
  }

  // Feature 3 Execution Method
  void _triggerLuckySpinAction() {
    if (_luckySpinsUsedCount >= _maxDailySpinsAllowed) {
      _showLimitAlert('Lucky Spin Limit', 'Daily spins capped at 5 to protect reward balance stability.');
      return;
    }
    setState(() {
      _luckySpinsUsedCount++;
      _totalPawCoins += 100;
    });
    _showFeedbackToast('🎯 Spin complete! +100 PawCoins added.');
  }

  // Feature 4 Execution Method
  void _watchPremiumVideoRewardAction() {
    if (_premiumVideosWatchedCount >= _maxDailyVideosAllowed) {
      _showLimitAlert('Premium Ad Limit', 'Premium video tasks capped at 5 per day to balance margins.');
      return;
    }
    setState(() {
      _premiumVideosWatchedCount++;
      _totalPawCoins += 300;
    });
    _showFeedbackToast('📺 Video verification verified! +300 PawCoins added.');
  }

  // Feature 5 Execution Method
  void _simulatePassiveStepWalkingIncrement() {
    setState(() {
      _mockLiveStepsWalked += 500;
      if (_mockLiveStepsWalked >= _dailyStepsTargetGoal) {
        _totalPawCoins += 400;
        _mockLiveStepsWalked = 0;
        _showFeedbackToast('🏃‍♂️ Daily step milestone achieved! +400 PawCoins.');
      } else {
        _showFeedbackToast('🐾 Steps sync: $_mockLiveStepsWalked / $_dailyStepsTargetGoal recorded.');
      }
    });
  }

  // Feature 6 Execution Method
  void _handlePassiveCoinTapAction() {
    setState(() {
      _tapAccumulationTracker++;
      if (_tapAccumulationTracker >= 20) {
        _totalPawCoins += 50;
        _tapAccumulationTracker = 0;
        _showFeedbackToast('👆 Multiplier Triggered! +50 PawCoins added.');
      }
    });
  }

  void _navigateToPayoutGateway() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Theme(
          data: ThemeData(scaffoldBackgroundColor: CashPawsColors.backgroundMidnight, brightness: Brightness.dark),
          child: CashPawsPayoutScreen(
            currentCoins: _totalPawCoins,
            currentUserId: widget.userId,
            onBalanceChanged: (updatedBalance) {
              setState(() => _totalPawCoins = updatedBalance);
            },
          ),
        ),
      ),
    );
  }

  void _showFeedbackToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _showLimitAlert(String title, String body) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: CashPawsColors.cardNavy,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(body, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK', style: TextStyle(color: CashPawsColors.neonGreen)))],
      ),
    );
  }

  String _displayMiningTimeRemaining(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return "${pad(d.inHours)}:${pad(d.inMinutes.remainder(60))}:${pad(d.inSeconds.remainder(60))}";
  }

    @override
  Widget build(BuildContext context) {
    double progressPct = (_totalPawCoins / _targetCoinsThreshold).clamp(0.0, 1.0);
    double estimatedUsdVal = _totalPawCoins / 10000;

    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      appBar: AppBar(
        backgroundColor: CashPawsColors.backgroundMidnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showFeedbackToast('Opening system drawer...'),
        ),
        title: const Text('🐾 CASHPAWS HUB', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: CashPawsColors.cardNavy,
              radius: 18,
              child: const Icon(Icons.person, color: CashPawsColors.neonGreen, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance: $_totalPawCoins / $_targetCoinsThreshold PawCoins', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('(\$${estimatedUsdVal.toStringAsFixed(2)} / \$10.00 Target)', style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPct,
                      minHeight: 10,
                      backgroundColor: CashPawsColors.cardNavy,
                      valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
                    ),
                  ),
                ],
              ),
            ),
            if (_isTopBannerAdLoaded && _topAdMobBanner != null)
              Container(
                alignment: Alignment.center,
                width: _topAdMobBanner!.size.width.toDouble(),
                height: _topAdMobBanner!.size.height.toDouble(),
                padding: const EdgeInsets.only(bottom: 8),
                child: AdWidget(ad: _topAdMobBanner!),
              ),

                        Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FEATURE 1: Daily Check-In Streak
                    _buildFeatureCard(
                      title: '1. Daily Check-In Streak',
                      subtitle: _hasClaimedCheckInToday 
                          ? 'Claimed Today (Streak: $_consecutiveCheckInDays)' 
                          : 'Daily reward of +250 PawCoins is waiting!',
                      icon: Icons.calendar_today,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasClaimedCheckInToday ? Colors.grey : CashPawsColors.neonGreen,
                        ),
                        onPressed: _hasClaimedCheckInToday ? null : _executeDailyCheckInClaim,
                        child: Text(_hasClaimedCheckInToday ? 'DONE' : 'CLAIM', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FEATURE 2: Paws Mining with Integrated Visual Avatar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: CashPawsColors.cardNavy, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.blur_circular, color: CashPawsColors.neonGreen, size: 22),
                              const SizedBox(width: 10),
                              const Text('2. Paws Mining Node', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const Spacer(),
                              InkWell(
                                onTap: () => setState(() => _activeCompanionType = _activeCompanionType == 'Cat' ? 'Dog' : 'Cat'),
                                child: Text('($_activeCompanionType Visual Active)', style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 11, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: CashPawsColors.backgroundMidnight, 
                                  shape: BoxShape.circle, 
                                  border: Border.all(color: CashPawsColors.neonGreen, width: 1.5),
                                ),
                                child: Icon(_activeCompanionType == 'Cat' ? Icons.pets : Icons.cruelty_free, color: CashPawsColors.neonGreen, size: 30),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isMiningSessionActive)
                                    Text('Time Left: ${_displayMiningTimeRemaining(_miningTimeLeftLeft)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
                                  else if (_canClaimCompletedMining)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                                      onPressed: _claimCompletedMiningCoins,
                                      child: const Text('CLAIM +500 COINS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                    )
                                  else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                                      onPressed: _startThreeHourMiningLoop,
                                      child: const Text('START 3-HOUR MINER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FEATURE 3: Spin Wheel Action Module
                    _buildFeatureCard(
                      title: '3. Lucky Spin Wheel',
                      subtitle: 'Used today: $_luckySpinsUsedCount / $_maxDailySpinsAllowed sessions',
                      icon: Icons.hourglass_top_rounded,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _triggerLuckySpinAction,
                        child: const Text('SPIN                    // FEATURE 5: Paws Step Walking Component
                    _buildFeatureCard(
                      title: '5. Paws Step Walking',
                      subtitle: 'Live Sensor Sync Tracker: $_mockLiveStepsWalked / $_dailyStepsTargetGoal steps',
                      icon: Icons.directions_walk,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _simulatePassiveStepWalkingIncrement,
                        child: const Text('WALK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FEATURE 6: Paws Tap Coins Interactive Multiplier Block
                    _buildFeatureCard(
                      title: '6. Paws Tap Coins',
                      subtitle: 'Tap Tracker Meter: $_tapAccumulationTracker / 20 inputs clicked',
                      icon: Icons.touch_app,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _handlePassiveCoinTapAction,
                        child: const Text('TAP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // FIXED CONTENT BOTTOM SLOTS: Central Payout Navigation Trigger Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CashPawsColors.neonGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _navigateToPayoutGateway,
                        child: const Text('💵 WITHDRAW FUNDS NOW', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // FIXED BOTTOM SLOTS: Static Bottom AdMob Banner View Layout Layer
            if (_isBottomBannerAdLoaded && _bottomAdMobBanner != null)
              Container(
                alignment: Alignment.center,
                width: _bottomAdMobBanner!.size.width.toDouble(),
                height: _bottomAdMobBanner!.size.height.toDouble(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AdWidget(ad: _bottomAdMobBanner!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required String title, required String subtitle, required IconData icon, required Widget actionWidget}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: CashPawsColors.cardNavy, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: CashPawsColors.neonGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          actionWidget,
        ],
      ),
    );
  }
}
', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FEATURE 4: Paws Video Reward Module
                    _buildFeatureCard(
                      title: '4. Paws Video Reward',
                      subtitle: 'Completed: $_premiumVideosWatchedCount / $_maxDailyVideosAllowed ad strings',
                      icon: Icons.video_library,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _watchPremiumVideoRewardAction,
                        child: const Text('WATCH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    
