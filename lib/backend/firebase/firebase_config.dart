import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCsg05lKx-eFFjtZ3nUQEDfqce5cY5vhqo",
            authDomain: "summ-a-ize-lt6ras.firebaseapp.com",
            projectId: "summ-a-ize-lt6ras",
            storageBucket: "summ-a-ize-lt6ras.appspot.com",
            messagingSenderId: "922759884909",
            appId: "1:922759884909:web:d61c6ca20b452dec944f64"));
  } else {
    await Firebase.initializeApp();
  }
}
