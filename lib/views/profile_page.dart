import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import 'register_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _currentUserUid;
  bool _isLoading = true;
  UserProfile? _localProfile;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await _authService.getCachedUid();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('mock_user_name') ?? 'Astro Explorer';
      final email = prefs.getString('mock_user_email') ?? 'explorer@spacenews.com';
      final instagram = prefs.getString('mock_user_instagram') ?? '@astro_explorer';
      
      _localProfile = UserProfile(
        uid: uid ?? 'fallback_uid',
        name: name,
        email: email,
        instagram: instagram,
        photoUrl: r'C:\Users\User\Downloads\Foto Formal Santai 2.png',
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _currentUserUid = uid;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();
      if (!mounted) return;

      // Reset navigation history and return to Register Page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B19),
        elevation: 0,
        title: const Text(
          'Astronaut Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
              ),
            )
          : _currentUserUid == null
              ? _buildNoSessionState()
              : StreamBuilder<UserProfile?>(
                  stream: _firestoreService.getUserProfileStream(_currentUserUid!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        ),
                      );
                    }

                    // Fallback local mock profile if Firestore error or empty data
                    final UserProfile profile = snapshot.data ?? _getFallbackProfile();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (snapshot.hasError) ...[
                            _buildConfigWarning(),
                            const SizedBox(height: 20),
                          ],
                          const SizedBox(height: 10),

                          // Glowing profile photo container
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: const Color(0xFF151D3B),
                                backgroundImage: _getProfileImage(profile.photoUrl),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Full Name
                          Text(
                            profile.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Email
                          Text(
                            profile.email,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 35),

                          // Profile Fields Card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF151D3B).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF151D3B).withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  _buildProfileTile(
                                    icon: Icons.person_rounded,
                                    label: 'Full Name',
                                    value: profile.name,
                                  ),
                                  const Divider(color: Color(0xFF151D3B), height: 30, thickness: 1),
                                  _buildProfileTile(
                                    icon: Icons.mail_rounded,
                                    label: 'Email Address',
                                    value: profile.email,
                                  ),
                                  const Divider(color: Color(0xFF151D3B), height: 30, thickness: 1),
                                  _buildProfileTile(
                                    icon: Icons.camera_alt_rounded,
                                    label: 'Instagram',
                                    value: profile.instagram,
                                    valueColor: const Color(0xFF00E5FF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Log Out Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _handleLogout,
                              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                              label: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF070B19),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoSessionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, color: Colors.amberAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Profile Protected',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to explore your dashboard profiles.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview Mode: Configure Firebase options to fetch Firestore profile data.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(String path) {
    if (kIsWeb) {
      if (path.contains('Foto Formal Santai 2.png') || !path.startsWith('http')) {
        return const NetworkImage('foto_profile.png');
      }
      return NetworkImage(path);
    } else {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return NetworkImage(path);
      } else {
        return FileImage(io.File(path));
      }
    }
  }

  UserProfile _getFallbackProfile() {
    return _localProfile ?? UserProfile(
      uid: 'fallback_uid',
      name: 'Astro Explorer',
      email: 'explorer@spacenews.com',
      instagram: '@astro_explorer',
      photoUrl: r'C:\Users\User\Downloads\Foto Formal Santai 2.png',
    );
  }
}
