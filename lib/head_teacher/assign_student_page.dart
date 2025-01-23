import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_lead_assign_page.dart';

class AssignStudentPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AssignStudentPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Team Lead tanlash',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'team_lead')
            .where('region', isEqualTo: userData['region'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
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
              final teamLead = teamLeads[index].data() as Map<String, dynamic>;
              teamLead['id'] = teamLeads[index].id;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF512DA8),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamLeadAssignPage(
                          headTeacherData: userData,
                          teamLeadData: teamLead,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
