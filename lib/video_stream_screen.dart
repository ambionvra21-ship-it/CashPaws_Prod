import 'package:flutter/material.dart';
import 'theme.dart';

class CashPawsVideoStreamScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int pointsEarned) onVideoWatched;

  const CashPawsVideoStreamScreen({
    super.key,
    required this.currentCoins,
    required this.onVideoWatched,
  });

  @override
  State<CashPawsVideoStreamScreen> createState() => _CashPawsVideoStreamScreenState();
}

class _CashPawsVideoStreamScreenState extends State<CashPawsVideoStreamScreen> {
  int _localCoins = 0;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _localCoins = widget.currentCoins;
  }

  void _triggerRewardedAd(String streamTier, int rewardAmount) {
    if (_isAdLoading) return;

    setState(() {
      _isAdLoading = true;
    });

    // Simulated AdMob Rewarded Video callback engine pipeline
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      setState(() {
        _isAdLoading = false;
        _localCoins += rewardAmount;
      });

      widget.onVideoWatched(rewardAmount);

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: CashPawsColors.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            '🎉 REWARD CREDITED!',
            textAlign: TextAlign.center,
            style: TextStyle(color: CashPawsColors.textWhite, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thank you for watching the $streamTier sponsor stream.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: CashPawsColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Text(
                '+$rewardAmount Pawcoins',
                style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CashPawsColors.neonGreen,
                  foregroundColor: CashPawsColors.backgroundMidnight,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('AWESOME', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CashPawsColors.backgroundMidnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: CashPawsColors.textWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SPONSOR VIDEO STREAMS',
          style: TextStyle(color: CashPawsColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CURRENT ACCUMULATED SCORE DISPLAYER CHIP
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Live Balance:',
                            style: TextStyle(color: CashPawsColors.textMuted, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: CashPawsColors.goldAccent, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                _localCoins.toString(),
                                style: const TextStyle(color: CashPawsColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'AVAILABLE VIDEO TIERS',
                      style: TextStyle(color: CashPawsColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 12),

                    _buildVideoRow(
                      tierTitle: 'Standard Stream Alpha',
                      reward: 10,
                      description: 'Watch a 15-30 second sponsor highlight.',
                    ),
                    const SizedBox(height: 12),

                    _buildVideoRow(
                      tierTitle: 'Premium Stream Beta',
                      reward: 10,
                      description: 'High-yield interactive video engagement.',
                    ),
                    const SizedBox(height: 12),

                    _buildVideoRow(
                      tierTitle: 'Mega Video Stream Delta',
                      reward: 10,
                      description: 'Maximize your passive daily wallet earnings.',
                    ),
                  ],
                ),
              ),
            ),
            
            // PERSISTENT BOTTOM ADMOB STRIP PLACEHOLDER
            Container(
              width: double.infinity,
              height: 50,
              color: CashPawsColors.cardNavy,
              alignment: Alignment.center,
              child: Text(
                _isAdLoading ? '🔄 BUFFERING SPONSOR VIDEO...' : '🔥 ADMOB RUNNING STRIP PLACEHOLDER 🔥',
                style: TextStyle(color: CashPawsColors.textMuted.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoRow({required String tierTitle, required int reward, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CashPawsColors.cardNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CashPawsColors.neonGreen.withOpacity(0.05), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tierTitle,
                style: const TextStyle(color: CashPawsColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CashPawsColors.goldAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+$reward Coins',
                  style: const TextStyle(color: CashPawsColors.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: CashPawsColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: Text(_isAdLoading ? 'STREAMING...' : 'WATCH SPONSOR STREAM'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CashPawsColors.neonGreen,
                foregroundColor: CashPawsColors.backgroundMidnight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: _isAdLoading ? null : () => _triggerRewardedAd(tierTitle, reward),
            ),
          ),
        ],
      ),
    );
  }
}
