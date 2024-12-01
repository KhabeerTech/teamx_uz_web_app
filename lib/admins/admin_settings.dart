import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // Yangi admin uchun controllerlar
  final _newAdminUsernameController = TextEditingController();
  final _newAdminPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCreatingAdmin = false;
  String? _initialUsername;

  // Xatolik holatlarini saqlash uchun
  bool _isOldPasswordError = false;
  bool _isNewPasswordError = false;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('user_type', isEqualTo: 'admin')
          .get();

      if (adminDoc.docs.isNotEmpty) {
        final adminData = adminDoc.docs.first.data();
        setState(() {
          _nameController.text = adminData['username'] ?? '';
          _initialUsername = _nameController.text;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ma\'lumotlarni yuklashda xatolik yuz berdi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createNewAdmin() async {
    if (_newAdminUsernameController.text.isEmpty ||
        _newAdminPasswordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username va parolni kiriting'),
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
        return;
      }

      // Yangi admin qo'shish - username ni document ID sifatida ishlatish
      await FirebaseFirestore.instance.collection('users').doc(username).set({
        'username': username,
        'password': _newAdminPasswordController.text,
        'user_type': 'assistant',
        'case': 'yes',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yangi asistent muvaffaqiyatli qo\'shildi'),
            backgroundColor: Colors.green,
          ),
        );
        // Maydonlarni tozalash
        _newAdminUsernameController.clear();
        _newAdminPasswordController.clear();
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

  void _showCreateAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi admin yaratish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newAdminUsernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newAdminPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Parol',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: _isCreatingAdmin ? null : _createNewAdmin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF512D84),
              foregroundColor: Colors.white,
            ),
            child: _isCreatingAdmin
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Yaratish'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAdminData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('user_type', isEqualTo: 'admin')
          .get();

      if (adminDoc.docs.isNotEmpty) {
        final docId = adminDoc.docs.first.id;
        final adminData = adminDoc.docs.first.data();

        // Joriy parolni tekshirish
        if (_oldPasswordController.text.isEmpty ||
            _oldPasswordController.text != adminData['password']) {
          setState(() {
            _isOldPasswordError = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_oldPasswordController.text.isEmpty
                    ? 'Joriy parolni kiriting'
                    : 'Joriy parol noto\'g\'ri'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        // Agar joriy parol to'g'ri bo'lsa va yangi parol kiritilgan bo'lsa
        if (_newPasswordController.text.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({
            'password': _newPasswordController.text,
          });
        }

        // Username ni o'zgartirish
        if (_nameController.text != adminData['username']) {
          // Username bandligini tekshirish
          final usernameCheck = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: _nameController.text)
              .get();

          if (usernameCheck.docs.isNotEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bu username band'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() => _isLoading = false);
            return;
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({
            'username': _nameController.text,
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Muvaffaqiyatli o\'zgartirildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
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

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF512D84),
        title: const Text('Sozlamalar'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin ma\'lumotlari',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF512D84),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, username kiriting';
                  }
                  // Username uzunligi 4-20 orasida bo'lishi kerak
                  if (value.length < 4 || value.length > 20) {
                    return 'Username 4-20 ta belgidan iborat bo\'lishi kerak';
                  }
                  // Faqat harflar, raqamlar va _ belgisiga ruxsat berish
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Username faqat harflar, raqamlar va _ belgisidan iborat bo\'lishi mumkin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Parolni o\'zgartirish',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF512D84),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Joriy parol',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isOldPasswordError ? Colors.red : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isOldPasswordError ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isOldPasswordError
                          ? Colors.red
                          : const Color(0xFF512D84),
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: _isOldPasswordError ? Colors.red : null,
                  ),
                  labelStyle: TextStyle(
                    color: _isOldPasswordError ? Colors.red : null,
                  ),
                ),
                onChanged: (value) {
                  if (_isOldPasswordError) {
                    setState(() {
                      _isOldPasswordError = false;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Joriy parolni kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yangi parol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateAdminData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF512D84),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Saqlash',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showCreateAdminDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    'Yangi admin tayinlash',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _newAdminUsernameController.dispose();
    _newAdminPasswordController.dispose();
    super.dispose();
  }
}
