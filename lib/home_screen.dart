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
  final int _targetCoinsThreshold = 100000; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 1. Daily Check-in Streak Tracking Configurations
  bool _hasClaimedCheckInToday = false;
  int _consecutiveCheckInDays = 0;

  // 2. Paws Mining Background Engine Timers
  Timer? _miningCountDownTimer;
  Duration _miningTimeLeftLeft = const Duration(hours: 3);
  bool _isMiningSessionActive = false;
  bool _canClaimCompletedMining = false;
  String _activeCompanionType = 'Cat'; 

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

  // AdMob Platform Engine Trackers
  BannerAd? _dashboardSingleBottomBanner;
  BannerAd? _featureDoubleBannerA;
  BannerAd? _featureDoubleBannerB;
  
  bool _isDashboardBannerLoaded = false;
  bool _isDoubleBannerALoaded = false;
  bool _isDoubleBannerBLoaded = false;

  RewardedAd? _cashPawsRewardedAdObject;
  bool _isAdNetworkLoading = false;

  final String _testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String _testRewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

    @override
  void initState() {
    super.initState();
    _totalPawCoins = widget.initialCoins;
    _initializeProductionAdMobLayers();
  }

  @override
  void dispose() {
    _miningCountDownTimer?.cancel();
    _dashboardSingleBottomBanner?.dispose();
    _featureDoubleBannerA?.dispose();
    _featureDoubleBannerB?.dispose();
    _cashPawsRewardedAdObject?.dispose();
    super.dispose();
  }

  void _initializeProductionAdMobLayers() {
    _dashboardSingleBottomBanner = BannerAd(
      adUnitId: _testBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isDashboardBannerLoaded = true),
        onAdFailedToLoad: (ad, err) { ad.dispose(); debugPrint('Dashboard banner fail: $err'); },
      ),
    )..load();

    _featureDoubleBannerA = BannerAd(
      adUnitId: _testBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isDoubleBannerALoaded = true),
        onAdFailedToLoad: (ad, err) { ad.dispose(); debugPrint('Double banner A fail: $err'); },
      ),
    )..load();

    _featureDoubleBannerB = BannerAd(
      adUnitId: _testBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isDoubleBannerBLoaded = true),
        onAdFailedToLoad: (ad, err) { ad.dispose(); debugPrint('Double banner B fail: $err'); },
      ),
    )..load();

    _preCacheRewardedAdLoop();
  }

  void _preCacheRewardedAdLoop() {
    if (_isAdNetworkLoading || _cashPawsRewardedAdObject != null) return;
    setState(() => _isAdNetworkLoading = true);

    RewardedAd.load(
      adUnitId: _testRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _cashPawsRewardedAdObject = ad;
          _isAdNetworkLoading = false;
        },
        onAdFailedToLoad: (err) {
          _cashPawsRewardedAdObject = null;
          _isAdNetworkLoading = false;
          debugPrint('Rewarded ad cache failed: $err');
        },
      ),
    );
  }

  void _triggerAdGatedFeatureAction(VoidCallback onAdSuccessReward) {
    if (_cashPawsRewardedAdObject != null) {
      _cashPawsRewardedAdObject!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(onAdSuccessReward);
        _cashPawsRewardedAdObject = null;
        _preCacheRewardedAdLoop();
      });
    } else {
      setState(onAdSuccessReward);
      _preCacheRewardedAdLoop();
    }
  }

    void _executeDailyCheckInClaim() {
    if (_hasClaimedCheckInToday) return;
    _triggerAdGatedFeatureAction(() {
      _hasClaimedCheckInToday = true;
      _consecutiveCheckInDays += 1;
      _totalPawCoins += 250;
    });
    _showFeedbackToast("Check-In complete! Day $_consecutiveCheckInDays streak active.");
  }

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
    _triggerAdGatedFeatureAction(() {
      _totalPawCoins += 500;
      _canClaimCompletedMining = false;
    });
    _showFeedbackToast('🎉 Cloud Mining complete! +500 PawCoins added.');
  }

  void _triggerLuckySpinAction() {
    if (_luckySpinsUsedCount >= _maxDailySpinsAllowed) {
      _showLimitAlert('Lucky Spin Limit', 'Daily spins capped at 5 to protect reward balance stability.');
      return;
    }
    _showInteractiveFeatureModal('🎰 LUCKY SPIN TASK', 'Test your fortune! Watching the full rewarded video ad activates the spin engine.', () {
      _triggerAdGatedFeatureAction(() {
        _luckySpinsUsedCount++;
        _totalPawCoins += 100;
      });
      _showFeedbackToast('🎯 Spin complete! +100 PawCoins added.');
    });
  }

  void _watchPremiumVideoRewardAction() {
    if (_premiumVideosWatchedCount >= _maxDailyVideosAllowed) {
      _showLimitAlert('Premium Ad Limit', 'Premium video tasks capped at 5 per day to balance margins.');
      return;
    }
    _showInteractiveFeatureModal('📺 PREMIUM VIDEO WALL', 'Claim instant bonus rewards by completing full ad verification sequences.', () {
      _triggerAdGatedFeatureAction(() {
        _premiumVideosWatchedCount++;
        _totalPawCoins += 300;
      });
      _showFeedbackToast('📺 Video verification verified! +300 PawCoins added.');
    });
  }

  void _simulatePassiveStepWalkingIncrement() {
    _showInteractiveFeatureModal('🏃‍♂️ PEDOMETER MILESTONE', 'Sync your passive walking step sensor logs with our network ad ledger.', () {
      setState(() {
        _mockLiveStepsWalked += 500;
        if (_mockLiveStepsWalked >= _dailyStepsTargetGoal) {
          _totalPawCoins += 400;
          _mockLiveStepsWalked = 0;
          _showFeedbackToast('🏃‍♂️ Daily step milestone achieved! +400 PawCoins.');
        } else {
          _showFeedbackToast("🐾 Steps sync: $_mockLiveStepsWalked / $_dailyStepsTargetGoal recorded.");
        }
      });
    });
  }

  void _handlePassiveCoinTapAction() {
    setState(() {
      _tapAccumulationTracker++;
      if (_tapAccumulationTracker >= 20) {
        _triggerAdGatedFeatureAction(() {
          _totalPawCoins += 50;
          _tapAccumulationTracker = 0;
        });
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

    // Tactical Injection: The Interactive High-Density Double-Banner Modal View Framework
  void _showInteractiveFeatureModal(String title, String description, VoidCallback onActionButtonPressed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CashPawsColors.backgroundMidnight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // High-Density Double Banner System Layout Header Frame Blocks
                    if (_isDoubleBannerALoaded && _featureDoubleBannerA != null)
                      Container(
                        alignment: Alignment.center,
                        width: _featureDoubleBannerA!.size.width.toDouble(),
                        height: _featureDoubleBannerA!.size.height.toDouble(),
                        padding: const EdgeInsets.only(bottom: 4),
                        child: AdWidget(ad: _featureDoubleBannerA!),
                      ),
                    if (_isDoubleBannerBLoaded && _featureDoubleBannerB != null)
                      Container(
                        alignment: Alignment.center,
                        width: _featureDoubleBannerB!.size.width.toDouble(),
                        height: _featureDoubleBannerB!.size.height.toDouble(),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AdWidget(ad: _featureDoubleBannerB!),
                      ),

                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CashPawsColors.neonGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onActionButtonPressed();
                        },
                        child: const Text('ACTIVATE TASK (WATCH AD)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Tactical Injection: The Profile Overlay Panel Screen View Configuration Sheet
  void _openUserProfileInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CashPawsColors.cardNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: CashPawsColors.backgroundMidnight,
                child: Icon(Icons.person, color: CashPawsColors.neonGreen, size: 36),
              ),
              const SizedBox(height: 12),
              Text('User Account: ${widget.userId}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Target Market Zone: Philippines (PHP)', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.security, color: CashPawsColors.neonGreen),
                title: const Text('Account Integrity Ledger', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text('Secure multi-currency verification active', style: TextStyle(color: Colors.grey, fontSize: 11)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

    @override
  Widget build(BuildContext context) {
    double progressPct = (_totalPawCoins / _targetCoinsThreshold).clamp(0.0, 1.0);
    double estimatedUsdVal = _totalPawCoins / 10000;
    double estimatedPhpVal = estimatedUsdVal * 56.00;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CashPawsColors.backgroundMidnight,
      
      // Strict Request: Hamburger sidebar drawer layout implementation block
      drawer: Drawer(
        backgroundColor: CashPawsColors.backgroundMidnight,
        child: Column(
          children: [
            UserHeaderDrawer(userId: widget.userId, currentCoins: _totalPawCoins),
            ListTile(
              leading: const Icon(Icons.home, color: CashPawsColors.neonGreen),
              title: const Text('Dashboard Hub', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: CashPawsColors.neonGreen),
              title: const Text('Redeem Incentives', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _navigateToPayoutGateway();
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('CashPaws v1.0.0 Stable Build', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: CashPawsColors.backgroundMidnight,
        elevation: 0,
        // Strict Request: Hamburger button asset opens drawer navigation panel
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('🐾 CASHPAWS HUB', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        actions: [
          // Strict Request: Profile icon triggers information overlay sheet
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 26),
            onPressed: _openUserProfileInfoSheet,
          ),
        ],
      ),

            body: SafeArea(
        child: Column(
          children: [
            // HIGH-VISIBILITY PROGRESS HEADER BAR VIEW CONTAINER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CashPawsColors.cardNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CashPawsColors.neonGreen.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('LIVE COIN LEDGER PROGRESS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('${(progressPct * 100).toStringAsFixed(1)}% Completed', style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$_totalPawCoins / $_targetCoinsThreshold PawCoins', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Value Check: ₱${estimatedPhpVal.toStringAsFixed(2)} PHP (\$${estimatedUsdVal.toStringAsFixed(2)} / \$10.00 Target)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: 12,
                        backgroundColor: CashPawsColors.backgroundMidnight,
                        valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PRIMARY SCROLLABLE INTERFACE CARD MODULE ARRAY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FEATURE 1: Daily Check-In Streak
                    _buildFeatureCard(
                      title: '1. Daily Check-In Streak',
                      subtitle: _hasClaimedCheckInToday ? 'Claimed Today (Streak: $_consecutiveCheckInDays)' : 'Daily reward of +250 PawCoins is waiting!',
                      icon: Icons.calendar_today,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _hasClaimedCheckInToday ? Colors.grey : CashPawsColors.neonGreen),
                        onPressed: _hasClaimedCheckInToday ? null : _executeDailyCheckInClaim,
                        child: Text(_hasClaimedCheckInToday ? 'DONE' : 'CLAIM', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FEATURE 2: Paws Mining Node View Container with Avatar Silhouette Frame
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
                                decoration: BoxDecoration(color: CashPawsColors.backgroundMidnight, shape: BoxShape.circle, border: Border.all(color: CashPawsColors.neonGreen, width: 1.5)),
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

                    // FEATURE 3: Lucky Spin Wheel
                    _buildFeatureCard(
                      title: '3. Lucky Spin Wheel',
                      subtitle: 'Used today: $_luckySpinsUsedCount / $_maxDailySpinsAllowed sessions',
                      icon: Icons.hourglass_top_rounded,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _triggerLuckySpinAction,
                        child: const Text('SPIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                                        // FEATURE 4: Paws Video Reward
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

                    // FEATURE 5: Paws Step Walking
                    _buildFeatureCard(
                      title: '5. Paws Step Walking',
                      subtitle: 'Passive Sync Ledger: $_mockLiveStepsWalked / $_dailyStepsTargetGoal steps',
                      icon: Icons.directions_walk,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _simulatePassiveStepWalkingIncrement,
                        child: const Text('WALK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FEATURE 6: Paws Tap Coins
                    _buildFeatureCard(
                      title: '6. Paws Tap Coins',
                      subtitle: 'Tap Multiplier Accumulator: $_tapAccumulationTracker / 20 inputs clicked',
                      icon: Icons.touch_app,
                      actionWidget: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: CashPawsColors.neonGreen),
                        onPressed: _handlePassiveCoinTapAction,
                        child: const Text('TAP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Strict Request Placement: Centralized Withdrawal triggering button fixed above ad layout footer
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
                    const SizedBox(height: 16), // Safety Spacer padding prevents Google accidental click flags
                  ],
                ),
              ),
            ),

            // Strict Request Layout: Fixed single bottom AdMob banner footer housing configuration row
            if (_isDashboardBannerLoaded && _dashboardSingleBottomBanner != null)
              Container(
                alignment: Alignment.center,
                width: _dashboardSingleBottomBanner!.size.width.toDouble(),
                height: _dashboardSingleBottomBanner!.size.height.toDouble(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AdWidget(ad: _dashboardSingleBottomBanner!),
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

// Simple internal helper drawer layout class builder to secure compilation architecture completeness
class UserHeaderDrawer extends StatelessWidget {
  final String userId;
  final int currentCoins;
  const UserHeaderDrawer({super.key, required this.userId, required this.currentCoins});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      color: CashPawsColors.cardNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_balance_wallet, color: CashPawsColors.neonGreen, size: 36),
          const SizedBox(height: 12),
          Text(userId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('$currentCoins PawCoins Accumulated', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
