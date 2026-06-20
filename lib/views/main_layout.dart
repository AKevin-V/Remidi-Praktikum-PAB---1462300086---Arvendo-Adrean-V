import 'package:flutter/material.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The 4 main screens matching the tabs
  final List<Widget> _pages = [
    const HomePage(),
    const FavoritePage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF151D3B).withOpacity(0.8),
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF070B19),
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 20,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded, shadows: [
                Shadow(color: Color(0xFF00E5FF), blurRadius: 10),
              ]),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline_rounded),
              activeIcon: Icon(Icons.favorite_rounded, shadows: [
                Shadow(color: Color(0xFF00E5FF), blurRadius: 10),
              ]),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              activeIcon: Icon(Icons.notifications_rounded, shadows: [
                Shadow(color: Color(0xFF00E5FF), blurRadius: 10),
              ]),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, shadows: [
                Shadow(color: Color(0xFF00E5FF), blurRadius: 10),
              ]),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
