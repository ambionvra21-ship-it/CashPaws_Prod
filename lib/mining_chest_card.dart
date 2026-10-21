import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MiningChestCard extends StatefulWidget {
  final VoidCallback onMiningComplete;
  const MiningChestCard({Key? key, required this.onMiningComplete}) : super(key: key);

  @override
  State<MiningChestCard> createState() => _MiningChestCardState();
}

class _MiningChestCardState extends State<MiningChestCard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isMining = false;
  bool _isLoading = true;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  final int _cooldownHours = 3;

  @override
  void initState() {
    super.initState();
    _checkMiningStatus();
  }

  Future<void> _checkMiningStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('last_chest_mine')
          .eq('user_id', user.id)
          .single();

      if (data['last_chest_mine'] != null) {
        final DateTime lastMine = DateTime.parse(data['last_chest_mine']);
        final DateTime nextMineAvailable = lastMine.add(Duration(hours: _cooldownHours));
        final DateTime now = DateTime.now();

        if (now.isBefore(nextMineAvailable)) {
          if (mounted) {
            setState(() {
              _remainingTime = nextMineAvailable.difference(now);
              _isMining = true;
              _isLoading = false;
            });
            _startTimer();
          }
          return;
        }
      }
      
      if (mounted) {
        setState(() {
          _isMining = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Mining validation log lookup skipped: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _countdownTimer?.cancel();
            _isMining = false;
            widget.onMiningComplete();
          }
        });
      }
    });
  }

  Future<void> _startMiningProcess() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final String nowIso = DateTime.now().toIso8601String();

      await _supabase.from('user_profiles').update({
        'last_chest_mine': nowIso,
      }).eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _remainingTime = Duration(hours: _cooldownHours);
          _isMining = true;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mining synchronization failed: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1A1E), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
      );
    }

    return InkWell(
      onTap: _isMining ? null : _startMiningProcess,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: !_isMining ? Colors.orangeAccent.withOpacity(0.4) : Colors.white10,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              _isMining ? Icons.hourglass_top_rounded : Icons.inventory_2_rounded,
              color: _isMining ? Colors.blueAccent : Colors.orangeAccent,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mining Chest', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(_isMining ? 'Extracting pawcoins...' : 'Tap to open chest', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isMining ? Colors.blue.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _isMining ? _formatDuration(_remainingTime) : 'Ready to Open',
                style: TextStyle(
                  color: _isMining ? Colors.blueAccent : Colors.orangeAccent,
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
