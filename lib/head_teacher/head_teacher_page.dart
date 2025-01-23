import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_team_lead_page.dart';
import 'approve_students_page.dart';
import 'assign_student_page.dart';
import 'head_teacher_profile_page.dart';
import 'team_lead_details_page.dart';
import 'team_lead_assign_page.dart';
import '../team_leads/team_lead_home_page.dart';

class HeadTeacherPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HeadTeacherPage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<HeadTeacherPage> createState() => _HeadTeacherPageState();
}

class _HeadTeacherPageState extends State<HeadTeacherPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('Team Lead lar', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(widget.userData['username'])
            .snapshots(),
        builder: (context, headTeacherSnapshot) {
          if (headTeacherSnapshot.hasError) {
            return Center(child: Text('Xatolik: ${headTeacherSnapshot.error}'));
          }

          if (!headTeacherSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final headTeacherData =
              headTeacherSnapshot.data!.data() as Map<String, dynamic>;

          if (_selectedIndex == 0) {
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'team_lead')
                  .where('region', isEqualTo: headTeacherData['region'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Xatolik yuz berdi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final teamLeads = snapshot.data?.docs ?? [];

                if (teamLeads.isEmpty) {
                  return const Center(
                    child: Text(
                      'Hozircha Team Lead lar yo\'q',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teamLeads.length,
                  itemBuilder: (context, index) {
                    final teamLead =
                        teamLeads[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading:
                            const Icon(Icons.person, color: Color(0xFF512DA8)),
                        title: Text(
                          teamLead['full_name'] ?? 'Nomsiz',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${teamLead['username'] ?? ''}'),
                            Text(
                                'Tel: ${teamLead['phone'] == 'N/A' || teamLead['phone'] == null ? teamLead['father_phone'] ?? 'N/A' : teamLead['phone']}'),
                            Text('Region: ${teamLead['region'] ?? 'N/A'}'),
                          ],
                        ),
                        onTap: () async {
                          // Team lead ma'lumotlarini olish
                          final teamLeadDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(teamLead['username'])
                              .get();

                          if (!mounted) return;

                          if (teamLeadDoc.exists) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamLeadHomePage(
                                  userData: teamLeadDoc.data()!,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            );
          } else if (_selectedIndex == 1) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: AddTeamLeadPage(userData: widget.userData),
            );
          } else if (_selectedIndex == 2) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: AssignStudentPage(userData: widget.userData),
            );
          } else if (_selectedIndex == 3) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ApproveStudentsPage(userData: widget.userData),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: HeadTeacherProfilePage(userData: widget.userData),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Team Lead lar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Team Lead qo\'shish',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind),
            label: 'O\'quvchi biriktirish',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'O\'quvchilarni tasdiqlash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF512DA8),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
