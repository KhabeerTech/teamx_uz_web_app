import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_lead_students_page.dart';
import 'team_lead_profile_page.dart';
import 'package:teamx_uz_web_app/team_leads/my_students_page.dart';

class TeamLeadHomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TeamLeadHomePage({Key? key, required this.userData}) : super(key: key);

  @override
  _TeamLeadHomePageState createState() => _TeamLeadHomePageState();
}

class _TeamLeadHomePageState extends State<TeamLeadHomePage> {
  int _selectedIndex = 0;
  late Stream<DocumentSnapshot> _teamLeadStream;

  @override
  void initState() {
    super.initState();
    _teamLeadStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData['username'])
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _teamLeadStream,
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

        return Column(
          children: [
            // Body
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  TeamLeadStudentsPage(
                    username: widget.userData['username'],
                    userData: widget.userData,
                  ),
                  MyStudentsPage(
                    username: widget.userData['username'],
                    userData: widget.userData,
                  ),
                  TeamLeadProfilePage(username: widget.userData['username']),
                ],
              ),
            ),
            // Bottom Navigation
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF512DA8),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'O\'quvchilar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school),
                  label: 'Mening O\'quvchilarim',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
