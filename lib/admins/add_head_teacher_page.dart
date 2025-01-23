import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddHeadTeacherPage extends StatefulWidget {
  const AddHeadTeacherPage({super.key});

  @override
  _AddHeadTeacherPageState createState() => _AddHeadTeacherPageState();
}

class _AddHeadTeacherPageState extends State<AddHeadTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRegion;
  List<String> _regions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    try {
      final QuerySnapshot regionsSnapshot =
          await _firestore.collection('regions').get();
      setState(() {
        _regions =
            regionsSnapshot.docs.map((doc) => doc['name'] as String).toList();
        _regions.sort();
      });
    } catch (e) {
      print('Error loading regions: $e');
    }
  }

  Future<void> _addHeadTeacher() async {
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
      // Check if username already exists
      final userDoc = await _firestore
          .collection('users')
          .doc(_usernameController.text)
          .get();

      if (userDoc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu username allaqachon mavjud'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Add new head teacher
      await _firestore.collection('users').doc(_usernameController.text).set({
        'name': _nameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'region': _selectedRegion,
        'role': 'head_teacher',
        'case': 'yes',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Head teacher muvaffaqiyatli qo\'shildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _nameController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _phoneController.clear();
      setState(() {
        _selectedRegion = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xatolik yuz berdi: $e'),
          backgroundColor: Colors.red,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Head Teacher qo\'shish',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ism',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, ismni kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, username kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Parol',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, parolni kiriting';
                    }
                    if (value.length < 6) {
                      return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon raqam',
                    border: OutlineInputBorder(),
                    hintText: '+998901234567',
                  ),
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
                    if (_phoneController.text.isEmpty) {
                      _phoneController.text = "+998";
                      _phoneController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _phoneController.text.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, telefon raqamni kiriting';
                    }
                    if (!value.startsWith('+998')) {
                      return 'Raqam +998 bilan boshlanishi kerak';
                    }
                    if (value.length != 13) {
                      return 'Raqam 13 ta belgidan iborat bo\'lishi kerak';
                    }
                    // Raqam formati tekshirish: +998 dan keyin 9 ta raqam
                    final numberAfterCode = value.substring(4);
                    if (numberAfterCode.length != 9 ||
                        !RegExp(r'^\d{9}$').hasMatch(numberAfterCode)) {
                      return '+998 dan keyin 9 ta raqam kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Filial joyi',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF512D84),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isLoading ? null : _addHeadTeacher,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Qo\'shish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
