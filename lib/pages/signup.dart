import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:teamx_uz_web_app/pages/signUpNext.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _startAnimation = false;
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newusernameController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _newrepaccwordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCheckingUsername = false;
  String? _usernameError;

  // Username mavjudligini tekshirish
  Future<bool> _isUsernameExists(String username) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();
      return doc.exists;
    } catch (e) {
      print("Firebase xatosi: $e");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    // Animatsiya controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30),
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
    
    // Rasm o'lchamini ekranga qarab moslash
    double logoSize;
    if (screenWidth > 950) {
      logoSize = screenWidth * 0.1; // 950px dan katta ekranlar uchun
    } else if (screenWidth > 400) {
      logoSize = screenWidth * 0.15; // 400px dan katta ekranlar uchun
    } else {
      logoSize = screenWidth * 0.25; // Kichik ekranlar uchun
    }
    InputDecoration inputDecoration(String labelText) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF512D84)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
      );
    }

// Validator uchun umumiy funksiya
    String? validateField(String? value, String fieldName) {
      if (value == null || value.isEmpty) {
        return "$fieldName maydoni to‘ldirilishi shart!";
      }
      return null;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          child: Container(
            width: screenWidth,
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Stack(
                      children: <Widget>[
                        Transform.translate(
                          offset: Offset(0, screenHeight * 0.03),
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
                                      width: logoSize * 3,
                                      height: logoSize * 3,
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
                              width: logoSize * 3,
                              height: logoSize * 3,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const Center(
                    child: Text(
                      "Ro‘yhatdan o‘tish",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF512D84),
                      ),
                      softWrap: false,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025), // Margin qo'shish
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _newNameController,
                          decoration: inputDecoration("Ism Familya").copyWith(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF512D84),
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFF512D84)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Ism Familya kiriting";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        TextFormField(
                          controller: _newusernameController,
                          decoration: inputDecoration("Username").copyWith(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF512D84),
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFF512D84)),
                          onChanged: (value) async {
                            if (value.length >= 4) {
                              bool exists = await _isUsernameExists(value);
                              setState(() {
                                if (exists) {
                                  _usernameError = "Bu username allaqachon band";
                                } else {
                                  _usernameError = null;
                                }
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Username kiriting";
                            }
                            if (value.length < 4) {
                              return "Username kamida 4 ta belgidan iborat bo'lishi kerak";
                            }
                            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                              return "Username faqat harflar va raqamlardan iborat bo'lishi kerak";
                            }
                            return _usernameError;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        TextFormField(
                          controller: _newpasswordController,
                          decoration: inputDecoration("Parol").copyWith(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF512D84),
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFF512D84)),
                          obscureText: true, // Parolni yashirish
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Parol kiriting";
                            }
                            if (value.length < 6) {
                              return "Parol kamida 6 ta belgidan iborat bo'lishi kerak";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        TextFormField(
                          controller: _newrepaccwordController,
                          decoration: inputDecoration("Parolni qayta kiriting")
                              .copyWith(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF512D84),
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFF512D84)),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Parolni qayta kiriting";
                            }
                            if (value.length < 6) {
                              return "Parol kamida 6 ta belgidan iborat bo'lishi kerak";
                            }
                            if (value != _newpasswordController.text) {
                              return "Parollar mos emas";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool exists = await _isUsernameExists(
                                  _newusernameController.text);
                              if (exists) {
                                setState(() {
                                  _usernameError = "Bu username allaqachon band";
                                });
                                _formKey.currentState!.validate();
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpNext(
                                    username: _newusernameController.text,
                                    fullName: _newNameController.text,
                                    password: _newpasswordController.text,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                const Color.fromRGBO(255, 235, 59, 1),
                            backgroundColor: const Color(0xFF512D84),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.3,
                                vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const FittedBox(
                            child: Text(
                              "Keyingi",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: false,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
