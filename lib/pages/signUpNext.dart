import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamx_uz_web_app/pages/sing_In_wait.dart';
import 'package:teamx_uz_web_app/pages/student_page.dart';

class SignUpNext extends StatefulWidget {
  final String username;
  final String fullName;
  final String password;

  const SignUpNext({
    super.key,
    required this.username,
    required this.fullName,
    required this.password,
  });

  @override
  State<SignUpNext> createState() => _SignUpNextState();
}

class _SignUpNextState extends State<SignUpNext> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _startAnimation = false;
  final TextEditingController _phoneFatherController = TextEditingController();
  final TextEditingController _phoneMotherController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _schoolNumber = TextEditingController();
  final TextEditingController _ageController =
      TextEditingController(text: 'Yosh');
  int _selectedAge = 13;
  int? _selectedGrade = 10;
  List<int> grades = [6, 7, 8, 9, 10, 11];
  String? _selectedRegion; // Qo'shildi
  List<String> _regions = []; // Qo'shildi
  bool _isLoading = false;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  void validateAllFields() {
    if (_formKey.currentState?.validate() ?? false) {
      _saveUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Formni to'ldirishingiz kerak!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _startAnimation = true;
        _controller.forward();
      });
    });

    _loadRegions(); // Qo'shildi
  }

  // Regionlarni yuklash funksiyasi
  Future<void> _loadRegions() async {
    try {
      final QuerySnapshot regionsSnapshot =
          await _firestore.collection('regions').get();
      setState(() {
        _regions =
            regionsSnapshot.docs.map((doc) => doc['name'] as String).toList();
        _regions.sort(); // Alifbo tartibida saralash
      });
    } catch (e) {
      print('Error loading regions: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, filial joyini tanlang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ma'lumotlarni Firestore'ga saqlash
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(widget.username);

      await userDoc.set({
        'username': widget.username,
        'age': _selectedAge,
        'full_name': widget.fullName,
        'password': widget
            .password, // ESLATMA: Parolni xavfsiz saqlash uchun hash qilish kerak
        'school_number': _schoolNumber.text,
        'grade': _selectedGrade,
        'father_phone': _phoneFatherController.text,
        'mother_phone': _phoneMotherController.text,
        'region': _selectedRegion, // O'zgartirildi
        'created_at': FieldValue.serverTimestamp(),
        'role': 'student', // O'quvchi roli
        'is_approved': false, // Yangi o'quvchilar tasdiqlash kutishadi
        'case': 'no', // Har bir yangi foydalanuvchi uchun case="no"
      }, SetOptions(merge: true));

      // Kutish sahifasiga o'tish
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SingInWait(),
        ),
      );
    } catch (e) {
      print("Firestore xatosi: $e"); // Debug uchun

      // Foydalanuvchiga xato haqida xabar berish
      if (!mounted) return;
      String errorMessage = "Ma'lumotlarni saqlashda xatolik yuz berdi.";

      if (e.toString().contains('permission-denied')) {
        errorMessage = "Ruxsat yo'q. Iltimos, tizimga qayta kiring.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Ekran o'lchamiga qarab masshtablash
    double scaleFactor;
    if (screenWidth > 1450) {
      scaleFactor = 0.25; // 1450px dan katta ekranlar uchun
    } else if (screenWidth > 1100) {
      scaleFactor = 0.35; // 1100px dan katta ekranlar uchun
    } else if (screenWidth > 800) {
      scaleFactor = 0.5; // 800px dan katta ekranlar uchun
    } else if (screenWidth > 450) {
      scaleFactor = 0.7; // 450px dan katta ekranlar uchun
    } else {
      scaleFactor = 1.0; // Kichik ekranlar uchun
    }

    double fontSize = screenWidth * 0.04 * scaleFactor;
    double paddingValue = screenWidth * 0.04 * scaleFactor;
    double logoSize = screenWidth * 0.25 * scaleFactor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF512D84),
              const Color(0xFF512D84).withOpacity(0.5),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth,
              constraints: BoxConstraints(
                minHeight:
                    screenHeight, // Minimal balandlik ekran balandligiga teng
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
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
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                child: Column(children: [
                  Center(
                    child: Stack(
                      children: <Widget>[
                        // Katta rasm
                        Transform.translate(
                          offset: Offset(0, screenHeight * 0.01),
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
                                      width: logoSize * 2,
                                      height: logoSize * 2,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Kichik rasm
                        Transform.translate(
                          offset: Offset(
                              screenWidth * -0.008, screenHeight * 0.0000005),
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: _startAnimation ? 1.0 : 0.0,
                            child: Image.asset(
                              'assets/logo.png',
                              width: logoSize * 2,
                              height: logoSize * 2,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.0001),
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
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF512D84), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: const TextStyle(
                                color: Color(0xFF512D84),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: paddingValue),
                      GestureDetector(
                        onTap: () => _showDialog(
                          CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32.0,
                            scrollController: FixedExtentScrollController(
                              initialItem: _selectedAge -
                                  13, // Adjusted for the starting point
                            ),
                            onSelectedItemChanged: (int selectedItem) {
                              setState(() {
                                _selectedAge = selectedItem +
                                    13; // Update with selected age
                              });
                            },
                            children: List<Widget>.generate(53, (int index) {
                              return Center(
                                  child: Text((index + 13).toString()));
                            }),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF512D84), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Yosh: $_selectedAge',
                                    style: const TextStyle(
                                      color: Color(0xFF512D84),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // TextFormField(
                      //   controller: _age,
                      //   decoration: inputDecoration("Yosh"),
                      //   style: TextStyle(color: Color(0xFF512D84)),
                      //   keyboardType: TextInputType.number,
                      //   inputFormatters: [
                      //     FilteringTextInputFormatter.digitsOnly,
                      //     LengthLimitingTextInputFormatter(3),
                      //   ],
                      // ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: paddingValue / 2,
                            horizontal: paddingValue),
                        decoration: BoxDecoration(
                          color: const Color(0xFF512D84),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Maktab',
                          style: TextStyle(
                            color: const Color(0xFFECE94C),
                            fontSize: fontSize * 0.8,
                          ),
                        ),
                      ),
                      SizedBox(width: paddingValue),
                      Expanded(
                        child: TextFormField(
                          controller: _schoolNumber,
                          decoration: inputDecoration("10"),
                          style: const TextStyle(color: Color(0xFF512D84)),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "maktab";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: paddingValue * 1.5),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: paddingValue / 2,
                            horizontal: paddingValue),
                        decoration: BoxDecoration(
                          color: const Color(0xFF512D84),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Sinf',
                          style: TextStyle(
                            color: const Color(0xFFECE94C),
                            fontSize: fontSize * 0.8,
                          ),
                        ),
                      ),
                      SizedBox(width: paddingValue),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedGrade,
                          decoration: inputDecoration("Sinf"),
                          validator: (value) {
                            if (value == null) {
                              return "Sinfni tanlang";
                            }
                            return null;
                          },
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGrade = newValue!;
                            });
                          },
                          items: grades.map((grade) {
                            return DropdownMenuItem<int>(
                              value: grade,
                              child: Text(
                                grade.toString(),
                                style:
                                    const TextStyle(color: Color(0xFF512D84)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: paddingValue),
                  TextFormField(
                    controller: _phoneFatherController,
                    decoration: inputDecoration("Otasining telefon raqami"),
                    style: const TextStyle(color: Color(0xFF512D84)),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$')),
                      LengthLimitingTextInputFormatter(13),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.length < 4 &&
                            !newValue.text.startsWith('+998')) {
                          return const TextEditingValue(
                            text: "+998",
                            selection: TextSelection.collapsed(offset: 4),
                          );
                        }
                        return newValue;
                      }),
                    ],
                    onTap: () {
                      if (_phoneFatherController.text.isEmpty) {
                        _phoneFatherController.text = "+998";
                        _phoneFatherController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _phoneFatherController.text.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "raqamingizni kiriting";
                      }
                      if (value.length != 13 || !value.startsWith('+998')) {
                        return "raqamni tog'ri kiriting";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: paddingValue),
                  TextFormField(
                    controller: _phoneMotherController,
                    decoration: inputDecoration("Onasining telefon raqami"),
                    style: const TextStyle(color: Color(0xFF512D84)),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$')),
                      LengthLimitingTextInputFormatter(13),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.length < 4 &&
                            !newValue.text.startsWith('+998')) {
                          return const TextEditingValue(
                            text: "+998",
                            selection: TextSelection.collapsed(offset: 4),
                          );
                        }
                        return newValue;
                      }),
                    ],
                    onTap: () {
                      if (_phoneMotherController.text.isEmpty) {
                        _phoneMotherController.text = "+998";
                        _phoneMotherController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _phoneMotherController.text.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "raqamingizni kiriting";
                      }
                      if (value.length != 13 || !value.startsWith('+998')) {
                        return "raqamni tog'ri kiriting";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: paddingValue),
                  DropdownButtonFormField<String>(
                    // TextField o'rniga DropdownButtonFormField
                    value: _selectedRegion,
                    decoration: inputDecoration('Filial joyi'),
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Iltimos, filial joyini tanlang';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.1),
                  ElevatedButton(
                    onPressed: validateAllFields,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
                      backgroundColor: const Color(0xFF512D84),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.3,
                          vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const FittedBox(
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
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
