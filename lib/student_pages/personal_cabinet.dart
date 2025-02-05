import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamx_uz_web_app/pages/signIn_username.dart';
import 'dart:html' as html;

class PersonalCabinetPage extends StatefulWidget {
  final String username;
  const PersonalCabinetPage({super.key, required this.username});

  @override
  State<PersonalCabinetPage> createState() => _PersonalCabinetPageState();
}

class _PersonalCabinetPageState extends State<PersonalCabinetPage>
    with SingleTickerProviderStateMixin {
  bool _startAnimation = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Ma'lumotlarni o'zbekchaga o'girish uchun Map
  final Map<String, String> _fieldNames = {
    'username': 'usernamengiz',
    'grade': 'Sinfingiz',
    'full_name': 'Ism familiyasi',
    'school_number': 'Maktabingiz ',
    'mother_phone': 'Onangizning telefon raqami',
    'father_phone': 'Otangizning telefon raqami',
  };

  void _signOut() {
    // localStorage dan ma'lumotlarni o'chirish
    html.window.localStorage.remove('username');
    html.window.localStorage.remove('password');
    html.window.localStorage.remove('user_role');

    // Sign in page ga o'tish
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SignIn_username(),
      ),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  Future<void> _getUserData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _userData = querySnapshot.docs.first.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _userData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userData = null;
        _isLoading = false;
      });
    }
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
          textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double scale;
    double padding;
    double fontSize = 16;
    double buttonHeight;
    double imageScale;

    // Scaling calculations
    if (screenWidth <= 200) {
      buttonHeight = screenHeight * 0.065;
      fontSize *= 0.9;
      imageScale = 0.75;
    } else if (screenWidth <= 300) {
      buttonHeight = screenHeight * 0.065;
      fontSize *= 0.7;
      imageScale = 0.85;
    } else if (screenWidth <= 400) {
      buttonHeight = screenHeight * 0.065;
      fontSize *= 0.88;
      imageScale = 0.85;
    } else if (screenWidth <= 500) {
      buttonHeight = screenHeight * 0.065;
      fontSize *= 1.2;
      imageScale = 0.88;
    } else if (screenWidth <= 600) {
      buttonHeight = screenHeight * 0.065;
      fontSize *= 1.3;
      imageScale = 0.4;
    } else if (screenWidth <= 700) {
      buttonHeight = screenHeight * 0.07;
      fontSize *= 1.4;
      imageScale = 0.6;
    } else if (screenWidth <= 800) {
      buttonHeight = screenHeight * 0.07;
      fontSize *= 1.5;
      imageScale = 0.2;
    } else if (screenWidth <= 900) {
      buttonHeight = screenHeight * 0.07;
      fontSize *= 1.6;
      imageScale = 0.9;
    } else if (screenWidth <= 1000) {
      buttonHeight = screenHeight * 0.07;
      fontSize *= 1.7;
      imageScale = 0.85;
    } else if (screenWidth <= 1100) {
      buttonHeight = screenHeight * 0.075;
      fontSize *= 1.8;
      imageScale = 0.8;
    } else if (screenWidth <= 1200) {
      buttonHeight = screenHeight * 0.075;
      fontSize *= 1.9;
      imageScale = 0.75;
    } else if (screenWidth <= 1300) {
      buttonHeight = screenHeight * 0.08;
      fontSize *= 2.0;
      imageScale = 0.7;
    } else if (screenWidth <= 1400) {
      buttonHeight = screenHeight * 0.08;
      fontSize *= 2.1;
      imageScale = 0.65;
    } else if (screenWidth <= 1500) {
      buttonHeight = screenHeight * 0.085;
      fontSize *= 2.2;
      imageScale = 0.6;
    } else if (screenWidth <= 1600) {
      buttonHeight = screenHeight * 0.085;
      fontSize *= 2.3;
      imageScale = 0.55;
    } else if (screenWidth <= 1700) {
      buttonHeight = screenHeight * 0.09;
      fontSize *= 2.1;
      imageScale = 0.5;
    } else if (screenWidth <= 1800) {
      buttonHeight = screenHeight * 0.09;
      fontSize *= 2.2;
      imageScale = 0.45;
    } else {
      buttonHeight = screenHeight * 0.095;
      fontSize *= 2.3;
      imageScale = 0.4;
    }

    return Scaffold(
      appBar: screenWidth < 600
          ? AppBar(
              backgroundColor: const Color(0xFF512D84),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Shaxsiy kabinet',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Nexa',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF512D84),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Shaxsiy kabinet',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Nexa',
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 249, 248, 198),
              Color.fromARGB(255, 218, 200, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            Transform.translate(
                              offset: Offset(0, screenHeight * 0.02),
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
                                        Colors.black,
                                        BlendMode.srcATop,
                                      ),
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: 5.0,
                                          sigmaY: 5.0,
                                        ),
                                        child: Image.asset(
                                          'assets/logo.png',
                                          width: screenWidth <= 800
                                              ? screenWidth * 0.4 * imageScale
                                              : screenWidth * 0.3 * imageScale,
                                          height: screenWidth <= 800
                                              ? screenWidth * 0.4 * imageScale
                                              : screenWidth * 0.3 * imageScale,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(
                                screenWidth * -0.008,
                                screenHeight * 0.01,
                              ),
                              child: AnimatedOpacity(
                                duration: const Duration(seconds: 1),
                                opacity: _startAnimation ? 1.0 : 0.0,
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: screenWidth <= 800
                                      ? screenWidth * 0.4 * imageScale
                                      : screenWidth * 0.3 * imageScale,
                                  height: screenWidth <= 800
                                      ? screenWidth * 0.4 * imageScale
                                      : screenWidth * 0.3 * imageScale,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_userData == null)
                        const Center(child: Text('Ma\'lumotlar topilmadi'))
                      else
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ..._fieldNames.entries.map((entry) {
                                final value = _userData![entry.key];
                                if (value == null) return const SizedBox.shrink();

                                return _buildButton(
                                  '${entry.value}: ${value.toString()}',
                                  fontSize,
                                  screenWidth * 0.85,
                                  buttonHeight,
                                );
                              }).toList(),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _signOut,
                                child: Container(
                                  width: screenWidth * 0.85,
                                  height: buttonHeight,
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
                                      'Chiqish',
                                      style: TextStyle(
                                        fontSize: fontSize,
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
                ),
              ),
              if (screenWidth <= 850)
                Positioned(
                  right: screenHeight * -0.002,
                  bottom: screenWidth * -0.15,
                  child: Image.asset(
                    'assets/newimage.png',
                    width: screenWidth * 0.45,
                    height: screenHeight * 0.45,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
