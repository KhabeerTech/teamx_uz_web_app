import 'dart:ui';

import 'package:flutter/material.dart';

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

InputDecoration inputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle:
        const TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0), // Faqat chap va o'ng chetlarga padding
  );
}

class SignIn_username extends StatefulWidget {
  const SignIn_username({super.key});

  @override
  State<SignIn_username> createState() => _SignIn_usernameState();
}

class _SignIn_usernameState extends State<SignIn_username>
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
    double fontSize = screenWidth * 0.05;
    double paddingValue = screenHeight * 0.02;
    double logoSize = screenWidth * 0.25;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 249, 248, 198),
                  Color.fromARGB(255, 218, 200, 255)
                ], // Gradient ranglar
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: <Widget>[
                      // Katta rasm
                      Transform.translate(
                        offset: Offset(
                            0,
                            screenHeight *
                                0.05), // Ekran yuqorisidan 20% bo'sh joy
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: 0.1, sigmaY: 0.1), // Rasmga blur effekti
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 30),
                              opacity: _startAnimation
                                  ? 0.3
                                  : 0.0, // Rasmga opacity effekti qo'shish
                              child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcATop), // Rang filtri
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                        sigmaX: 5.0,
                                        sigmaY:
                                            5.0), // Xiralashtirishning kuchi
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width: logoSize * 3,
                                      height: logoSize * 3,
                                      fit: BoxFit.contain,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ),

                      // Kichik rasm (sal o'ng va yuqoriga joylashtirilgan)
                      Transform.translate(
                        offset: Offset(
                            screenWidth * -0.008,
                            screenHeight *
                                0.04), // Rasmni o'ng va yuqoriga ko'chirish
                        child: AnimatedOpacity(
                          duration: const Duration(
                              seconds: 1), // Sekinlashtirish uchun 10 soniya
                          opacity: _startAnimation ? 1.0 : 0.0,
                          child: Image.asset(
                            'assets/logo.png',
                            width: logoSize * 3, // Kichikroq rasm
                            height: logoSize * 3,
                            fit: BoxFit.contain,
                          ),
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
