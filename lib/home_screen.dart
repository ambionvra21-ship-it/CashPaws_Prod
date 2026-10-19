import 'package:flutter/material.dart';
import 'theme.dart';
import 'spin_wheel_dialog.dart';
import 'video_stream_screen.dart';

class CashPawsHomeScreen extends StatefulWidget {
  const CashPawsHomeScreen({super.key});

  @override
  State<CashPawsHomeScreen> createState() => _CashPawsHomeScreenState();
}

class _CashPawsHomeScreenState extends State<CashPawsHomeScreen> {
  int _userPawcoins = 12450; 
  double _usdValue = 12.45; 
  int _spinsRemaining = 5;
  bool _hasCheckedInToday = false;

  void _executeDailyCheckIn() {
    if (!_hasCheckedInToday) {
      setState(() {
        _userPawcoins += 50;
        _usdValue = _userPawcoins / 1000;
        _hasCheckedInToday = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Claimed 50 Daily Pawcoins! (AdMob Triggered)'),
          backgroundColor: CashPawsColors.neonGreen,
        ),
      );
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR USER PROFILE ACTION ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: CashPawsColors.cardNavy,
                              child: Icon(Icons.person, color: CashPawsColors.neonGreen),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Hi, Partner!',
                              style: TextStyle(color: CashPawsColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: CashPawsColors.textWhite),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // GLOWING COIN BALANCE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardNavy,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CashPawsColors.neonGreen.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: CashPawsColors.neonGreen.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'YOUR BALANCE',
                            style: TextStyle(color: CashPawsColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on, color: CashPawsColors.goldAccent, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                _userPawcoins.toString(),
                                style: const TextStyle(color: CashPawsColors.textWhite, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${_usdValue.toStringAsFixed(2)} USD',
                            style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CORE ACTIVE PASSIVE EARNING TASK DASHBOARD CHIPS
                    const Text(
                      'PASSIVE MISSIONS',
                      style: TextStyle(color: CashPawsColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 12),

                    // Daily Check In Interactive Trigger Row
                    _buildTaskCard(
                      icon: Icons.calendar_today,
                      title: 'Daily Rewards Login',
                      subtitle: _hasCheckedInToday ? 'Claimed Today' : 'Available: +50 Pawcoins',
                      actionLabel: _hasCheckedInToday ? 'Locked' : 'Claim Now',
                      isCompleted: _hasCheckedInToday,
                      onTap: _executeDailyCheckIn,
                    ),
                    const SizedBox(height: 12),

                                        // Lucky Spin Wheel Path Router Button
                    _buildTaskCard(
                      icon: Icons.hourglass_top_rounded,
                      title: 'Lucky Spin & Win',
                      subtitle: 'Spins remaining today: $_spinsRemaining/5',
                      actionLabel: 'Spin Wheel',
                      isCompleted: _spinsRemaining == 0,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => CashPawsSpinWheelDialog(
                            currentSpinsRemaining: _spinsRemaining,
                            onSpinComplete: (pointsWon) {
                              setState(() {
                                _spinsRemaining--;
                                _userPawcoins += pointsWon;
                                _usdValue = _userPawcoins / 1000;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Watch Incentivized Video Engine Button 
                    _buildTaskCard(
                      icon: Icons.play_circle_filled,
                      title: 'Watch Video Streams',
                      subtitle: 'Passive payout per view: +10 Pawcoins',
                      actionLabel: 'Watch Now',
                      isCompleted: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CashPawsVideoStreamScreen(
                              currentCoins: _userPawcoins,
                              onVideoWatched: (pointsEarned) {
                                setState(() {
                                  _userPawcoins += pointsEarned;
                                  _usdValue = _userPawcoins / 1000;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // FIXED BOTTOM AUTOMATED ADMOB BANNER VIEWPORT SAFE ZONE
            Container(
              width: double.infinity,
              height: 50,
              color: CashPawsColors.cardNavy,
              alignment: Alignment.center,
              child: Text(
                '🔥 ADMOB RUNNING STRIP PLACEHOLDER 🔥',
                style: TextStyle(color: CashPawsColors.textMuted.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CashPawsColors.cardNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: CashPawsColors.goldAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: CashPawsColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: CashPawsColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isCompleted ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.grey.shade800 : CashPawsColors.neonGreen,
              foregroundColor: CashPawsColors.backgroundMidnight,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(actionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
