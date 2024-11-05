import 'package:firebase_core/firebase_core.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyBgsoC92o6pmsN-RmmryJuJcq7pJrfeAnY",
  authDomain: "memo-37886.firebaseapp.com",
  projectId: "memo-37886",
  storageBucket: "memo-37886.firebasestorage.app",
  messagingSenderId: "64688778305",
  appId: "1:64688778305:web:355029098dbd27f4692ac0",
);

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: firebaseConfig);
}
