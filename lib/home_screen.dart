import 'package:flutter/material.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Clean Android Material 3 Top Navigation Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.pets, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              'CashPaws',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 16),
            _buildMiningCard(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildMiniSpinCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildStepCounterCard()),
              ],
            ),
            const SizedBox(height: 16),
            _buildWithdrawalCard(),
            const SizedBox(height: 16),
            _buildWatchAdsCard(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.monetization_on), label: 'Earn'),
          NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  // Placeholder methods to hold structure for subsequent batches
  Widget _buildBalanceCard() => const SizedBox.shrink();
  Widget _buildMiningCard() => const SizedBox.shrink();
  Widget _buildMiniSpinCard() => const SizedBox.shrink();
  Widget _buildStepCounterCard() => const SizedBox.shrink();
  Widget _buildWithdrawalCard() => const SizedBox.shrink();
  Widget _buildWatchAdsCard() => const SizedBox.shrink();
}

  // --- BATCH 2 COMPONENTS ---

  Widget _buildBalanceCard() {
    return Card(
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
              children: const [
                Text('Total Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  '15,480 Coins',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF1E293B)),
                ),
                Text('\$12.34', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {},
              child: const Text('REWARDS STORE'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiningCard() {
    return Card(
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
                  children: const [
                    Text('PAWS MINING', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12, color: Color(0xFF1E40AF))),
                    SizedBox(height: 4),
                    Text('CHEST MINING', style: TextStyle(fontWeight: FontWeight.black, fontSize: 22, color: Color(0xFF1E293B))),
                  ],
                ),
                const Icon(Icons.lock_open, size: 50, color: Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: const Text('START MINING'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: null,
                    icon: const Icon(Icons.check, color: Colors.green),
                    label: const Text('Claimed', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSpinCard() {
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
            const Text('Spins Remaining: 2/3', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(32),
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text('SPIN NOW', style: TextStyle(fontSize: 11, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepCounterCard() {
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
            Row(
              children: const [
                Icon(Icons.directions_walk, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Expanded(child: Text('WALKING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
              ],
            ),
            const SizedBox(height: 8),
            const Text('4,500 / 10,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: 0.45, backgroundColor: Colors.grey.shade200, color: Colors.orange),
            const SizedBox(height: 4),
            const Text('15 Coins', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  // --- BATCH 3 COMPONENTS ---

  Widget _buildWithdrawalCard() {
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
              'Withdrawal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text('Payment Methods', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMethodIcon('GCash', Icons.account_balance_wallet, Colors.blue),
                _buildMethodIcon('Maya', Icons.wallet, Colors.green),
                _buildMethodIcon('PayPal', Icons.payment, Colors.blue.shade900),
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
              onPressed: () {},
              child: const Text('WITHDRAW FUNDS'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMethodIcon(String name, IconData icon, Color color) {
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

  Widget _buildWatchAdsCard() {
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
                _buildAdTaskItem('10s Video Ad', 'Earn 5 Coins'),
                _buildAdTaskItem('Bonus Video', 'Earn 5 Coins'),
                _buildAdTaskItem('Partner Offer', 'Earn 8 Coins'),
                _buildAdTaskItem('Partner Offer', 'Earn 8 Coins'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdTaskItem(String title, String reward) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: BorderSide(color: Colors.green.shade100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
