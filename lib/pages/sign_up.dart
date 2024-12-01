import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationForm();
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
  // Bu o'zgaruvchi State klassi ichida aniqlanishi kerak
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneFatherController = TextEditingController();
  final TextEditingController _phoneMotherController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schoolNumber = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int? _selectedGrade = 10;
  List<int> grades = [6, 7, 8, 9, 10, 11];

  InputDecoration inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF512D84)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.05;
    double paddingValue = screenHeight * 0.02;
    double logoSize = screenWidth * 0.25;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: paddingValue),
              Container(
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: paddingValue),
              Text(
                "Ro'yhatdan o'tish",
                style: TextStyle(
                    fontSize: fontSize, color: const Color(0xFF512D84)),
              ),
              SizedBox(height: paddingValue),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.021,
                    horizontal: screenHeight * 0.01),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 20,
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: inputDecoration("Ism Familiya"),
                      style: const TextStyle(color: Color(0xFF512D84)),
                    ),
                    SizedBox(height: paddingValue),
                    TextFormField(
                      controller: _age,
                      decoration: inputDecoration("Yosh"),
                      style: const TextStyle(color: Color(0xFF512D84)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: paddingValue),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: paddingValue / 2, horizontal: paddingValue),
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
                    ),
                  ),
                  SizedBox(width: paddingValue * 1.5),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: paddingValue / 2, horizontal: paddingValue),
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
                      value: _selectedGrade, // O'zgaruvchi qiymati
                      decoration: inputDecoration("Sinf"),
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
                            style: const TextStyle(color: Color(0xFF512D84)),
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
                decoration: InputDecoration(
                  labelText: "Onasining telefon raqami",
                  labelStyle: const TextStyle(color: Color(0xFF512D84)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF512D84), width: 2.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF512D84), width: 2.5),
                  ),
                ),
                style: const TextStyle(color: Color(0xFF512D84)),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^\+?\d*$')), // Faqat '+' va raqamlar ruxsat etiladi
                  LengthLimitingTextInputFormatter(
                      13), // Maksimum uzunlikni 13 ga cheklash
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
                      TextPosition(offset: _phoneFatherController.text.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 13) {
                    return "Telefon raqami +998 bilan boshlanishi va jami 13 raqamdan iborat bo'lishi kerak";
                  }
                  return null;
                },
              ),

              // TextFormField(
              //   controller: _phoneFatherController,
              //   decoration: InputDecoration(
              //     labelText: "Otasining telefon raqami",
              //     labelStyle: TextStyle(color: Color(0xFF512D84)),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide:
              //           BorderSide(color: Color(0xFF512D84), width: 2.5),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide:
              //           BorderSide(color: Color(0xFF512D84), width: 2.5),
              //     ),
              //   ),
              //   style: TextStyle(color: Color(0xFF512D84)),
              //   keyboardType: TextInputType.number,
              //   inputFormatters: [
              //     FilteringTextInputFormatter.digitsOnly,
              //     LengthLimitingTextInputFormatter(12),
              //     TextInputFormatter.withFunction((oldValue, newValue) {
              //       if (newValue.text.length < 3) {
              //         return TextEditingValue(
              //           text: "998",
              //           selection: TextSelection.collapsed(offset: 3),
              //         );
              //       } else if (!newValue.text.startsWith("998")) {
              //         return TextEditingValue(
              //           text: "998" + newValue.text.substring(3),
              //           selection: TextSelection.collapsed(
              //               offset: newValue.selection.end),
              //         );
              //       }
              //       return newValue;
              //     }),
              //   ],
              //   onTap: () {
              //     if (_phoneFatherController.text.isEmpty) {
              //       _phoneFatherController.text = "998";
              //     }
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty || value.length != 12) {
              //       return "Telefon raqami 998 bilan boshlanishi va 12 raqamdan iborat bo'lishi kerak";
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: _phoneMotherController,
                decoration: InputDecoration(
                  labelText: "Onasining telefon raqami",
                  labelStyle: const TextStyle(color: Color(0xFF512D84)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF512D84), width: 2.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF512D84), width: 2.5),
                  ),
                ),
                style: const TextStyle(color: Color(0xFF512D84)),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^\+?\d*$')), // Faqat '+' va raqamlar ruxsat etiladi
                  LengthLimitingTextInputFormatter(
                      13), // Maksimum uzunlikni 13 ga cheklash
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
                      TextPosition(offset: _phoneMotherController.text.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 13) {
                    return "Telefon raqami +998 bilan boshlanishi va jami 13 raqamdan iborat bo'lishi kerak";
                  }
                  return null;
                },
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: _regionController,
                decoration: inputDecoration("Qishloq / Tuman"),
                style: const TextStyle(color: Color(0xFF512D84)),
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: _cityController,
                decoration: inputDecoration("Shahar, Viloyat"),
                style: const TextStyle(color: Color(0xFF512D84)),
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: _branchController,
                decoration: inputDecoration("Qaysi filial"),
                style: const TextStyle(color: Color(0xFF512D84)),
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: _passwordController,
                decoration: inputDecoration("Parol"),
                style: const TextStyle(color: Color(0xFF512D84)),
                obscureText: true,
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: inputDecoration("Parolni qayta kiritish"),
                style: const TextStyle(color: Color(0xFF512D84)),
                obscureText: true,
              ),
              SizedBox(height: paddingValue * 2),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
                  backgroundColor: const Color(0xFF512D84),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.3,
                      vertical: screenHeight * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Ro'yxatdan o'tish"),
              ),
              // SizedBox(height: paddingValue * 2),
            ],
          ),
        ),
      ),
    );
  }
}























