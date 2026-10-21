import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPaws',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  
  // Persistent Core State Variables
  int _totalCoins = 15480;
  int _stepsWalked = 4500;
  int _spinsRemaining = 3;
  bool _isMiningClaimed = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedMetrics();
  }

  // --- LOCAL HARDWARE PERSISTENCE HOOKS ---
  Future<void> _loadPersistedMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalCoins = prefs.getInt('totalCoins') ?? 15480;
      _stepsWalked = prefs.getInt('stepsWalked') ?? 4500;
      _spinsRemaining = prefs.getInt('spinsRemaining') ?? 3;
      _isMiningClaimed = prefs.getBool('isMiningClaimed') ?? false;
    });
  }

  Future<void> _saveMetric(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  // --- ENGINE TRANSACTION LOGIC ---
  void _awardCoins(int amount, String source) {
    setState(() {
      _totalCoins += amount;
      _saveMetric('totalCoins', _totalCoins);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 +$amount Coins added from $source!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSystemAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeDashboardView(
            totalCoins: _totalCoins,
            stepsWalked: _stepsWalked,
            spinsRemaining: _spinsRemaining,
            isMiningClaimed: _isMiningClaimed,
            onMiningTriggered: () {
              if (!_isMiningClaimed) {
                setState(() {
                  _isMiningClaimed = true;
                  _saveMetric('isMiningClaimed', true);
                });
                _awardCoins(250, 'Chest Mining Pool');
              }
            },
            onSpinTriggered: () {
              if (_spinsRemaining > 0) {
                setState(() {
                  _spinsRemaining--;
                  _saveMetric('spinsRemaining', _spinsRemaining);
                });
                _awardCoins(15, 'Spin Mini-Game');
              } else {
                _showSystemAlert('No Spins Left', 'Your daily spin budget is empty!');
              }
            },
            onWalkSimulated: () {
              if (_stepsWalked < 10000) {
                setState(() {
                  _stepsWalked += 500;
                  _saveMetric('stepsWalked', _stepsWalked);
                });
                _awardCoins(5, 'Steps Milestone');
              } else {
                _showSystemAlert('Target Met', 'Daily movement limits achieved!');
              }
            },
            onAdWatched: () => _awardCoins(10, 'Video Monetization Network'),
            onWithdrawalPressed: () {
              double val = _totalCoins / 1253.64;
              _showSystemAlert('Withdrawal Processing', 'Converting balance...\nEstimated value: ₱${val.toStringAsFixed(2)}');
            },
            onStoreRedirect: () => setState(() => _currentIndex = 2),
          ),
          const PlaceholderView(title: '📝 Earn Tasks Panel'),
          const PlaceholderView(title: '🎁 Rewards Store Marketplace'),
          const PlaceholderView(title: '⏳ Ledger Records Logs'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.monetization_on), label: 'Earn'),
          NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class PlaceholderView extends StatelessWidget {
  final String title;
  const PlaceholderView({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}

// ==========================================
// PHASE 2: HOME DASHBOARD PRESENTATION LAYER
// ==========================================

class HomeDashboardView extends StatelessWidget {
  final int totalCoins;
  final int stepsWalked;
  final int spinsRemaining;
  final bool isMiningClaimed;
  final VoidCallback onMiningTriggered;
  final VoidCallback onSpinTriggered;
  final VoidCallback onWalkSimulated;
  final VoidCallback onAdWatched;
  final VoidCallback onWithdrawalPressed;
  final VoidCallback onStoreRedirect;

  const HomeDashboardView({
    super.key,
    required this.totalCoins,
    required this.stepsWalked,
    required this.spinsRemaining,
    required this.isMiningClaimed,
    required this.onMiningTriggered,
    required this.onSpinTriggered,
    required this.onWalkSimulated,
    required this.onAdWatched,
    required this.onWithdrawalPressed,
    required this.onStoreRedirect,
  });

  @override
  Widget build(BuildContext context) {
    double usdValue = totalCoins * 0.0008;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Row(
          children: [
            Icon(Icons.pets, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              'CashPaws',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 22),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Balance Tracking Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '$totalCoins Coins',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          '\$${usdValue.toStringAsFixed(2)} Value',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onStoreRedirect,
                      child: const Text('REWARDS STORE'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Chest Mining Interactive Card
            Card(
              elevation: 0,
              color: const Color(0xFFDBEAFE),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PAWS MINING',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12, color: Color(0xFF1E40AF)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMiningClaimed ? 'CHEST EMPTY' : 'CHEST READY',
                              style: const TextStyle(fontWeight: FontWeight.black, fontSize: 22, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        Icon(isMiningClaimed ? Icons.lock : Icons.lock_open, size: 50, color: Colors.orangeAccent),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: isMiningClaimed ? Colors.grey : const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isMiningClaimed ? null : onMiningTriggered,
                      child: Text(isMiningClaimed ? 'DAILY REWARD CLAIMED' : 'CLAIM CHEST (250 COINS)'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Split Action Layout Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSpinGridItem()),
                const SizedBox(width: 12),
                Expanded(child: _buildPedometerGridItem()),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom Section Placeholder Hooks for Phase 3
            _buildWithdrawalCardSection(),
            const SizedBox(height: 16),
            _buildAdNetworkTaskSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinGridItem() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.pie_chart, color: Colors.orange, size: 36)),
            ),
            const SizedBox(height: 8),
            Text('Remaining Spins: $spinsRemaining/3', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(32),
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              onPressed: onSpinTriggered,
              child: const Text('SPIN WHEEL', style: TextStyle(fontSize: 10, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPedometerGridItem() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.directions_walk, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Expanded(child: Text('PEDOMETER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
              ],
            ),
            const SizedBox(height: 8),
            Text('$stepsWalked / 10000', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: stepsWalked / 10000, backgroundColor: Colors.grey.shade200, color: Colors.orange),
            const SizedBox(height: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(32),
                backgroundColor: Colors.blueGrey,
              ),
              onPressed: onWalkSimulated,
              child: const Text('SIMULATE +500', style: TextStyle(fontSize: 10, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PHASE 3: WITHDRAWAL GATEWAYS & MONETIZATION
  // ==========================================

  Widget _buildWithdrawalCardSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Withdrawal Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMethodRowItem('GCash', Icons.account_balance_wallet, Colors.blue),
                _buildMethodRowItem('Maya', Icons.wallet, Colors.green),
                _buildMethodRowItem('PayPal', Icons.payment, Colors.blue.shade900),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onWithdrawalPressed,
              child: const Text('EXECUTE REAL-TIME PAYOUT'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMethodRowItem(String name, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _buildAdNetworkTaskSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Watch Ads & Tasks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: [
                _buildAdGridButton('Premium Video', 'Earn 10 Coins', onOnTap: onAdWatched),
                _buildAdGridButton('Sponsor Video', 'Earn 10 Coins', onOnTap: onAdWatched),
                _buildAdGridButton('Promo Video', 'Earn 10 Coins', onOnTap: onAdWatched),
                _buildAdGridButton('Bonus Stream', 'Earn 10 Coins', onOnTap: onAdWatched),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdGridButton(String title, String reward, {required VoidCallback onOnTap}) {
    return InkWell(
      onTap: onOnTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: BorderSide(color: Colors.green.shade100),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    reward,
                    style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


