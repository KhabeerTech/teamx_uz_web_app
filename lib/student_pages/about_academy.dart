import 'package:flutter/material.dart';

class AboutAcademyPage extends StatefulWidget {
  const AboutAcademyPage({super.key});

  @override
  State<AboutAcademyPage> createState() => _AboutAcademyPageState();
}

class _AboutAcademyPageState extends State<AboutAcademyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akademiya haqida'),
      ),
      body: const Center(
        child: Text('Akademiya haqida sahifasi'),
      ),
    );
  }
}
