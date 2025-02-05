import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamx_uz_web_app/firebase_options.dart';
import 'package:teamx_uz_web_app/pages/onboard.dart';
import 'package:teamx_uz_web_app/pages/student_page.dart';
import 'package:teamx_uz_web_app/admins/admin_page.dart';
import 'package:teamx_uz_web_app/team_leads/team_lead_home_page.dart';
// import 'package:teamx_uz_web_app/headimport 'package:firebase_core/firebase_core.dart';

// import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  try {
    print('Initializing Firebase...'); // Debug print
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully'); // Debug print
  } catch (e) {
    print('Error initializing Firebase: $e'); // Debug print
    // Firebase initializatsiya xatosi bo'lsa ham davom etamiz
  }

  runApp(const MyApp(homePage: OnboardPages()));
}

class MyApp extends StatelessWidget {
  final Widget homePage;
  
  const MyApp({super.key, required this.homePage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamX',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: homePage,
      debugShowCheckedModeBanner: false,
    );
  }
}