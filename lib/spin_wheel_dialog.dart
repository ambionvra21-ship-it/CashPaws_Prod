import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class CashPawsSpinWheelDialog extends StatefulWidget {
  final int currentSpinsRemaining;
  final Function(int pointsWon) onSpinComplete;

  const CashPawsSpinWheelDialog({
    super.key,
    required this.currentSpinsRemaining,
    required this.onSpinComplete,
  });

  @override
  State<CashPawsSpinWheelDialog> createState() => _CashPawsSpinWheelDialogState();
}

class _CashPawsSpinWheelDialogState extends State<CashPawsSpinWheelDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool _isSpinning = false;
  int _localSpinsRemaining = 0;
  
  // Strict point sectors to maintain a 90% profit margin
  final List<int> _wheelSectors =;

  @override
  void initState() {
    super.initState();
    _localSpinsRemaining = widget.currentSpinsRemaining;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    void _startLuckySpin() {
    if (_isSpinning || _localSpinsRemaining <= 0) return;

    setState(() {
      _isSpinning = true;
      _localSpinsRemaining--;
    });

    // Select a random winning index from our strict point sectors
    final random = Random();
    final int targetSectorIndex = random.nextInt(_wheelSectors.length);
    
    // Calculate precise rotational stop angle (4 full spins + target segment offset)
    double sectorAngle = (2 * pi) / _wheelSectors.length;
    double targetAngle = (2 * pi * 4) + (targetSectorIndex * sectorAngle) + (sectorAngle / 2);

    _animation = Tween<double>(
      begin: _animationController.value * 2 * pi % (2 * pi),
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    _animationController.forward(from: 0.0).then((_) {
      int pointsWon = _wheelSectors[targetSectorIndex];
      _showPrizeAlert(pointsWon);
    });
  }

  void _showPrizeAlert(int pointsWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CashPawsColors.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            pointsWon > 0 ? '🎉 WE HAVE A WINNER!' : '😢 Better Luck Next Time!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: CashPawsColors.textWhite, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To claim your reward, close the video sponsor ad below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CashPawsColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: CashPawsColors.goldAccent, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$pointsWon Pawcoins',
                    style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '🎁 (AdMob Interstitial Triggers Instantly Here)',
                style: TextStyle(color: CashPawsColors.goldAccent.withOpacity(0.8), fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CashPawsColors.neonGreen,
                  foregroundColor: CashPawsColors.backgroundMidnight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close prize alert window
                  setState(() {
                    _isSpinning = false;
                  });
                  widget.onSpinComplete(pointsWon);
                },
                child: const Text('CLAIM REWARD', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

    @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CashPawsColors.backgroundMidnight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CashPawsColors.neonGreen.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LUCKY SPIN WHEEL',
                  style: TextStyle(color: CashPawsColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: CashPawsColors.textMuted),
                  onPressed: _isSpinning ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Spins Remaining Today: $_localSpinsRemaining/5',
              style: const TextStyle(color: CashPawsColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            
            // THE GRAPHICAL WHEEL LAYER
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CashPawsColors.cardNavy,
                          border: Border.all(color: CashPawsColors.neonGreen, width: 4),
                        ),
                        child: CustomPaint(
                          painter: _WheelPainter(sectors: _wheelSectors),
                        ),
                      ),
                    );
                  },
                ),
                // Center Peg Indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CashPawsColors.textWhite,
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.star, color: CashPawsColors.goldAccent, size: 18),
                ),
                // Top Sector Pointer Arrow
                Positioned(
                  top: 0,
                  child: Icon(Icons.arrow_drop_down_sharp, color: Colors.red.shade400, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _localSpinsRemaining > 0 && !_isSpinning ? CashPawsColors.neonGreen : Colors.grey.shade800,
                  foregroundColor: CashPawsColors.backgroundMidnight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _localSpinsRemaining > 0 && !_isSpinning ? _startLuckySpin : null,
                child: Text(
                  _isSpinning ? 'SPINNING...' : (_localSpinsRemaining > 0 ? 'LAUNCH SPIN' : 'LIMIT REACHED'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to cleanly segment the points inside our dark wheel asset UI
class _WheelPainter extends CustomPainter {
  final List<int> sectors;
  _WheelPainter({required this.sectors});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double sweepAngle = (2 * pi) / sectors.length;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (int i = 0; i < sectors.length; i++) {
      paint.color = i % 2 == 0 ? CashPawsColors.cardNavy : const Color(0xFF1B2332);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle - (pi / 2) - (sweepAngle / 2),
        sweepAngle,
        true,
        paint,
      );

      // Render text numbers inside the slice markers cleanly
      final textPainter = TextPainter(
        text: TextSpan(
          text: sectors[i].toString(),
          style: const TextStyle(color: CashPawsColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double angle = i * sweepAngle - (pi / 2);
      double textX = center.dx + (radius * 0.65) * cos(angle);
      double textY = center.dy + (radius * 0.65) * sin(angle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(angle + (pi / 2));
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
