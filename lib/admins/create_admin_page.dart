import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAdminPage extends StatefulWidget {
  const CreateAdminPage({super.key});

  @override
  State<CreateAdminPage> createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends State<CreateAdminPage> {
  final _nameController = TextEditingController();
  final _newAdminUsernameController = TextEditingController();
  final _newAdminPasswordController = TextEditingController();
  bool _isCreatingAdmin = false;
  String _selectedUserType = 'assistant'; // Default qiymat

  Future<void> _createNewAdmin() async {
    if (_nameController.text.isEmpty ||
        _newAdminUsernameController.text.isEmpty ||
        _newAdminPasswordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barcha maydonlarni to\'ldiring'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isCreatingAdmin = true);

    try {
      final username = _newAdminUsernameController.text;

      // Username bandligini tekshirish
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu username band'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isCreatingAdmin = false);
        return;
      }

      // Yangi admin qo'shish - username ni document ID sifatida ishlatish
      await FirebaseFirestore.instance.collection('users').doc(username).set({
        'name': _nameController.text,
        'username': username,
        'password': _newAdminPasswordController.text,
        'user_type': _selectedUserType,
        'case': 'yes',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yangi asistent muvaffaqiyatli qo\'shildi',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: const Color.fromRGBO(236, 233, 76, 1),
          ),
        );
        // Maydonlarni tozalash
        _nameController.clear();
        _newAdminUsernameController.clear();
        _newAdminPasswordController.clear();
        Navigator.pop(
            context); // Muvaffaqiyatli yaratilgandan so'ng orqaga qaytish
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isCreatingAdmin = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF512D84),
        title: const Text('Yangi Admin Yaratish'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8F0FF), Color(0xFFF0F7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF512D84).withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF512D84).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Color(0xFF512D84),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Yangi Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF512D84),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Ism',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newAdminUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newAdminPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Parol',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      decoration: InputDecoration(
                        labelText: 'Foydalanuvchi turi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'team_leader',
                          child: Text('Team Leader'),
                        ),
                        DropdownMenuItem(
                          value: 'assistant',
                          child: Text('Assistant'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedUserType = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCreatingAdmin ? null : _createNewAdmin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(236, 233, 76, 1),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreatingAdmin
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF512D84),
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Yaratish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newAdminUsernameController.dispose();
    _newAdminPasswordController.dispose();
    super.dispose();
  }
}
