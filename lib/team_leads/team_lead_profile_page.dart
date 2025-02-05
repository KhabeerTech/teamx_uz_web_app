import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:teamx_uz_web_app/pages/signIn_username.dart';
import 'dart:html' as html;

class TeamLeadProfilePage extends StatelessWidget {
  final String username;

  const TeamLeadProfilePage({Key? key, required this.username})
      : super(key: key);

  void _signOut(BuildContext context) {
    // localStorage dan ma'lumotlarni o'chirish
    html.window.localStorage.remove('username');
    html.window.localStorage.remove('password');
    html.window.localStorage.remove('user_role');

    // Sign in page ga o'tish
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SignIn_username(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Xatolik yuz berdi'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final teamLeadData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF512DA8),
                      child: Text(
                        teamLeadData['full_name']
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'T',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      teamLeadData['full_name'] ?? 'Nomsiz',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@$username',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shaxsiy ma\'lumotlar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoItem(
                        icon: Icons.location_on,
                        title: 'Akademiya',
                        value: teamLeadData['region'] ?? 'N/A',
                      ),
                      _buildInfoItem(
                        icon: Icons.phone,
                        title: 'Otangizning telefon raqami',
                        value: teamLeadData['father_phone'] ?? 'N/A',
                      ),
                      _buildInfoItem(
                        icon: Icons.phone,
                        title: 'Onangizning telefon raqami',
                        value: teamLeadData['mother_phone'] ?? 'N/A',
                      ),
                      _buildInfoItem(
                        icon: Icons.phone,
                        title: 'Telefon raqamingiz',
                        value: teamLeadData['phone'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Statistics card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistika',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('team_lead_username', isEqualTo: username)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final studentCount =
                              snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildInfoItem(
                            icon: Icons.people,
                            title: 'O\'quvchilar soni',
                            value: studentCount.toString(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final groupLink = userData['group_link'] as String?;

                  if (groupLink == null || groupLink.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await canLaunch(groupLink)) {
                          await launch(groupLink);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C52FF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Guruhim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _signOut(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(239, 233, 233, 1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color.fromRGBO(81, 45, 132, 1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Chiqish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF512D84),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF512DA8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
