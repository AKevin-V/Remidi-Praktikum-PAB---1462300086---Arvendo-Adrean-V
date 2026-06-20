import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
/// 
/// Replace these mock settings with your actual Firebase project settings
/// or run `flutterfire configure` to regenerate this file.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'MOCK_API_KEY_WEB_REPLACE_ME',
    appId: '1:123456789:web:abcdef',
    messagingSenderId: '123456789',
    projectId: 'spacenews-core-default',
    authDomain: 'spacenews-core-default.firebaseapp.com',
    storageBucket: 'spacenews-core-default.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'MOCK_API_KEY_ANDROID_REPLACE_ME',
    appId: '1:123456789:android:abcdef',
    messagingSenderId: '123456789',
    projectId: 'spacenews-core-default',
    storageBucket: 'spacenews-core-default.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'MOCK_API_KEY_IOS_REPLACE_ME',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'spacenews-core-default',
    storageBucket: 'spacenews-core-default.appspot.com',
    iosBundleId: 'com.spacenews.core',
  );
}
