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
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('teamX haqida', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('teamX haqida sahifasi',
            style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
