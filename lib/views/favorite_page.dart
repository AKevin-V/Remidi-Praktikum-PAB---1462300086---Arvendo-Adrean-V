import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/article.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _currentUserUid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await _authService.getCachedUid();
    if (mounted) {
      setState(() {
        _currentUserUid = uid;
        _isLoading = false;
      });
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
          'Saved Exploration',
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
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _firestoreService.getFavoritesStream(_currentUserUid!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      // Return preview list if Firestore fails (e.g. mock credentials)
                      return _buildFirebaseErrorPreview(snapshot.error.toString());
                    }

                    final List<Map<String, dynamic>> favorites = snapshot.data ?? [];

                    if (favorites.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final data = favorites[index];
                        final article = Article(
                          id: data['articleId'] ?? 0,
                          title: data['title'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          newsSite: data['newsSite'] ?? '',
                          summary: data['summary'] ?? '',
                          publishedAt: data['publishedAt'] ?? '',
                          url: '',
                        );
                        return _buildFavoriteCard(article);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildFavoriteCard(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(article: article),
          ),
        );
      },
      child: Container(
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 85,
                  height: 85,
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFF151D3B)),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.newsSite,
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00E5FF), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSessionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.amberAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No Session Active',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in using your registered credentials to view saved news.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, color: Colors.grey[600], size: 70),
            const SizedBox(height: 20),
            const Text(
              'No Saved Articles',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Go to the Home dashboard, choose a galactic article, and press the heart icon to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseErrorPreview(String error) {
    // Standard mock placeholder articles in case Firebase Firestore is not loaded/configured yet
    final mockFavs = [
      Article(
        id: 1,
        title: 'Starship Super Heavy Launches on Fifth Integrated Test Flight',
        imageUrl: 'https://images.unsplash.com/photo-1541185933-ef5d8ed016c2?auto=format&fit=crop&q=80&w=800',
        newsSite: 'SpaceNews',
        summary: 'Demo article details.',
        publishedAt: '2026-06-20T10:00:00Z',
        url: '',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigoAccent),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.indigoAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Showing Demo Preview: Setup Firebase option credentials to access active Firestore sync.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: mockFavs.length,
              itemBuilder: (context, index) {
                return _buildFavoriteCard(mockFavs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
