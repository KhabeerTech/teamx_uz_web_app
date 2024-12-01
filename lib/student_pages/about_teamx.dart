import 'package:flutter/material.dart';

class AboutTeamXPage extends StatefulWidget {
  const AboutTeamXPage({super.key});

  @override
  State<AboutTeamXPage> createState() => _AboutTeamXPageState();
}

class _AboutTeamXPageState extends State<AboutTeamXPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('teamX haqida'),
      ),
      body: const Center(
        child: Text('teamX haqida sahifasi'),
      ),
    );
  }
}
