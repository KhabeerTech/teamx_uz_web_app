import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamLeadDetailsPage extends StatefulWidget {
  final String teamLeadId;
  final Map<String, dynamic> teamLeadData;

  const TeamLeadDetailsPage({
    super.key,
    required this.teamLeadId,
    required this.teamLeadData,
  });

  @override
  _TeamLeadDetailsPageState createState() => _TeamLeadDetailsPageState();
}

class _TeamLeadDetailsPageState extends State<TeamLeadDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic> todayStats = {
    'totalStudents': 0,
    'presentStudents': 0,
    'warningStudents': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      // Bugungi sana
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // O'quvchilar ro'yxatini olish
      final QuerySnapshot studentsSnapshot = await _firestore
          .collection('users')
          .where('team_lead', isEqualTo: widget.teamLeadId)
          .get();

      // Bugungi attendance records
      final attendanceSnapshot = await _firestore
          .collection('attendance_records')
          .doc(widget.teamLeadData['username'])
          .collection(dateStr)
          .get();

      // Attendance ma'lumotlarini map qilish
      final attendanceMap = {
        for (var doc in attendanceSnapshot.docs) doc.id: doc.data()
      };

      // O'quvchilar ma'lumotlarini to'ldirish
      final studentsList = studentsSnapshot.docs.map((doc) {
        final studentData = doc.data() as Map<String, dynamic>;
        final attendance = attendanceMap[studentData['username']] ?? {};

        return {
          'id': doc.id,
          ...studentData,
          'attendance': attendance,
        };
      }).toList();

      // Statistikani hisoblash
      int present = 0;
      int warnings = 0;

      for (var student in studentsList) {
        if (student['attendance']['steps'] != null &&
            student['attendance']['steps'] > 0) {
          present++;
        }
        if (student['attendance']['warning'] == true) {
          warnings++;
        }
      }

      setState(() {
        students = studentsList;
        todayStats = {
          'totalStudents': studentsList.length,
          'presentStudents': present,
          'warningStudents': warnings,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error loading students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
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
        title: Text(
          widget.teamLeadData['name'] ?? '',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudents,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Jami o\'quvchilar',
                            todayStats['totalStudents'].toString(),
                            const Color(0xFF512D84),
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            'Bugun kelganlar',
                            todayStats['presentStudents'].toString(),
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            'Ogohlantirishlar',
                            todayStats['warningStudents'].toString(),
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final attendance = student['attendance'];
                        final hasAttendance = attendance['steps'] != null &&
                            attendance['steps'] > 0;
                        final hasWarning = attendance['warning'] == true;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: hasAttendance
                                  ? Colors.green
                                  : hasWarning
                                      ? Colors.red
                                      : Colors.grey,
                              child: Text(
                                (student['name'] as String)
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(student['name'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Username: ${student['username'] ?? ''}'),
                                if (hasAttendance)
                                  Text(
                                      'Bugungi qadamlar: ${attendance['steps']}'),
                                if (hasWarning)
                                  const Text(
                                    'Ogohlantirish olgan',
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
