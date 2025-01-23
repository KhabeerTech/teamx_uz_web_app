import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_lead_students_page.dart';
import 'team_lead_profile_page.dart';

class TeamLeadHomePage extends StatefulWidget {
  final String username;

  const TeamLeadHomePage({Key? key, required this.username}) : super(key: key);

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
        .doc(widget.username)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _teamLeadStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Xatolik yuz berdi'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final teamLeadData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text('Team Lead - ${teamLeadData['full_name']}'),
            backgroundColor: const Color(0xFF512DA8),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // TODO: Implement logout
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              TeamLeadStudentsPage(username: widget.username),
              TeamLeadProfilePage(username: widget.username),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF512DA8),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'O\'quvchilar',
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
        );
      },
    );
  }
}
