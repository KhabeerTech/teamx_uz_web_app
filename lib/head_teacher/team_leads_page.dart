import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_lead_details_page.dart';

class TeamLeadsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TeamLeadsPage({
    super.key,
    required this.userData,
  });

  @override
  _TeamLeadsPageState createState() => _TeamLeadsPageState();
}

class _TeamLeadsPageState extends State<TeamLeadsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> teamLeads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamLeads();
  }

  Future<void> _loadTeamLeads() async {
    try {
      final QuerySnapshot teamLeadsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'team_lead')
          .get();

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      List<Map<String, dynamic>> updatedTeamLeads = [];

      for (var doc in teamLeadsSnapshot.docs) {
        final teamLeadData = doc.data() as Map<String, dynamic>;
        final teamLeadId = doc.id;
        final username = teamLeadData['username'] as String?;

        // O'quvchilar sonini olish
        final studentsSnapshot = await _firestore
            .collection('users')
            .where('team_lead_username', isEqualTo: username)
            .get();

        // Bugungi davomat ma'lumotlarini olish
        int presentCount = 0;
        int absentCount = 0;
        int warnedCount = 0;

        if (username != null) {
          for (var studentDoc in studentsSnapshot.docs) {
            final studentId = studentDoc.id;
            final studentData = studentDoc.data();

            // Ogohlantirish olganlar sonini tekshirish
            if (studentData['warned'] == true) {
              warnedCount++;
            }

            // Bugungi davomatni tekshirish
            final attendanceDoc = await _firestore
                .collection('attendance_records')
                .doc(username)
                .collection(dateStr)
                .doc(studentId)
                .get();

            if (attendanceDoc.exists) {
              final attendanceData =
                  attendanceDoc.data() as Map<String, dynamic>;
              if (attendanceData['is_present'] == true) {
                presentCount++;
              } else {
                absentCount++;
              }
            }
          }
        }

        updatedTeamLeads.add({
          'id': teamLeadId,
          ...teamLeadData,
          'total_students': studentsSnapshot.docs.length,
          'present_students': presentCount,
          'absent_students': absentCount,
          'warned_students': warnedCount,
        });
      }

      setState(() {
        teamLeads = updatedTeamLeads;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading team leads: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Team Lead\'lar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teamLeads.length,
              itemBuilder: (context, index) {
                final teamLead = teamLeads[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF512D84),
                      child: Text(
                        ((teamLead['full_name'] as String?) ?? 'N')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title:
                        Text(teamLead['full_name']?.toString() ?? 'Noma\'lum'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Username: ${teamLead['display_username']?.toString() ?? ''}'),
                        Text(
                            'O\'quvchilar soni: ${teamLead['total_students'] ?? 0}'),
                        Text(
                            'Bugun kelganlar: ${teamLead['present_students'] ?? 0}'),
                        Text(
                            'Bugun kelmaganlar: ${teamLead['absent_students'] ?? 0}'),
                        Text(
                            'Ogohlantirilganlar: ${teamLead['warned_students'] ?? 0}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamLeadDetailsPage(
                            teamLeadId: teamLead['id'],
                            teamLeadData: teamLead,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
