import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../models/user_profile.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Static memory cache for mock favorites to support real-time stream simulation in demo mode
  static final List<Map<String, dynamic>> _mockFavorites = [];
  
  // Broadcast controller to push updates to favorites stream listeners
  static final StreamController<List<Map<String, dynamic>>> _favoritesController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Helper check to determine if running in mock/demo mode
  bool get _isFirebaseMock {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      return options.apiKey.contains('MOCK') || options.apiKey.contains('REPLACE');
    } catch (_) {
      return true;
    }
  }

  // Save user profile
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String instagram,
  }) async {
    if (_isFirebaseMock) return;
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'instagram': instagram,
      'photoUrl': r'C:\Users\User\Downloads\Foto Formal Santai 2.png',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user profile stream
  Stream<UserProfile?> getUserProfileStream(String uid) {
    if (_isFirebaseMock) {
      return Stream.value(null);
    }
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Toggle favorite (returns true if now favorited, false if removed)
  Future<bool> toggleFavorite({
    required String uid,
    required int articleId,
    required String title,
    String? imageUrl,
    String? newsSite,
    String? summary,
    String? publishedAt,
  }) async {
    if (_isFirebaseMock) {
      final int index = _mockFavorites.indexWhere((item) => item['articleId'] == articleId);
      bool isAdded = false;
      
      if (index >= 0) {
        _mockFavorites.removeAt(index);
      } else {
        _mockFavorites.add({
          'userId': uid,
          'articleId': articleId,
          'title': title,
          'imageUrl': imageUrl ?? '',
          'newsSite': newsSite ?? '',
          'summary': summary ?? '',
          'publishedAt': publishedAt ?? '',
        });
        isAdded = true;
      }
      
      // Notify all listeners
      _favoritesController.add(List.from(_mockFavorites));
      return isAdded;
    }

    final String docId = '${uid}_$articleId';
    final DocumentReference favDoc = _db.collection('favorites').doc(docId);
    
    final DocumentSnapshot doc = await favDoc.get();
    
    if (doc.exists) {
      await favDoc.delete();
      return false;
    } else {
      await favDoc.set({
        'userId': uid,
        'articleId': articleId,
        'title': title,
        'imageUrl': imageUrl ?? '',
        'newsSite': newsSite ?? '',
        'summary': summary ?? '',
        'publishedAt': publishedAt ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  // Stream of favorites list for a user
  Stream<List<Map<String, dynamic>>> getFavoritesStream(String uid) {
    if (_isFirebaseMock) {
      // Return a stream that yields current state immediately, then updates on changes
      return _favoritesController.stream.asyncStart(() async => _mockFavorites);
    }
    return _db
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Stream of favorite status for a single article
  Stream<bool> isFavoriteStream(String uid, int articleId) {
    if (_isFirebaseMock) {
      return _favoritesController.stream
          .map((favs) => favs.any((item) => item['articleId'] == articleId))
          .asyncStart(() async => _mockFavorites.any((item) => item['articleId'] == articleId));
    }

    final String docId = '${uid}_$articleId';
    return _db.collection('favorites').doc(docId).snapshots().map((doc) => doc.exists);
  }
}

// Helper extension to yield an initial value before mapping a stream
extension StreamExtension<T> on Stream<T> {
  Stream<T> asyncStart(Future<T> Function() initial) async* {
    yield await initial();
    yield* this;
  }
}
