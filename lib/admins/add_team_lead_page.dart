import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeamLeadPage extends StatefulWidget {
  final String headTeacherUsername;
  final String headTeacherRegion;
  const AddTeamLeadPage({
    Key? key,
    required this.headTeacherUsername,
    required this.headTeacherRegion,
  }) : super(key: key);

  @override
  State<AddTeamLeadPage> createState() => _AddTeamLeadPageState();
}

class _AddTeamLeadPageState extends State<AddTeamLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addTeamLead() async {
    if (!_formKey.currentState!.validate()) return;

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
            content: Text('Bu username band!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Add new team lead
      await _firestore.collection('users').doc(_usernameController.text).set({
        'name': _nameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'region': widget.headTeacherRegion,
        'role': 'team_lead',
        'head_teacher': widget.headTeacherUsername,
        'case': 'yes',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team Lead muvaffaqiyatli qo\'shildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding team lead: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xatolik yuz berdi'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Yangi Team Lead qo\'shish',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ism Familiya',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos ismni kiriting';
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
                    return 'Iltimos username kiriting';
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
                    return 'Iltimos parolni kiriting';
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
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                  prefixText: '+998 ',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos telefon raqamni kiriting';
                  }
                  // Raqam formati tekshirish: +998 dan keyin 9 ta raqam
                  final numberAfterCode = value;
                  if (numberAfterCode.length != 9 ||
                      !RegExp(r'^\d{9}$').hasMatch(numberAfterCode)) {
                    return '9 ta raqam kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Show head teacher region
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Viloyat',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.headTeacherRegion,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addTeamLead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
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
    );
  }
}
