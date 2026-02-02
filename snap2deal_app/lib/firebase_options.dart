import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCzilaXmHhCkldCQKA8Cj50AxiPPoctNq0',
    appId: '1:984256346962:web:679b0ecf50243f8acd588b',
    messagingSenderId: '984256346962',
    projectId: 'snap2deal-492a4',
    authDomain: 'snap2deal-492a4.firebaseapp.com',
    storageBucket: 'snap2deal-492a4.firebasestorage.app',
    measurementId: 'G-X6V06GH0MD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzilaXmHhCkldCQKA8Cj50AxiPPoctNq0',
    appId:
        '1:984256346962:android:abc123', // Update after downloading google-services.json
    messagingSenderId: '984256346962',
    projectId: 'snap2deal-492a4',
    storageBucket: 'snap2deal-492a4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzilaXmHhCkldCQKA8Cj50AxiPPoctNq0',
    appId:
        '1:984256346962:ios:abc123', // Update after downloading GoogleService-Info.plist
    messagingSenderId: '984256346962',
    projectId: 'snap2deal-492a4',
    storageBucket: 'snap2deal-492a4.firebasestorage.app',
  );
}
