import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'mining_chest_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Global Earning Metric States
  int _pawcoins = 0;
  int _adsWatchedToday = 0;
  final int _maxDailyAds = 25; // Strict profit ceiling limit
  bool _isLoading = true;

  // AdMob Framework Variables
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  bool _isTopBannerLoaded = false;
  bool _isBottomBannerLoaded = false;
  final String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _refreshProfileData();
    _initDashboardAds();
  }

  // --- 1. Cloud Telemetry Synchronizations Engine ---
  Future<void> _refreshProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('pawcoins, ads_watched_today')
          .eq('user_id', user.id) // Securely synchronized matching your user_id column schema
          .single();

      if (mounted) {
        setState(() {
          _pawcoins = data['pawcoins'] ?? 0;
          _adsWatchedToday = data['ads_watched_today'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard database telemetry connection skipped: $e');
      setState(() => _isLoading = false);
    }
  }

  // --- 2. Monetization Layout Hooks Manager ---
  void _initDashboardAds() {
    _topBannerAd = BannerAd(
      adUnitId: _testBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isTopBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Top Banner failed loading inside dashboard viewport: $error');
        },
      ),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: _testBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBottomBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Bottom Banner failed loading inside dashboard viewport: $error');
        },
      ),
    )..load();
  }

    // --- 1. Universal Layout Component Card Factory Blueprint ---
  Widget _buildDashboardTaskCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String statusText,
    required bool isActionButtonActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E), // Modular asphalt surface panel
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActionButtonActive ? Colors.orangeAccent.withOpacity(0.3) : Colors.white10,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28),
                if (isActionButtonActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActionButtonActive ? Colors.orangeAccent.withOpacity(0.1) : Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: isActionButtonActive ? Colors.orangeAccent : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Screen Visual Layout Grid View Build Tree ---
  @override
  Widget build(BuildContext context) {
    final double usdEquivalent = _pawcoins / 1000.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121214), // Deep dark obsidian surface
      appBar: AppBar(
        title: const Text('CashPaws Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.orangeAccent),
            onPressed: () => Navigator.pushNamed(context, '/payouts'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                // Top Fixed Banner Ad Slot Container
                if (_isTopBannerLoaded && _topBannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _topBannerAd!.size.width.toDouble(),
                    height: _topBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _topBannerAd!),
                  ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshProfileData,
                    color: Colors.orangeAccent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dynamic Point Wallet Balance Card Matrix
                          Card(
                            color: const Color(0xFF1A1A1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Colors.orangeAccent, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Available Earnings', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      Text(
                                        'Ads: $_adsWatchedToday / $_maxDailyAds Max',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '🐾 $_pawcoins',
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '≈ \$${usdEquivalent.toStringAsFixed(2)} USD',
                                    style: const TextStyle(fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Premium Task Board',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          // Responsive Tasks Layout Matrix Blueprint Grid
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // 1. Daily Login Streak Card Component
                              _buildDashboardTaskCard(
                                icon: Icons.calendar_today_rounded,
                                iconColor: Colors.amber,
                                title: 'Daily Streak',
                                subtitle: 'Consecutive rewards',
                                statusText: 'Claimed Today',
                                isActionButtonActive: false,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Streak checked! Come back tomorrow.')),
                                  );
                                },
                              ),

                              // 2. Embedded Modular Mining Chest Card Component
                              MiningChestCard(onMiningComplete: _refreshProfileData),

                              // 3. Lucky Wheel Spin Card Component
                              _buildDashboardTaskCard(
                                icon: Icons.explore_rounded,
                                iconColor: Colors.deepOrangeAccent,
                                title: 'Spin Wheel',
                                subtitle: 'Lucky multiplier rolls',
                                statusText: 'Play Wheel',
                                isActionButtonActive: true,
                                onTap: () => Navigator.pushNamed(context, '/spin_wheel').then((_) => _refreshProfileData()),
                              ),

                                                            // 4. Step Logger Walking Tracker Card Component
                              _buildDashboardTaskCard(
                                icon: Icons.directions_walk_rounded,
                                iconColor: Colors.greenAccent,
                                title: 'Paws Walking',
                                subtitle: 'Steps sensor logger',
                                statusText: 'Track Steps',
                                isActionButtonActive: true,
                                onTap: () => Navigator.pushNamed(context, '/walking_tracker').then((_) => _refreshProfileData()),
                              ),

                              // 5. Video View Watch Ads Card Component
                              _buildDashboardTaskCard(
                                icon: Icons.play_circle_outline_rounded,
                                iconColor: Colors.blueAccent,
                                title: 'Watch Ads',
                                subtitle: 'Instant +15 Pawcoins',
                                statusText: 'Watch Video',
                                isActionButtonActive: true,
                                onTap: () => Navigator.pushNamed(context, '/watch_ads').then((_) => _refreshProfileData()),
                              ),

                              // 6. Fast Clicker Tap Coins Card Component
                              _buildDashboardTaskCard(
                                icon: Icons.touch_app_rounded,
                                iconColor: Colors.purpleAccent,
                                title: 'Tap Coins',
                                subtitle: '30s Time reflex trial',
                                statusText: 'Play Match',
                                isActionButtonActive: true,
                                onTap: () => Navigator.pushNamed(context, '/tap_coins').then((_) => _refreshProfileData()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Fixed Banner Ad Slot Container
                if (_isBottomBannerLoaded && _bottomBannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bottomBannerAd!.size.width.toDouble(),
                    height: _bottomBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd!),
                  ),
              ],
            ),
    );
  }

  // --- 3. Memory Component Management Cleanup Disposals ---
  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }
}
