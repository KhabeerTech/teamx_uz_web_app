import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const SettingsPage({
    super.key,
    required this.userData,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xatolik yuz berdi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showSignOutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Chiqishni tasdiqlash',
          style: TextStyle(
            color: Color(0xFF512D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Haqiqatan ham tizimdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Yo\'q',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF512D84),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ha'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Sozlamalar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF512D84),
              child: Text(
                (widget.userData['name'] as String)
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(widget.userData['name'] ?? ''),
            subtitle: Text(widget.userData['username'] ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Tizimdan chiqish',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _showSignOutDialog,
          ),
        ],
      ),
    );
  }
}
