import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSSiclpCso0UIeTNkQQaWFEWPN4TjJ0oc',
    appId: '1:293406059655:web:e84f999fc75a7aaa071c22',
    messagingSenderId: '293406059655',
    projectId: 'flutter-study-67f3f',
    authDomain: 'flutter-study-67f3f.firebaseapp.com',
    storageBucket: 'flutter-study-67f3f.firebasestorage.app',
    measurementId: 'G-94YLD59X5S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSSiclpCso0UIeTNkQQaWFEWPN4TjJ0oc',
    appId: '1:293406059655:android:default',
    messagingSenderId: '293406059655',
    projectId: 'flutter-study-67f3f',
    storageBucket: 'flutter-study-67f3f.firebasestorage.app',
  );
}