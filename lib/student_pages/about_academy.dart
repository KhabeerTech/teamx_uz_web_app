import 'package:flutter/material.dart';

class AboutAcademyPage extends StatelessWidget {
  const AboutAcademyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    double fontSize = screenWidth <= 500 ? 24 : 32;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akademiya haqida',
          style: TextStyle(
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
        width: screenWidth,
        height: screenHeight,
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
          child: Text(
            'Tez orada qo\'shiladi',
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Nexa',
              fontWeight: FontWeight.w800,
              color: const Color(0xFF512D84),
            ),
          ),
        ),
      ),
    );
  }
}
