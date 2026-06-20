import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Curated notifications list matching chronological order (latest first)
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Starship Flight 5 Success',
        'body': 'SpaceX successfully caught the Super Heavy booster on its fifth flight using the launch tower chopsticks.',
        'time': '2 hours ago',
        'icon': Icons.rocket_launch_rounded,
        'color': const Color(0xFF00E5FF),
      },
      {
        'title': 'Severe Solar Storm Warning',
        'body': 'NOAA predicts strong G4 solar storm. Spectacular auroras likely visible across mid-latitude areas tonight.',
        'time': '5 hours ago',
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.amberAccent,
      },
      {
        'title': 'Water Vapor on Exoplanet',
        'body': 'James Webb Telescope detects signs of water vapor in the atmosphere of rocky exoplanet LHS 1140 b.',
        'time': '1 day ago',
        'icon': Icons.blur_on_rounded,
        'color': const Color(0xFF7C4DFF),
      },
      {
        'title': 'Asteroid Flyby Distance Confirmed',
        'body': 'Astronomers confirm asteroid 2026-FT will pass safely within 0.8 lunar distances of Earth on Monday.',
        'time': '2 days ago',
        'icon': Icons.public_rounded,
        'color': Colors.greenAccent,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B19),
        elevation: 0,
        title: const Text(
          'Cosmic Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _buildNotificationCard(item);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF151D3B).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF151D3B).withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: item['color'].withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                item['icon'],
                color: item['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        item['time'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['body'],
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
