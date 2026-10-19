import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';

class CashPawsMiningScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int pointsEarned) onMiningClaimed;

  const CashPawsMiningScreen({
    super.key,
    required this.currentCoins,
    required this.onMiningClaimed,
  });

  @override
  State<CashPawsMiningScreen> createState() => _CashPawsMiningScreenState();
}

class _CashPawsMiningScreenState extends State<CashPawsMiningScreen> {
  int _localCoins = 0;
  bool _isMiningActive = false;
  bool _canClaimRewards = false;
  
  // Timer settings: Set to 3 hours for production (10800 seconds)
  static const int _miningDurationSeconds = 10800; 
  int _secondsRemaining = _miningDurationSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _localCoins = widget.currentCoins;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startMiningEngine() {
    // Simulated AdMob Rewarded Video Triggers Here before timer fires up
    setState(() {
      _isMiningActive = true;
      _canClaimRewards = false;
      _secondsRemaining = _miningDurationSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
        setState(() {
          _isMiningActive = false;
          _canClaimRewards = true;
        });
      }
    });
  }

  void _claimMiningRewards() {
    // Requires watching an ad to claim points and secure your profit margin
    int pointsEarned = 25; // Strict cap configuration
    setState(() {
      _localCoins += pointsEarned;
      _canClaimRewards = false;
    });

    widget.onMiningClaimed(pointsEarned);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Claimed 25 Mining Pawcoins! (AdMob Transacted)'),
        backgroundColor: CashPawsColors.neonGreen,
      ),
    );
  }

  String _formatTimerDisplay(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
          '3-HOUR CLOUD MINER',
          style: TextStyle(color: CashPawsColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PASSIVE CLOUD ENGINE STATUS BANNER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isMiningActive ? CashPawsColors.neonGreen.withOpacity(0.1) : CashPawsColors.cardNavy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isMiningActive ? '⚡ MINER ACTIVE' : '💤 MINER IDLE',
                  style: TextStyle(
                    color: _isMiningActive ? CashPawsColors.neonGreen : CashPawsColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 🐱 CENTRAL CAT/CHEST ANIMATED GRAPHICS RIG LAYER
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Pulsing Neon Glow Ring
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CashPawsColors.cardNavy,
                        border: Border.all(
                          color: _isMiningActive ? CashPawsColors.neonGreen : CashPawsColors.cardNavy, 
                          width: 3
                        ),
                        boxShadow: [
                          if (_isMiningActive)
                            BoxShadow(
                              color: CashPawsColors.neonGreen.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                    ),
                    // Core Custom Icon Element (Combines your requested Cat and Chest theme)
                    Icon(
                      _isMiningActive ? Icons.pets : Icons.inventory_2,
                      size: 72,
                      color: _isMiningActive ? CashPawsColors.neonGreen : CashPawsColors.goldAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // RUNNING TIME COUNTDOWN DISPLAY TEXT
              Text(
                _formatTimerDisplay(_secondsRemaining),
                style: const TextStyle(
                  color: CashPawsColors.textWhite,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Redemption payout threshold reward: +25 Pawcoins',
                style: TextStyle(color: CashPawsColors.textMuted, fontSize: 13),
              ),
              const Spacer(),

              // MASTER TRIGGER TERMINAL BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canClaimRewards ? CashPawsColors.goldAccent : (_isMiningActive ? Colors.grey.shade800 : CashPawsColors.neonGreen),
                    foregroundColor: CashPawsColors.backgroundMidnight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isMiningActive 
                      ? null 
                      : (_canClaimRewards ? _claimMiningRewards : _startMiningEngine),
                  child: Text(
                    _isMiningActive 
                        ? 'MINING POWER FLOWING...' 
                        : (_canClaimRewards ? 'CLAIM REDEMPTION (+25 COINS)' : 'START 3-HOUR MINER'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
