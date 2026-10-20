import 'package:flutter/material.dart';
import 'theme.dart';
import 'payout_screen.dart'; // Links directly to your standalone payout code file

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

  @override
  void initState() {
    super.initState();
    _totalPawCoins = widget.initialCoins; // Preloads your 2,650 sandbox balance
  }

  // Tactical Step 1: Navigates safely without dropping theme context layers
  void _navigateToWalletScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Theme(
          data: ThemeData(
            scaffoldBackgroundColor: CashPawsColors.backgroundMidnight,
            brightness: Brightness.dark,
          ),
          child: CashPawsPayoutScreen(
            currentCoins: _totalPawCoins,
            currentUserId: widget.userId,
            onBalanceChanged: (newBalance) {
              setState(() {
                _totalPawCoins = newBalance; // Updates main dashboard balance instantly on cashout
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      appBar: AppBar(
        backgroundColor: CashPawsColors.backgroundMidnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Added Hamburger Button Asset
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Navigation Drawer Panel...'))
            );
          },
        ),
        title: const Text(
          '🐾 CASHPAWS HUB', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: CashPawsColors.neonGreen),
            onPressed: _navigateToWalletScreen, // Step 1 Core Transition Trigger Hook
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Tracking Display Module Banner
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
              const SizedBox(height: 30),
              
              const Center(
                child: Text(
                  'Dashboard elements offline during tactical navigation staging.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