// import 'package:flutter/material.dart';
// import 'package:team_x/pages/onboard.dart';

// class SignUp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return RegistrationForm();
//   }
// }

// class RegistrationForm extends StatelessWidget {
//   // TextEditingControllerlarni har bir TextFormField uchun yaratish
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneFatherController = TextEditingController();
//   final TextEditingController _phoneMotherController = TextEditingController();
//   final TextEditingController _regionController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _branchController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _schollNumber = TextEditingController();
//   final TextEditingController _age = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   // Boshlang'ich sinfni tanlash uchun
//   int? _selectedGrade = 10;

//   // DropdownButtonFormField uchun sinflar
//   List<int> grades = [6, 7, 8, 9, 10, 11];

//   // InputDecorationni qaytarish
//   InputDecoration inputDecoration(String labelText) {
//     return InputDecoration(
//       labelText: labelText,
//       labelStyle: TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // MediaQuery orqali ekran o'lchamlarini olish
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     // Ekran o'lchamlariga asoslangan dinamik o'lchamlar
//     double fontSize =
//         screenWidth * 0.05; // Ekran kengligiga qarab shrift o'lchamini sozlash
//     double paddingValue = screenHeight *
//         0.02; // Ekran balandligiga qarab padding qiymatini sozlash
//     double logoSize =
//         screenWidth * 0.25; // Logo o'lchamini ekran kengligiga qarab sozlash

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(paddingValue),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                   height: paddingValue), // Yuqori qismda joy bo'shatish uchun
//               Container(
//                 child: Center(
//                   child: Image.asset(
//                     'assets/logo.png',
//                     width: logoSize,
//                     height: logoSize,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               SizedBox(height: paddingValue),
//               Text(
//                 "Ro'yhatdan o'tish",
//                 style: TextStyle(fontSize: fontSize, color: Color(0xFF512D84)),
//               ),
//               SizedBox(height: paddingValue),
//               // Ism Familiya va Yosh uchun container
//               Container(
//                 padding: EdgeInsets.symmetric(
//                     vertical: screenHeight * 0.021,
//                     horizontal: screenHeight * 0.01),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius:
//                       BorderRadius.circular(10), // Containerni kattalashtirdik
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5), // Soyaning qalinligi
//                       spreadRadius: 20, // Soyaning yoyilishi
//                       blurRadius: 25, // Soyaning bulanma radiusi
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: inputDecoration("Ism Familiya"),
//                       style: TextStyle(color: Color(0xFF512D84)),
//                     ),
//                     SizedBox(height: paddingValue),
//                     TextFormField(
//                       controller: _age,
//                       decoration: inputDecoration("Yosh"),
//                       style: TextStyle(color: Color(0xFF512D84)),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: paddingValue),
//               Row(
//                 children: [
//                   // Maktab yozuvi
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                         vertical: paddingValue / 2, horizontal: paddingValue),
//                     decoration: BoxDecoration(
//                       color: Color(0xFF512D84),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       'Maktab',
//                       style: TextStyle(
//                         color: Color(0xFFECE94C),
//                         fontSize: fontSize * 0.8,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: paddingValue),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _schollNumber,
//                       decoration: inputDecoration("10"),
//                       style: TextStyle(color: Color(0xFF512D84)),
//                     ),
//                   ),
//                   SizedBox(width: paddingValue * 1.5),
//                   // Sinf uchun DropdownButtonFormField
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                         vertical: paddingValue / 2, horizontal: paddingValue),
//                     decoration: BoxDecoration(
//                       color: Color(0xFF512D84),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       'Sinf',
//                       style: TextStyle(
//                         color: Color(0xFFECE94C),
//                         fontSize: fontSize * 0.8,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: paddingValue),
//                   Expanded(
//                     child: DropdownButtonFormField<int>(
//                       value: _selectedGrade,
//                       decoration: inputDecoration("Sinf"),
//                       onChanged: (newValue) {
//                         _selectedGrade = newValue!;
//                       },
//                       items: grades.map((grade) {
//                         return DropdownMenuItem<int>(
//                           value: grade,
//                           child: Text(grade.toString(),
//                               style: TextStyle(color: Color(0xFF512D84))),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _phoneFatherController,
//                 decoration: inputDecoration("Otasining telefon raqami"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _phoneMotherController,
//                 decoration: inputDecoration("Onasining telefon raqami"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _regionController,
//                 decoration: inputDecoration("Qishloq / Tuman"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _cityController,
//                 decoration: inputDecoration("Shahar, Viloyat"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _branchController,
//                 decoration: inputDecoration("Qaysi filial"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: inputDecoration("Parol"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//                 obscureText: true,
//               ),
//               SizedBox(height: paddingValue),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: inputDecoration("Parolni qayta kiritish"),
//                 style: TextStyle(color: Color(0xFF512D84)),
//                 obscureText: true,
//               ),
//               SizedBox(height: paddingValue * 2), // Quyida joy bo'shatish uchun
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


























