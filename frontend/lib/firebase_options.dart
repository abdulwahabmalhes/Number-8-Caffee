import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// FlutterFire configuration for Number Eight Specialty Coffee.
/// Generated from GoogleService-Info.plist (com.numbereight.frontend).
class DefaultFirebaseOptions {
  static bool get isSupportedOnCurrentPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android yet - '
          'add google-services.json and run flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvPfZVXZ-_Nq6KgWXBPkMBSh3YSNXDd90',
    appId: '1:411342658301:ios:160f5d9c92c33a991b7c94',
    messagingSenderId: '411342658301',
    projectId: 'number-8-509e1',
    storageBucket: 'number-8-509e1.firebasestorage.app',
    iosBundleId: 'com.numbereight.frontend',
  );
}
