import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const StatisticsPage({
    super.key,
    required this.userData,
  });

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  int totalTeamLeads = 0;
  int totalStudents = 0;
  int totalAttendance = 0;
  int totalWarnings = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      // Team Lead'lar sonini olish
      final teamLeadsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'team_lead')
          .get();
      totalTeamLeads = teamLeadsSnapshot.docs.length;

      // O'quvchilar sonini olish
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      totalStudents = studentsSnapshot.docs.length;

      // Bugungi sana uchun attendance va warning'larni olish
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      int attendanceCount = 0;
      int warningsCount = 0;

      for (var teamLead in teamLeadsSnapshot.docs) {
        final attendanceSnapshot = await _firestore
            .collection('attendance_records')
            .doc(teamLead.id)
            .collection(dateStr)
            .get();

        for (var doc in attendanceSnapshot.docs) {
          final data = doc.data();
          if (data['steps'] != null && data['steps'] > 0) {
            attendanceCount++;
          }
          if (data['warning'] == true) {
            warningsCount++;
          }
        }
      }

      setState(() {
        totalAttendance = attendanceCount;
        totalWarnings = warningsCount;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF512D84),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF512D84),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Statistika',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatCard(
                    'Team Lead\'lar',
                    totalTeamLeads,
                    Icons.people,
                  ),
                  _buildStatCard(
                    'O\'quvchilar',
                    totalStudents,
                    Icons.school,
                  ),
                  _buildStatCard(
                    'Bugungi kelganlar',
                    totalAttendance,
                    Icons.check_circle,
                  ),
                  _buildStatCard(
                    'Bugungi ogohlantirishlar',
                    totalWarnings,
                    Icons.warning,
                  ),
                ],
              ),
            ),
    );
  }
}
