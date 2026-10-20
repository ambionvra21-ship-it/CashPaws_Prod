import 'package:flutter/material.dart';
import 'theme.dart';

class CashPawsTasksPanel extends StatefulWidget {
  final int currentCoins;
  final Function(int updatedCoins) onCoinsEarned;

  const CashPawsTasksPanel({
    super.key,
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  State<CashPawsTasksPanel> createState() => _CashPawsTasksPanelState();
}

class _CashPawsTasksPanelState extends State<CashPawsTasksPanel> {
  // Strict Daily Limit Trackers to protect 95% revenue margins
  int _dailySpinsUsed = 0;
  int _dailyAdsWatched = 0;
  bool _hasClaimedDailyLogin = false;

  final int _maxSpinsPerDay = 5;
  final int _maxAdsPerDay = 5;

  void _triggerLuckySpin() {
    if (_dailySpinsUsed >= _maxSpinsPerDay) {
      _showLimitReachedDialog('⚠️ SPIN LIMIT REACHED', 'You have used your 5 lucky spins for today. Reset happens at midnight.');
      return;
    }

    setState(() => _dailySpinsUsed++);
    widget.onCoinsEarned(50); // Allocation example payload win
    _showToast('🎯 Spin complete! Earned 50 PawCoins.');
  }

  void _watchRewardedAdTask() {
    if (_dailyAdsWatched >= _maxAdsPerDay) {
      _showLimitReachedDialog('⚠️ AD WALL LIMIT REACHED', 'Daily bonus videos capped at 5 to maintain system integrity.');
      return;
    }

    setState(() => _dailyAdsWatched++);
    widget.onCoinsEarned(100); // 1,000 coins = $1 proportional payout mapping
    _showToast('📺 Video verified! Earned 100 PawCoins.');
  }

  void _claimDailyLogin() {
    if (_hasClaimedDailyLogin) {
      _showToast('❌ Already claimed today!');
      return;
    }

    setState(() => _hasClaimedDailyLogin = true);
    widget.onCoinsEarned(25);
    _showToast('📆 Daily login bonus of 25 PawCoins added.');
  }

  void _showLimitReachedDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: CashPawsColors.cardNavy,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK', style: TextStyle(color: CashPawsColors.neonGreen)),
          )
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DAILY BOUNTIES', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        // Daily Login Widget Item Row
        _buildTaskRow(
          icon: Icons.calendar_today,
          title: 'Daily Check-In Streak',
          subtitle: _hasClaimedDailyLogin ? 'Claimed' : '+25 PawCoins available',
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasClaimedDailyLogin ? Colors.grey : CashPawsColors.neonGreen,
              minimumSize: const Size(80, 36),
            ),
            onPressed: _hasClaimedDailyLogin ? null : _claimDailyLogin,
            child: Text('CLAIM', style: TextStyle(color: _hasClaimedDailyLogin ? Colors.white30 : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),

        // Lucky Spin Wheel Row Widget Item
        _buildTaskRow(
          icon: Icons.hourglass_top_rounded,
          title: 'Lucky Spin Wheel',
          subtitle: 'Remaining: ${_maxSpinsPerDay - _dailySpinsUsed} / $_maxSpinsPerDay today',
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _dailySpinsUsed >= _maxSpinsPerDay ? Colors.grey : CashPawsColors.neonGreen,
              minimumSize: const Size(80, 36),
            ),
            onPressed: _triggerLuckySpin,
            child: Text('SPIN', style: TextStyle(color: _dailySpinsUsed >= _maxSpinsPerDay ? Colors.white30 : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),

        // Dedicated Ad Video Hub Row Item
        _buildTaskRow(
          icon: Icons.video_library,
          title: 'Premium Video Rewards',
          subtitle: 'Remaining: ${_maxAdsPerDay - _dailyAdsWatched} / $_maxAdsPerDay today',
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _dailyAdsWatched >= _maxAdsPerDay ? Colors.grey : CashPawsColors.neonGreen,
              minimumSize: const Size(80, 36),
            ),
            onPressed: _watchRewardedAdTask,
            child: Text('WATCH', style: TextStyle(color: _dailyAdsWatched >= _maxAdsPerDay ? Colors.white30 : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
