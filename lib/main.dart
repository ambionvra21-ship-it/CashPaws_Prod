  Widget _buildGlassHUDEngine() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildMenuTile("Spin The Wheel", "TRY YOUR LUCK!", const Color(0xFFE99E3A), Icons.casino, () {}),
                const SizedBox(height: 12),
                _buildMenuTile("Tap Coins!", "TAP TO EARN!", const Color(0xFFFFD700), Icons.touch_app, () {}),
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
              borderGradient: const LinearGradient(colors: [Color(0xFF3A88E9), Color(0xFFE99E3A)]),
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
                        gradient: const LinearGradient(colors: [Colors.cyan, Color(0xFF3A88E9), Colors.transparent]),
                        width: 3,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.pets, size: 54, color: Color(0xFFC0D6E4))),
                  ),
                  const SizedBox(height: 12),
                  const Text("Mining Active:", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(_getFormattedTime(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _canCollect ? () {
                      setState(() {
                        _userCpPoints += 500;
                        _timeLeft = const Duration(hours: 4, minutes: 0, seconds: 0);
                        _canCollect = false;
                        _startMiningTimer();
                      });
                    } : null,
                    child: Opacity(
                      opacity: _canCollect ? 1.0 : 0.4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, py: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), 
                          gradient: const LinearGradient(colors: [Color(0xFF2B5876), Color(0xFF4E4376)]),
                        ),
                        child: Text(_canCollect ? "CLAIM NOW" : "COLLECT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildMenuTile("Walking Rewards", "$_stepCount / 10,000", const Color(0xFF3A88E9), Icons.directions_walk, () {
                  setState(() { if (_stepCount < 10000) _stepCount += 150; });
                }),
                const SizedBox(height: 12),
                _buildMenuTile("Watch Ads", "WATCH & EARN CP", Colors.redAccent, Icons.play_circle_filled, _triggerLiveVideoRewardAd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, String subtitle, Color color, IconData icon, VoidCallback action) {
    return Expanded(
      child: GestureDetector(
        onTap: action,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 16,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.01)]),
          borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]),
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
              const Text("Level Up and Earn Rewards!", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
