
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:teamx_uz_web_app/pages/signIn_username.dart';
import 'package:teamx_uz_web_app/pages/sing_In_wait.dart';

class OnboardPages extends StatefulWidget {
  const OnboardPages({super.key});

  @override
  State<OnboardPages> createState() => _OnboardPagesState();
}

class _OnboardPagesState extends State<OnboardPages> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Onboard(),
    );
  }
}

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();

    // Animatsiya controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Animatsiya davomiyligi
    );

    // Boshlang'ich animatsiya
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Future bilan animatsiyani boshlash
    Future.delayed(const Duration(milliseconds: 500), () {
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
    double fontSize = screenWidth * 0.05;
    double paddingValue = screenHeight * 0.02;

    // Responsive logo size calculation
    double logoSize;
    double multiplier;

    if (screenWidth > 1400) {
      logoSize = screenWidth * 0.08; // Juda katta ekranlar uchun
      multiplier = 2.8;
    } else if (screenWidth > 1200) {
      logoSize = screenWidth * 0.12; // Katta ekranlar uchun
      multiplier = 3.0;
    } else if (screenWidth > 800) {
      logoSize = screenWidth * 0.15; // O'rta ekranlar uchun
      multiplier = 3.2;
    } else if (screenWidth > 500) {
      logoSize = screenWidth * 0.18; // Kichikroq ekranlar uchun
      multiplier = 3.3;
    } else {
      logoSize = screenWidth * 0.25; // Juda kichik ekranlar uchun
      multiplier = 3.5;
    }

    return Scaffold(
        body: Stack(
      children: [
        // Yuqoridagi rasm
        Positioned(
          top: screenHeight * 0.15, // Yuqoridan 15% pastda
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Katta rasm
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
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
                          imageFilter:
                              ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Image.asset(
                            'assets/logo.png',
                            width: logoSize * multiplier,
                            height: logoSize * multiplier,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Kichik rasm
                Transform.translate(
                  offset: Offset(screenWidth * -0.02, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _startAnimation ? 1.0 : 0.0,
                    child: Image.asset(
                      'assets/logo.png',
                      width: logoSize * multiplier,
                      height: logoSize * multiplier,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pastdagi tugma
        Positioned(
          bottom: screenHeight * 0.05, // Pastdan 5% yuqorida
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignIn_username(),
                    ));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
                backgroundColor: const Color(0xFF512D84),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.2,
                    vertical: screenHeight * 0.01),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const FittedBox(
                child: Text(
                  "BOSHLASH",
                  style: TextStyle(
                    fontSize: 34,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