// // import 'package:flutter/material.dart';
// // import 'package:team_x/pages/onboard.dart';

// // class SignUp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return RegistrationForm();
// //   }
// // }

// // class RegistrationForm extends StatelessWidget {
// //   // TextEditingControllerlarni har bir TextFormField uchun yaratish
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _phoneFatherController = TextEditingController();
// //   final TextEditingController _phoneMotherController = TextEditingController();
// //   final TextEditingController _regionController = TextEditingController();
// //   final TextEditingController _cityController = TextEditingController();
// //   final TextEditingController _branchController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _confirmPasswordController =
// //       TextEditingController();

// //   // Boshlang'ich sinfni tanlash uchun
// //   int? _selectedGrade = 10;

// //   // DropdownButtonFormField uchun sinflar
// //   List<int> grades = [6, 7, 8, 9, 10, 11];

// //   // InputDecorationni qaytarish
// //   InputDecoration inputDecoration(String labelText) {
// //     return InputDecoration(
// //       labelText: labelText,
// //       labelStyle: TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // MediaQuery orqali ekran o'lchamlarini olish
// //     double screenWidth = MediaQuery.of(context).size.width;
// //     double screenHeight = MediaQuery.of(context).size.height;

// //     // Ekran o'lchamlariga asoslangan dinamik o'lchamlar
// //     double fontSize =
// //         screenWidth * 0.05; // Ekran kengligiga qarab shrift o'lchamini sozlash
// //     double paddingValue = screenHeight *
// //         0.02; // Ekran balandligiga qarab padding qiymatini sozlash
// //     double logoSize =
// //         screenWidth * 0.25; // Logo o'lchamini ekran kengligiga qarab sozlash

// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: EdgeInsets.all(paddingValue),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               SizedBox(
// //                   height: paddingValue), // Yuqori qismda joy bo'shatish uchun
// //               Container(
// //                 child: Center(
// //                   child: Image.asset(
// //                     'assets/logo.png',
// //                     width: logoSize,
// //                     height: logoSize,
// //                     fit: BoxFit.contain,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: paddingValue),
// //               Text(
// //                 "Ro'yhatdan o'tish",
// //                 style: TextStyle(fontSize: fontSize, color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _nameController,
// //                 decoration: inputDecoration("Ism Familiya"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _nameController,
// //                 decoration: inputDecoration("Yosh"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               Row(
// //                 children: [
// //                   // Maktab yozuvi
// //                   Container(
// //                     padding: EdgeInsets.symmetric(
// //                         vertical: paddingValue / 2, horizontal: paddingValue),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF512D84),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       'Maktab',
// //                       style: TextStyle(
// //                         color: Color(0xFFECE94C),
// //                         fontSize: fontSize * 0.8,
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(width: paddingValue),
// //                   Expanded(
// //                     child: TextFormField(
// //                       controller: _nameController,
// //                       decoration: inputDecoration("10"),
// //                       style: TextStyle(color: Color(0xFF512D84)),
// //                     ),
// //                   ),
// //                   SizedBox(width: paddingValue * 1.5),
// //                   // Sinf uchun DropdownButtonFormField
// //                   Container(
// //                     padding: EdgeInsets.symmetric(
// //                         vertical: paddingValue / 2, horizontal: paddingValue),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF512D84),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       'Sinf',
// //                       style: TextStyle(
// //                         color: Color(0xFFECE94C),
// //                         fontSize: fontSize * 0.8,
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(width: paddingValue),
// //                   Expanded(
// //                     child: DropdownButtonFormField<int>(
// //                       value: _selectedGrade,
// //                       decoration: inputDecoration("Sinf"),
// //                       onChanged: (newValue) {
// //                         _selectedGrade = newValue!;
// //                       },
// //                       items: grades.map((grade) {
// //                         return DropdownMenuItem<int>(
// //                           value: grade,
// //                           child: Text(grade.toString(),
// //                               style: TextStyle(color: Color(0xFF512D84))),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _phoneFatherController,
// //                 decoration: inputDecoration("Otasining telefon raqami"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _phoneMotherController,
// //                 decoration: inputDecoration("Onasining telefon raqami"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _regionController,
// //                 decoration: inputDecoration("Qishloq / Tuman"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _cityController,
// //                 decoration: inputDecoration("Shahar, Viloyat"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _branchController,
// //                 decoration: inputDecoration("Qaysi filial"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _passwordController,
// //                 decoration: inputDecoration("Parol"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //                 obscureText: true,
// //               ),
// //               SizedBox(height: paddingValue),
// //               TextFormField(
// //                 controller: _confirmPasswordController,
// //                 decoration: inputDecoration("Parolni qayta kiritish"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //                 obscureText: true,
// //               ),
// //               SizedBox(height: paddingValue * 2), // Quyida joy bo'shatish uchun
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }



















// // import 'package:flutter/material.dart';
// // import 'package:team_x/pages/onboard.dart';

// // class SignUp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return RegistrationForm();
// //   }
// // }

