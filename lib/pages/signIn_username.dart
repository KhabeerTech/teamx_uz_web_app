import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:teamx_uz_web_app/pages/student_page.dart';
import 'package:teamx_uz_web_app/pages/signup.dart';
import 'package:teamx_uz_web_app/admins/admin_page.dart';
import 'package:teamx_uz_web_app/team_leads/team_lead_home_page.dart';
import 'package:teamx_uz_web_app/pages/sing_In_wait.dart';

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

InputDecoration inputDecoration(String labelText) {
  // Ekran o'lchamini olish
  final screenWidth = WidgetsBinding.instance.window.physicalSize.width /
      WidgetsBinding.instance.window.devicePixelRatio;

  // Border qalinligi
  final borderWidth = screenWidth > 1350 ? 4.0 : 2.5;
  // Padding hajmi
  final verticalPadding = screenWidth > 1350 ? 17.0 : 15.0;

  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: Color(0xFF512D84)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: Color(0xFF512D84), width: borderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: Color(0xFF512D84), width: borderWidth),
    ),
    contentPadding:
        EdgeInsets.symmetric(horizontal: 15.0, vertical: verticalPadding),
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firestore'dan foydalanuvchini tekshirish
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_usernameController.text)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        print('User Data: $userData'); // Debug

        if (userData['password'] == _passwordController.text) {
          print('Password matched'); // Debug
          print('User Type: ${userData['role']}'); // Debug

          if (userData['role'] == 'team_lead') {
            print('User is team lead'); // Debug
            
            if (userData['is_approved'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sizning hisobingiz hali admin tomonidan tasdiqlanmagan!'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }
            
            // Team Lead uchun
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeamLeadHomePage(
                  username: _usernameController.text,
                ),
              ),
            );
          } else if (userData['user_type'] == 'admin' ||
              userData['user_type'] == 'assistant') {
            print('User is admin/assistant'); // Debug
            // Admin uchun
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPage(),
              ),
            );
          } else {
            // Student uchun
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentPage(
                  username: _usernameController.text,
                ),
              ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Parol noto\'g\'ri!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bunday foydalanuvchi topilmadi'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      print("Firestore xatosi: $e"); // Debug uchun
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xatolik yuz berdi. Qaytadan urinib ko\'ring'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
    double scaleFactor = 1.0;
    if (screenWidth > 1340) {
      scaleFactor = 0.3; // 1350px dan katta ekranlar uchun
    } else if (screenWidth > 600) {
      scaleFactor = 0.5; // 600px dan katta ekranlar uchun
    }

    double fontSize = screenWidth * 0.05 * scaleFactor;
    double paddingValue = screenHeight * 0.02 * scaleFactor;
    double logoSize = screenWidth * 0.25 * scaleFactor;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  ], // Gradient ranglar
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                                sigmaX: 0.1,
                                sigmaY: 0.1), // Rasmga blur effekti
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
                  SizedBox(height: screenHeight * 0.1),
                  const Center(
                    child: Text(
                      "Kirish",
                      style: TextStyle(
                        fontSize: 30, fontFamily: 'Montserrat',
                        // fontWeight: FontWeight.bold, // Agar bold font kerak bo'lsa
                        // fontStyle: FontStyle.italic,
                        // fontFamily: 'Montserrat',
                        // fontWeight: FontWeight.bold,
                        fontWeight:
                            FontWeight.w800, // Agar bold font kerak bo'lsa
                        // fontStyle: FontStyle.italic,
                        color: Color(0xFF512D84),
                      ),
                      softWrap: false,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.015,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025), // Margin qo'shish
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: inputDecoration(
                            "Username",
                          ).copyWith(
                            labelStyle: const TextStyle(
                              fontWeight:
                                  FontWeight.w800, // Label matnini qalin qilish
                              color: Color(0xFF512D84),
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF512D84),
                            // fontWeight: FontWeight.w900,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username kiriting';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _passwordController,
                          decoration: inputDecoration("Parol").copyWith(
                            labelStyle: const TextStyle(
                              fontWeight:
                                  FontWeight.w900, // Label matnini qalin qilish
                              color: Color(0xFF512D84),
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF512D84),
                            fontWeight: FontWeight.bold,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Parolni kiriting';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "akkauntingiz bo'lmasa     ",
                          style: TextStyle(
                            color: const Color.fromARGB(221, 21, 21, 21),
                            fontSize: MediaQuery.of(context).size.width > 700
                                ? 18
                                : MediaQuery.of(context).size.width > 450
                                    ? 16.5
                                    : 14,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width > 700
                                ? screenWidth * 0.3
                                : MediaQuery.of(context).size.width > 450
                                    ? screenWidth * 0.04
                                    : screenWidth * 0.03),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ));
                          },
                          style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF512D84),
                              foregroundColor:
                                  const Color.fromRGBO(255, 235, 59, 1),
                              padding: MediaQuery.of(context).size.width > 700
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 17)
                                  : MediaQuery.of(context).size.width > 450
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10)),
                          child: Text(
                            "Ro'yhatdan o'tish",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 18
                                  : MediaQuery.of(context).size.width > 450
                                      ? 16
                                      : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.189),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
                      backgroundColor: const Color(0xFF512D84),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.35,
                          vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const FittedBox(
                            child: Text(
                              "Kirish",
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
          ),
        ));
  }
}
