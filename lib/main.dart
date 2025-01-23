import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teamx_uz_web_app/firebase_options.dart';
import 'package:teamx_uz_web_app/pages/onboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamX',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardPages(),
      debugShowCheckedModeBanner: false,
    );
  }
}