// // class RegistrationForm extends StatelessWidget {
// //   // TextEditingControllerlarni har bir TextFormField uchun yaratish
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _phoneFatherController = TextEditingController();
// //   final TextEditingController _phoneMotherController = TextEditingController();
// //   final TextEditingController _regionController = TextEditingController();
// //   final TextEditingController _cityController = TextEditingController();
// //   final TextEditingController _branchController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _confirmPasswordController =
// //       TextEditingController();

// //   // Boshlang'ich sinfni tanlash uchun
// //   int? _selectedGrade = 10;

// //   // DropdownButtonFormField uchun sinflar
// //   List<int> grades = [6, 7, 8, 9, 10, 11];

// //   // InputDecorationni qaytarish
// //   InputDecoration inputDecoration(String labelText) {
// //     return InputDecoration(
// //       labelText: labelText,
// //       labelStyle: TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // appBar: AppBar(
// //       //   leading: IconButton(
// //       //       onPressed: () {
// //       //         Navigator.push(
// //       //             context,
// //       //             MaterialPageRoute(
// //       //               builder: (context) => OnboardPages(),
// //       //             ));
// //       //       },
// //       //       icon: Icon(Icons.arrow_back)),
// //       // ),
// //       backgroundColor: Colors.grey[100],
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               SizedBox(height: 20), // Yuqori qismda joy bo'shatish uchun
// //               Container(
// //                 // width: 100, // Container kengligi
// //                 // height: 100, // Container balandligi
// //                 // decoration: BoxDecoration(
// //                 //   // shape: BoxShape.circle,
// //                 //   color: Colors.white,
// //                 //   boxShadow: [
// //                 //     BoxShadow(
// //                 //       color: Colors.grey.withOpacity(0.5),
// //                 //       spreadRadius: 2,
// //                 //       blurRadius: 5,
// //                 //       offset: Offset(0, 3),
// //                 //     ),
// //                 //   ],
// //                 // ),
// //                 child: Center(
// //                   child: Image.asset(
// //                     'assets/logo.png',
// //                     width: 90,
// //                     height: 90,
// //                     fit: BoxFit.contain,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 10),
// //               Text(
// //                 "Ro'yhatdan o'tish",
// //                 style: TextStyle(fontSize: 24, color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: 20),
// //               TextFormField(
// //                 controller: _nameController,
// //                 decoration: inputDecoration("Ism Familiya"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: 10),
// //               TextFormField(
// //                 controller: _nameController,
// //                 decoration: inputDecoration("Yosh"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: 10),
// //               Row(
// //                 children: [
// //                   // Maktab yozuvi
// //                   Container(
// //                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF512D84),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       'Maktab',
// //                       style: TextStyle(
// //                         color: Color(0xFFECE94C),
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Expanded(
// //                     child: TextFormField(
// //                       controller: _nameController,
// //                       decoration: inputDecoration("10"),
// //                       style: TextStyle(color: Color(0xFF512D84)),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 25),
// //                   // Sinf uchun DropdownButtonFormField
// //                   Container(
// //                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 25),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF512D84),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       'Sinf',
// //                       style: TextStyle(
// //                         color: Color(0xFFECE94C),
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(width: 10),
// //                   Expanded(
// //                     child: DropdownButtonFormField<int>(
// //                       value: _selectedGrade,
// //                       decoration: inputDecoration("Sinf"),
// //                       onChanged: (newValue) {
// //                         _selectedGrade = newValue!;
// //                       },
// //                       items: grades.map((grade) {
// //                         return DropdownMenuItem<int>(
// //                           value: grade,
// //                           child: Text(grade.toString(),
// //                               style: TextStyle(color: Color(0xFF512D84))),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 10),
// //               TextFormField(
// //                 controller: _phoneFatherController,
// //                 decoration: inputDecoration("Otasining telefon raqami"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _phoneMotherController,
// //                 decoration: inputDecoration("Onasining telefon raqami"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _regionController,
// //                 decoration: inputDecoration("Qishloq / Tuman"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _cityController,
// //                 decoration: inputDecoration("Shahar, Viloyat"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _branchController,
// //                 decoration: inputDecoration("Qaysi filial"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _passwordController,
// //                 decoration: inputDecoration("Parol"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //                 obscureText: true,
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _confirmPasswordController,
// //                 decoration: inputDecoration("Parolni qayta kiritish"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //                 obscureText: true,
// //               ),

// //               SizedBox(height: 20), // Quyida joy bo'shatish uchun
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }




// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(SignUp());
// // }

// // class SignUp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: RegistrationForm(),
// //     );
// //   }
// // }

// // class RegistrationForm extends StatelessWidget {
// //   final TextEditingController _controller = TextEditingController();

// //   InputDecoration inputDecoration(String labelText) {
// //     return InputDecoration(
// //       labelText: labelText,
// //       labelStyle: TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide(color: Color(0xFF512D84), width: 2.5),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               SizedBox(height: 40), // Yuqori qismda joy bo'shatish uchun
// //               Text(
// //                 "Ro'yhatdan o'tish",
// //                 style: TextStyle(fontSize: 24, color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: 20),
// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: inputDecoration("Ism Familiya"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: 10),
// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: inputDecoration("Ism Familiya"),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),
// //               SizedBox(height: 10),
// //               Row(
// //                 children: [
// //                   // Maktab yozuvi
// //                   Container(
// //                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF512D84),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       'Maktab',
// //                       style: TextStyle(
// //                         color: Color(0xFFECE94C),
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Expanded(
// //                     child: TextFormField(
// //                       controller: _controller,
// //                       decoration: inputDecoration("10"),
// //                       style: TextStyle(color: Color(0xFF512D84)),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 25),
// //                   // Sinf yozuvi
// //                   Container(
// //                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 25),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF512D84),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       'Sinf',
// //                       style: TextStyle(
// //                         color: Color(0xFFECE94C),
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(width: 10),
// //                   Expanded(
// //                     child: TextFormField(
// //                       controller: _controller,
// //                       decoration: inputDecoration("10-A"),
// //                       style: TextStyle(color: Color(0xFF512D84)),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 10),
// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Otasining telefon raqami",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding: EdgeInsets.symmetric(
// //                       vertical: 8.0,
// //                       horizontal: 12.0), // Balandlikni qisqartirish uchun
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Onasining telefon raqami",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Qishloq / Tuman",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Shahar, Viloyat",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Qaysi filial",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Parol",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //                 obscureText: true,
// //               ),

// //               SizedBox(height: 10),

// //               TextFormField(
// //                 controller: _controller,
// //                 decoration: InputDecoration(
// //                   labelText: "Parolni qayta kiritish",
// //                   labelStyle: TextStyle(color: Color(0xFF512D84)),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide:
// //                         BorderSide(color: Color(0xFF512D84), width: 2.5),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
// //                 ),
// //                 style: TextStyle(color: Color(0xFF512D84)),
// //                 obscureText: true,
// //               ),

// //               SizedBox(height: 20),

// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Otasining telefon raqami"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               // ),
// //               // SizedBox(height: 10),
// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Onasining telefon raqami"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               // ),
// //               // SizedBox(height: 10),
// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Qishloq / Tuman"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               // ),
// //               // SizedBox(height: 10),
// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Shahar, Viloyat"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               // ),
// //               // SizedBox(height: 10),
// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Qaysi filial"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               // ),
// //               // SizedBox(height: 10),
// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Parol"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               //   obscureText: true,
// //               // ),
// //               // SizedBox(height: 10),
// //               // TextFormField(
// //               //   controller: _controller,
// //               //   decoration: inputDecoration("Parolni qayta kiritish"),
// //               //   style: TextStyle(color: Color(0xFF512D84)),
// //               //   obscureText: true,
// //               // ),
// //               // SizedBox(height: 20), // Quyida joy bo'shatish uchun
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
