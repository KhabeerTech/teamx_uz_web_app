import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  final String courseName;
  const ComingSoonPage({required this.courseName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          courseName,
          style: const TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.w800,
            color: Color(0xFF512D84),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF512D84)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 249, 248, 198),
              Color.fromARGB(255, 218, 200, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.engineering,
                size: 100,
                color: Color(0xFF8C52FF),
              ),
              const SizedBox(height: 20),
              Text(
                '$courseName bo\'limi',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Nexa',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF512D84),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tez orada qo\'shiladi',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Nexa',
                  color: Color(0xFF512D84),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
