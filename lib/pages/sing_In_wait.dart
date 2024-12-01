import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SingInWait extends StatefulWidget {
  const SingInWait({super.key});

  @override
  State<SingInWait> createState() => _SingInWaitState();
}

class _SingInWaitState extends State<SingInWait>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _startAnimation = false;

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
  }

  @override
  void dispose() {
    _controller.dispose(); // Animatsiya controllerni tozalash
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Ekran o'lchamiga qarab masshtablash
    double scaleFactor;
    double titleFontSize = 20.0;
    double subtitleFontSize = 16.0;
    double iconSize = 65.0;
    double containerWidth = 0.8;
    double containerPadding = 15.0;

    // Ekran o'lchamlariga qarab sozlash
    if (screenWidth <= 300) {
      scaleFactor = 0.8;
      titleFontSize *= 0.8;
      subtitleFontSize *= 0.8;
      iconSize *= 0.8;
      containerWidth = 0.9;
      containerPadding = 12;
    } else if (screenWidth <= 500) {
      scaleFactor = 0.85;
      titleFontSize *= 0.85;
      subtitleFontSize *= 0.85;
      iconSize *= 0.85;
      containerWidth = 0.85;
    } else if (screenWidth <= 700) {
      scaleFactor = 0.9;
      titleFontSize *= 0.9;
      subtitleFontSize *= 0.9;
      iconSize *= 0.9;
    } else if (screenWidth <= 900) {
      scaleFactor = 0.95;
      titleFontSize *= 0.95;
      subtitleFontSize *= 0.95;
      iconSize *= 0.95;
    } else if (screenWidth <= 1100) {
      scaleFactor = 1.0;
      titleFontSize *= 1.0;
      subtitleFontSize *= 1.0;
      iconSize *= 1.0;
    } else if (screenWidth <= 1300) {
      scaleFactor = 1.05;
      titleFontSize *= 1.05;
      subtitleFontSize *= 1.05;
      iconSize *= 1.05;
    } else if (screenWidth <= 1500) {
      scaleFactor = 1.1;
      titleFontSize *= 1.1;
      subtitleFontSize *= 1.1;
      iconSize *= 1.1;
    } else {
      scaleFactor = 1.15;
      titleFontSize *= 1.15;
      subtitleFontSize *= 1.15;
      iconSize *= 1.15;
    }

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
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
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: <Widget>[
                      Transform.translate(
                        offset: Offset(0, screenHeight * 0.05),
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
                                    width: screenWidth * 0.25 * scaleFactor,
                                    height: screenWidth * 0.25 * scaleFactor,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset:
                            Offset(screenWidth * -0.008, screenHeight * 0.04),
                        child: AnimatedOpacity(
                          duration: const Duration(seconds: 1),
                          opacity: _startAnimation ? 1.0 : 0.0,
                          child: Image.asset(
                            'assets/logo.png',
                            width: screenWidth * 0.25 * scaleFactor,
                            height: screenWidth * 0.25 * scaleFactor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),
                Container(
                  width: screenWidth * containerWidth * scaleFactor,
                  padding: EdgeInsets.all(containerPadding * scaleFactor),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_task_outlined,
                        size: iconSize,
                        color: Colors.green,
                      ),
                      SizedBox(height: 20 * scaleFactor),
                      Text(
                        "Ma'lumotlaringiz adminga yuborildi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          color: const Color(0xFF512D84),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Admin tasdiqlashini kuting",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: const Color(0xFF512D84),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
