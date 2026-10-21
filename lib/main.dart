import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:gradient_borders/box_borders/gradient_box_border';
import 'theme.dart';

void main() {
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CashPawsTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TopHeaderBar(),
                    SizedBox(height: 20),
                    LoginStreakBar(),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassHUDEngine(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomBannerAd(),
            )
          ],
        ),
      ),
    );
  }
}

class TopHeaderBar extends StatelessWidget {
  const TopHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 18, color: Colors.white70),
            ),
            const SizedBox(width: 8),
            const Text("AlexPaw", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const Row(
          children: [
            Icon(Icons.pets, color: CashPawsTheme.accentOrange, size: 18),
            SizedBox(width: 4),
            Text("CashPaws", style: TextStyle(fontSize: 16, fontWeight: FontWeight.black)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.monetization_on, color: CashPawsTheme.textGold, size: 14),
              SizedBox(width: 4),
              Text("95,240 CP", style: TextStyle(color: CashPawsTheme.textGold, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginStreakBar extends StatelessWidget {
  const LoginStreakBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: CashPawsTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text("Daily Login Streak", style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.pets, color: CashPawsTheme.accentBlue, size: 20),
            )),
          )
        ],
      ),
    );
  }
}

class GlassHUDEngine extends StatelessWidget {
  const GlassHUDEngine({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildCard("Spin The Wheel", "TRY YOUR LUCK!", CashPawsTheme.accentOrange, Icons.casino),
                const SizedBox(height: 12),
                _buildCard("Tap Coins!", "TAP TO EARN!", CashPawsTheme.textGold, Icons.touch_app),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 300,
              borderRadius: 24,
              blur: 20,
              alignment: Alignment.center,
              border: 1.5,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.01)],
              ),
              borderGradient: const LinearGradient(
                colors: [CashPawsTheme.accentBlue, CashPawsTheme.accentOrange],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Mini-Mining", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: GradientBoxBorder(
                        gradient: const LinearGradient(colors: [Colors.cyan, CashPawsTheme.accentBlue, Colors.transparent]),
                        width: 3,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.pets, size: 54, color: Color(0xFFC0D6E4))),
                  ),
                  const SizedBox(height: 12),
                  const Text("Mining Active:", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const Text("02:18:39 Left", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, py: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [Color(0xFF2B5876), Color(0xFF4E4376)]),
                    ),
                    child: const Text("COLLECT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildCard("Walking Rewards", "8,412 / 10,000", CashPawsTheme.accentBlue, Icons.directions_walk),
                const SizedBox(height: 12),
                _buildCard("Watch Ads", "WATCH & EARN CP", Colors.redAccent, Icons.play_circle_filled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, Color color, IconData icon) {
    return Expanded(
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.01)],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomBannerAd extends StatelessWidget {
  const BottomBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070A0F),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, py: 2),
                color: Colors.purple,
                child: const Text("AD", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text("Level Up and Earn \$!", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 28),
            ),
            onPressed: () {},
            child: const Text("INSTALL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
