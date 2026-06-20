import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class DetailPage extends StatefulWidget {
  final Article article;

  const DetailPage({
    super.key,
    required this.article,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  String? _currentUserUid;
  bool _localFavoriteState = false; // Fallback local toggle for demo/offline resilience

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
      });
    }
  }

  Future<void> _handleFavoriteToggle() async {
    if (_currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add favorites'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    try {
      final bool nowFavorite = await _firestoreService.toggleFavorite(
        uid: _currentUserUid!,
        articleId: widget.article.id,
        title: widget.article.title,
        imageUrl: widget.article.imageUrl,
        newsSite: widget.article.newsSite,
        summary: widget.article.summary,
        publishedAt: widget.article.publishedAt,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nowFavorite ? 'Added to favorites collection' : 'Removed from favorites collection'),
          backgroundColor: nowFavorite ? const Color(0xFF00E5FF) : Colors.grey[800],
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Offline/Demo fallback if Firebase options are not set up yet
      setState(() {
        _localFavoriteState = !_localFavoriteState;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase not configured. Saved locally! (${e.toString().contains('FirebaseOptions') ? 'Credentials needed' : e.toString()})'),
          backgroundColor: Colors.indigoAccent,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: CustomScrollView(
        slivers: [
          // Dynamic Header Image
          SliverAppBar(
            expandedHeight: size.height * 0.4,
            pinned: true,
            backgroundColor: const Color(0xFF070B19),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF070B19).withOpacity(0.6),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF070B19).withOpacity(0.6),
                  child: _currentUserUid == null
                      ? IconButton(
                          icon: Icon(
                            _localFavoriteState ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: _localFavoriteState ? Colors.redAccent : Colors.white,
                          ),
                          onPressed: _handleFavoriteToggle,
                        )
                      : StreamBuilder<bool>(
                          stream: _firestoreService.isFavoriteStream(_currentUserUid!, widget.article.id),
                          builder: (context, snapshot) {
                            // If snapshot error or loading, fallback to local state toggle
                            final bool isFav = snapshot.data ?? _localFavoriteState;
                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                color: isFav ? Colors.redAccent : Colors.white,
                              ),
                              onPressed: _handleFavoriteToggle,
                            );
                          },
                        ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.article.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFF151D3B)),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0x77070B19), Color(0xFF070B19)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Body
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151D3B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: Color(0xFF00E5FF), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              widget.article.newsSite,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatFullDate(widget.article.publishedAt),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Full Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.35,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Thin divider line
                  Divider(
                    color: const Color(0xFF151D3B).withOpacity(0.8),
                    thickness: 1.5,
                  ),
                  const SizedBox(height: 16),

                  // Summary Title
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E5FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary Teks Ringkasan
                  Text(
                    widget.article.summary,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(String isoString) {
    try {
      final DateTime date = DateTime.parse(isoString).toLocal();
      final List<String> months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '';
    }
  }
}
