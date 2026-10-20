  Widget _buildEarningWidgetsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // 1. Daily Login Interactive Widget Card Component
        _buildDashboardTaskCard(
          icon: Icons.calendar_today_rounded,
          iconColor: Colors.amber,
          title: 'Daily Streak',
          subtitle: 'Claim daily rewards',
          statusText: 'Claimed Today',
          isActionButtonActive: false,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Streak locked. Come back tomorrow at 12:00 AM!')),
            );
          },
        ),

        // 2. Lucky Roulette Spin Wheel Component Card
        _buildDashboardTaskCard(
          icon: Icons.hourglass_empty_rounded,
          iconColor: Colors.deepOrangeAccent,
          title: 'Spin Wheel',
          subtitle: 'Multiply coin gains',
          statusText: '3 / 5 Remaining',
          isActionButtonActive: true,
          onTap: () {
            // Links straight into the standalone Spin Wheel Game View screen
            Navigator.pushNamed(context, '/spin_wheel');
          },
        ),
      ],
    );
  }

  // Universal Layout Component Factory Blueprint for the Cards Container
  Widget _buildDashboardTaskCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String statusText,
    required bool isActionButtonActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E), // Obsidian asphalt core styling
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActionButtonActive ? Colors.orangeAccent.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28),
                if (isActionButtonActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActionButtonActive ? Colors.orangeAccent.withOpacity(0.1) : Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: isActionButtonActive ? Colors.orangeAccent : Colors.grey,
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
