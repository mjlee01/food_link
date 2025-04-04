// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmmln_SE6gf-FLsVemo5py8cKlnR6tI_Y',
    appId: '1:383144624227:web:847e374df4ea47fcd8f856',
    messagingSenderId: '383144624227',
    projectId: 'food-link-b011d',
    authDomain: 'food-link-b011d.firebaseapp.com',
    storageBucket: 'food-link-b011d.firebasestorage.app',
    measurementId: 'G-HTMWLRTV89',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDpx-4TQkbNZiP6_-MiD4CWQp2ONDkBuw',
    appId: '1:383144624227:android:8c0b4411dcd0d344d8f856',
    messagingSenderId: '383144624227',
    projectId: 'food-link-b011d',
    storageBucket: 'food-link-b011d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjkK_xa_wTUB-eapBW48YhukU-l7xjsYg',
    appId: '1:383144624227:ios:3c3148176a58f63ad8f856',
    messagingSenderId: '383144624227',
    projectId: 'food-link-b011d',
    storageBucket: 'food-link-b011d.firebasestorage.app',
    iosBundleId: 'com.foodLink.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjkK_xa_wTUB-eapBW48YhukU-l7xjsYg',
    appId: '1:383144624227:ios:0dee034e97cbbd9cd8f856',
    messagingSenderId: '383144624227',
    projectId: 'food-link-b011d',
    storageBucket: 'food-link-b011d.firebasestorage.app',
    iosBundleId: 'com.example.foodLink',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCmmln_SE6gf-FLsVemo5py8cKlnR6tI_Y',
    appId: '1:383144624227:web:a8fdf13f8dc4b559d8f856',
    messagingSenderId: '383144624227',
    projectId: 'food-link-b011d',
    authDomain: 'food-link-b011d.firebaseapp.com',
    storageBucket: 'food-link-b011d.firebasestorage.app',
    measurementId: 'G-FGGD2BZEWH',
  );
}
