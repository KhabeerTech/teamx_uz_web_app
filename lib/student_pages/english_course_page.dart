import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EnglishCoursePage extends StatefulWidget {
  final int startStep;
  final int userStep;
  const EnglishCoursePage({
    required this.startStep,
    required this.userStep,
    super.key,
  });

  @override
  State<EnglishCoursePage> createState() => _EnglishCoursePageState();
}

class _EnglishCoursePageState extends State<EnglishCoursePage> {
  final _firestore = FirebaseFirestore.instance;

  void _launchTelegramChannel() async {
    const telegramUrl = 'https://t.me/+h5O6K_Dx5jFkMjYy';
    try {
      if (await canLaunch(telegramUrl)) {
        await launch(telegramUrl);
      } else {
        throw 'Could not launch $telegramUrl';
      }
    } catch (e) {
      debugPrint('Error launching Telegram URL: $e');
    }
  }

  Widget _buildStepGrid() {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;

    // 3 ta ustun uchun button o'lchami
    double buttonWidth = (screenWidth * 0.9) / 3;
    // 10 ta qator uchun button o'lchami (ekran balandligining 70% ini ishlatamiz)
    double buttonHeight = (screenHeight * 0.7) / 10;

    double fontSize = screenWidth <= 500 ? 16 : 20;

    return Container(
      width: screenWidth * 0.95,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 240, 255),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF8C52FF),
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(10, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (col) {
              final index = row * 3 + col;
              final stepNumber = widget.startStep + index;
              if (index >= 30) return const SizedBox.shrink();

              Color buttonColor;
              // Agar foydalanuvchi shu konteynerdan o'tib ketgan bo'lsa
              if (widget.userStep > widget.startStep + 29) {
                buttonColor = const Color(0xFF00BF63); // Hammasi yashil
              }
              // Agar foydalanuvchi shu konteyner ichida bo'lsa
              else if (widget.userStep >= widget.startStep &&
                  widget.userStep <= widget.startStep + 29) {
                if (stepNumber <= widget.userStep) {
                  buttonColor =
                      const Color(0xFF00BF63); // O'tgan qadamlar yashil
                } else if (stepNumber <= widget.userStep + 3) {
                  buttonColor = const Color(0xFFFFA726); // Keyingi 3 ta sariq
                } else {
                  buttonColor = Colors.white; // Qolganlari oq
                }
              }
              // Agar foydalanuvchi bu konteynergacha yetib kelmagan bo'lsa
              else {
                buttonColor = Colors.white; // Hammasi oq
              }

              return Container(
                width: buttonWidth * 0.9,
                height: buttonHeight * 0.9,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        buttonColor == Colors.white ? Colors.grey : buttonColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: buttonColor == Colors.white
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  // Widget _buildTelegramButton() {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final buttonWidth =
  //       screenWidth <= 800 ? screenWidth * 0.8 : screenWidth * 0.27;
  //   final buttonHeight = screenWidth <= 800 ? 45.0 : 60.0;
  //   final fontSize = screenWidth <= 800 ? 16.0 : 20.0;
  //   final iconSize = screenWidth <= 800 ? 24.0 : 32.0;

  //   return Container(
  //     margin: EdgeInsets.all(screenWidth <= 800 ? 16 : 24),
  //     width: buttonWidth,
  //     height: buttonHeight,
  //     child: ElevatedButton.icon(
  //       onPressed: _launchTelegramChannel,
  //       icon: Icon(
  //         Icons.telegram,
  //         color: Colors.white,
  //         size: iconSize,
  //       ),
  //       label: Text(
  //         'Telegram kanalga o\'tish',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: fontSize,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFF512D84),
  //         padding: EdgeInsets.symmetric(
  //           horizontal: screenWidth <= 800 ? 24 : 36,
  //           vertical: screenWidth <= 800 ? 16 : 24,
  //         ),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Ingliz tili',
          style: TextStyle(
            color: Color(0xFF512D84),
            fontWeight: FontWeight.bold,
          ),
        ),
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
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.01,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStepGrid(),
                // _buildTelegramButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
