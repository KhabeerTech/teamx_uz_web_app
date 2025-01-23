import 'package:flutter/material.dart';
import 'assign_student_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeadTeacherProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HeadTeacherProfilePage({Key? key, required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('region', isEqualTo: userData['region'])
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, studentsSnapshot) {
        int studentCount = 0;
        if (studentsSnapshot.hasData) {
          studentCount = studentsSnapshot.data!.docs.length;
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF512DA8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 50, color: Color(0xFF512DA8)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData['full_name'] ?? 'Nomsiz',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '@${userData['username'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filial holati',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'O\'quvchilar',
                            '$studentCount',
                            Icons.people,
                          ),
                        ),
                        const SizedBox(width: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('region', isEqualTo: userData['region'])
                              .where('role', isEqualTo: 'team_lead')
                              .snapshots(),
                          builder: (context, teamLeadSnapshot) {
                            int teamLeadCount = 0;
                            if (teamLeadSnapshot.hasData) {
                              teamLeadCount =
                                  teamLeadSnapshot.data!.docs.length;
                            }
                            return Expanded(
                              child: _buildStatCard(
                                'Team Lead lar',
                                '$teamLeadCount',
                                Icons.supervisor_account,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      'Filial',
                      userData['region'] ?? 'N/A',
                      Icons.location_city,
                    ),
                    const SizedBox(height: 24),
                    // Center(
                    //   child: ElevatedButton.icon(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF512DA8),
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 32,
                    //         vertical: 16,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => AssignStudentPage(
                    //             userData: userData,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     icon: const Icon(Icons.person_add, color: Colors.white),
                    //     label: const Text(
                    //       'O\'quvchilarni biriktirish',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF512DA8), size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF512DA8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF512DA8), size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
