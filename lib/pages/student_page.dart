import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../student_pages/personal_cabinet.dart';
import '../student_pages/my_courses.dart';
import '../student_pages/about_academy.dart';
import '../student_pages/about_teamx.dart';
import '../student_pages/trial_steps_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPage extends StatefulWidget {
  final String username;
  final VoidCallback? onPersonalCabinetPressed;

  const StudentPage({
    super.key,
    required this.username,
    this.onPersonalCabinetPressed,
  });

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _startAnimation = false;
  String userStep = '1-qadam';
  int userWarnings = 0;

  @override
  void initState() {
    super.initState();

    // Animatsiya controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30), // Animatsiya davomiyligi
    );

    // Boshlang'ich animatsiya
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Future bilan animatsiyani boshlash
    Future.delayed(const Duration(milliseconds: 20), () {
      setState(() {
        _startAnimation = true;
        _controller.forward();
      });
    });
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.username)
          .get();

      if (userDoc.exists) {
        setState(() {
          if (userDoc.data()?['steps'] != null) {
            userStep = '${userDoc.data()?['steps']}-qadam';
          }
          if (userDoc.data()?['warned'] != null) {
            userWarnings = userDoc.data()?['warned'];
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Animatsiya controllerni tozalash
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = MediaQuery.of(context).size.width;

        return _buildLayout(context, 1.0, 12, 16);
      },
    );
  }

  Widget _buildLayout(
      BuildContext context, double scale, double padding, double fontSize) {
    final size = MediaQuery.of(context).size;
    final paddingValue = MediaQuery.of(context).padding;
    double screenWidth = size.width;
    double screenHeight = size.height;

    // Height va text size ni ekran o'lchamiga qarab moslashtirish
    double buttonHeight;
    double textSize;
    double imageScale;

    if (screenWidth <= 100) {
      buttonHeight = screenHeight * 0.065;
      textSize = fontSize * 0.8;
      imageScale = 0.7;
    } else if (screenWidth <= 200) {
      buttonHeight = screenHeight * 0.065;
      textSize = fontSize * 0.9;
      imageScale = 0.75;
    } else if (screenWidth <= 300) {
      buttonHeight = screenHeight * 0.065;
      textSize = fontSize * 0.7;
      imageScale = 0.85;
    } else if (screenWidth <= 400) {
      buttonHeight = screenHeight * 0.065;
      textSize = fontSize * 0.88;
      imageScale = 0.85;
    } else if (screenWidth <= 500) {
      buttonHeight = screenHeight * 0.065;
      textSize = fontSize * 1.2;
      imageScale = 0.88;
    } else if (screenWidth <= 600) {
      buttonHeight = screenHeight * 0.065;
      textSize = fontSize * 1.3;
      imageScale = 0.4;
    } else if (screenWidth <= 700) {
      buttonHeight = screenHeight * 0.07;
      textSize = fontSize * 1.4;
      imageScale = 0.6;
    } else if (screenWidth <= 800) {
      buttonHeight = screenHeight * 0.07;
      textSize = fontSize * 1.5;
      imageScale = 0.2;
    } else if (screenWidth <= 900) {
      buttonHeight = screenHeight * 0.07;
      textSize = fontSize * 1.6;
      imageScale = 0.9;
    } else if (screenWidth <= 1000) {
      buttonHeight = screenHeight * 0.07;
      textSize = fontSize * 1.7;
      imageScale = 0.85;
    } else if (screenWidth <= 1100) {
      buttonHeight = screenHeight * 0.075;
      textSize = fontSize * 1.8;
      imageScale = 0.8;
    } else if (screenWidth <= 1200) {
      buttonHeight = screenHeight * 0.075;
      textSize = fontSize * 1.9;
      imageScale = 0.75;
    } else if (screenWidth <= 1300) {
      buttonHeight = screenHeight * 0.08;
      textSize = fontSize * 2.0;
      imageScale = 0.7;
    } else if (screenWidth <= 1400) {
      buttonHeight = screenHeight * 0.08;
      textSize = fontSize * 2.1;
      imageScale = 0.65;
    } else if (screenWidth <= 1500) {
      buttonHeight = screenHeight * 0.085;
      textSize = fontSize * 2.2;
      imageScale = 0.6;
    } else if (screenWidth <= 1600) {
      buttonHeight = screenHeight * 0.085;
      textSize = fontSize * 2.3;
      imageScale = 0.55;
    } else if (screenWidth <= 1700) {
      buttonHeight = screenHeight * 0.09;
      textSize = fontSize * 2.1;
      imageScale = 0.5;
    } else if (screenWidth <= 1800) {
      buttonHeight = screenHeight * 0.09;
      textSize = fontSize * 2.2;
      imageScale = 0.45;
    } else if (screenWidth <= 1900) {
      buttonHeight = screenHeight * 0.095;
      textSize = fontSize * 2.3;
      imageScale = 0.4;
    } else if (screenWidth <= 2000) {
      buttonHeight = screenHeight * 0.1;
      textSize = fontSize * 2.4;
      imageScale = 0.35;
    } else {
      buttonHeight = screenHeight * 0.1;
      textSize = fontSize * 2.5;
      imageScale = 0.3;
    }

    // MediaQuery orqali ekran o'lchamiga qarab scale va padding ni moslashtirish
    if (screenWidth <= 100) {
      scale *= 0.3;
      padding = 1;
    } else if (screenWidth <= 200) {
      scale *= 0.4;
      padding = 2;
    } else if (screenWidth <= 300) {
      scale *= 0.5;
      padding = 3;
    } else if (screenWidth <= 400) {
      scale *= 0.6;
      padding = 4;
    } else if (screenWidth <= 500) {
      scale *= 0.7;
      padding = 5;
    } else if (screenWidth <= 600) {
      scale *= 0.8;
      padding = 6;
    } else if (screenWidth <= 700) {
      scale *= 0.85;
      padding = 7;
    } else if (screenWidth <= 800) {
      scale *= 0.9;
      padding = 8;
    } else if (screenWidth <= 900) {
      scale *= 0.95;
      padding = 9;
    } else if (screenWidth <= 1000) {
      scale *= 1.0;
      padding = 10;
    } else if (screenWidth <= 1200) {
      scale *= 0.9; // Scale ni kattaroq qildim
      padding = 8; // Padding ni kamaytirib qo'ydim
    } else if (screenWidth <= 1400) {
      scale *= 0.85;
      padding = 7;
    } else if (screenWidth <= 1600) {
      scale *= 0.8;
      padding = 6;
    } else if (screenWidth <= 1800) {
      scale *= 0.75;
      padding = 5;
    } else {
      scale *= 0.7;
      padding = 4;
    }

    double logoSize;
    if (screenWidth <= 800) {
      logoSize = screenWidth * 0.3 * scale; // 800px gacha katta o'lcham
    } else {
      logoSize = screenWidth * 0.2 * scale; // 800px dan keyin normal o'lcham
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: screenWidth,
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          padding: EdgeInsets.all(padding),
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
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.02 * scale),
                  Center(
                    child: Stack(
                      children: <Widget>[
                        Transform.translate(
                          offset: Offset(0, screenHeight * 0.02 * scale),
                          child: ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 0,
                                ),
                              ),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 30),
                                opacity: _startAnimation ? 0.3 : 0.0,
                                child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                        Colors.black, BlendMode.srcATop),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                          sigmaX: 5.0, sigmaY: 5.0),
                                      child: Image.asset(
                                        'assets/logo.png',
                                        width: screenWidth <= 800
                                            ? logoSize * 2.5
                                            : logoSize * 2,
                                        height: screenWidth <= 800
                                            ? logoSize * 2.5
                                            : logoSize * 2,
                                        fit: BoxFit.contain,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(screenWidth * -0.008 * scale,
                              screenHeight * 0.01 * scale),
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: _startAnimation ? 1.0 : 0.0,
                            child: Image.asset(
                              'assets/logo.png',
                              width: screenWidth <= 800
                                  ? logoSize * 2.5
                                  : logoSize * 2,
                              height: screenWidth <= 800
                                  ? logoSize * 2.5
                                  : logoSize * 2,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02 * scale),
                  Padding(
                    padding: EdgeInsets.all(padding * 0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: screenWidth * 0.9,
                          height:
                              screenWidth <= 800 ? screenHeight * 0.12 : null,
                          margin: EdgeInsets.only(
                              bottom: screenWidth <= 800
                                  ? screenHeight * 0.025
                                  : screenHeight * 0.02),
                          padding: EdgeInsets.all(screenWidth <= 800 ? 16 : 16),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(239, 233, 233, 1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color.fromRGBO(81, 45, 132, 1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Qadamingiz: $userStep',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF512D84),
                                  ),
                                ),
                                SizedBox(height: screenWidth <= 800 ? 12 : 8),
                                Text(
                                  'Ogohlantirishlaringiz: $userWarnings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF512D84),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: screenWidth <= 800
                                ? screenHeight * 0.025
                                : screenHeight * 0.02),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonalCabinetPage(
                                  username: widget.username,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.9,
                            height: screenWidth <= 800
                                ? screenHeight * 0.07
                                : buttonHeight * scale,
                            margin: EdgeInsets.only(
                                bottom: screenWidth <= 800
                                    ? screenHeight * 0.025
                                    : 16),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(239, 233, 233, 1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color.fromRGBO(81, 45, 132, 1),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Shaxsiy kabinetim',
                                style: TextStyle(
                                  fontSize: textSize,
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF512D84),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // Userning ma'lumotlarini olish
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.username)
                                .get();

                            if (!mounted) return;

                            if (userDoc.exists) {
                              final userData = userDoc.data() as Map<String, dynamic>;

                              // 3daystest true bo'lsa TrialStepsPage ga o'tish
                              if (userData['3daystest'] == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrialStepsPage(),
                                  ),
                                );
                              } else {
                                // Aks holda MyCoursesPage ga o'tish
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyCoursesPage(
                                      username: widget.username,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.9,
                            height: screenWidth <= 800
                                ? screenHeight * 0.07
                                : buttonHeight * scale,
                            margin: EdgeInsets.only(
                                bottom: screenWidth <= 800
                                    ? screenHeight * 0.025
                                    : 16),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(239, 233, 233, 1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color.fromRGBO(81, 45, 132, 1),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Qadamlarim',
                                style: TextStyle(
                                  fontSize: textSize + 2,
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF512D84),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutAcademyPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.9,
                            height: screenWidth <= 800
                                ? screenHeight * 0.07
                                : buttonHeight * scale,
                            margin: EdgeInsets.only(
                                bottom: screenWidth <= 800
                                    ? screenHeight * 0.025
                                    : 16),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(239, 233, 233, 1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color.fromRGBO(81, 45, 132, 1),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Akademiya haqida',
                                style: TextStyle(
                                  fontSize: textSize,
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF512D84),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (screenWidth <= 850)
                Positioned(
                  right: screenHeight * -0.002 * scale,
                  bottom: screenWidth * -0.15 * scale,
                  child: Image.asset(
                    'assets/newimage.png',
                    width: screenWidth * 0.45, // Ekran kengligi bo'yicha 15%
                    height:
                        screenHeight * 0.45, // Ekran balandligi bo'yicha 15%
                    fit: BoxFit.contain, // Rasm proporsiyasini saqlash
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, double fontSize, double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 233, 233, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color.fromRGBO(81, 45, 132, 1),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'Nexa',
            fontWeight: FontWeight.w800,
            color: const Color(0xFF512D84),
          ),
        ),
      ),
    );
  }
}
