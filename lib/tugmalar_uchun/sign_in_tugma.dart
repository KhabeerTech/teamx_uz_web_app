// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:team_x/pages/sign_in.dart';

// class _RegistrationFormState extends State<RegistrationForm> {
//   // Firebase Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Your existing controllers...
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneFatherController = TextEditingController();
//   final TextEditingController _phoneMotherController = TextEditingController();
//   final TextEditingController _regionController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _branchController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _schoolNumber = TextEditingController();
//   final TextEditingController _age = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   // Your existing method to submit the form
//   void _submitForm() async {
//     try {
//       // Create a new user document in Firebase Firestore
//       await _firestore.collection('users').add({
//         'name': _nameController.text,
//         'phoneFather': _phoneFatherController.text,
//         'phoneMother': _phoneMotherController.text,
//         'region': _regionController.text,
//         'city': _cityController.text,
//         'branch': _branchController.text,
//         'password': _passwordController.text,
//         'schoolNumber': _schoolNumber.text,
//         'age': _age.text,
//         'grade': _selectedGrade,
//         'confirmPassword': _confirmPasswordController.text,
//       });

//       // Show a success message or navigate to another page
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Ro\'yxatdan o\'tish muvaffaqiyatli!')),
//       );

//       // You can navigate to another page, e.g., Onboard page
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => Onboard()),
//       );
//     } catch (e) {
//       // Handle any errors that occur during the Firebase operation
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Xatolik yuz berdi!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Your existing form fields here...
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed:
//                     _submitForm, // Call the _submitForm function when the button is pressed
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
//                   backgroundColor: const Color(0xFF512D84),
//                   padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text("Ro'yxatdan o'tish"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
