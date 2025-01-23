import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentCategoryPage extends StatefulWidget {
  final String title;
  final String category;
  final String teamLeadUsername;
  final Map<String, dynamic> userData;

  const StudentCategoryPage({
    Key? key,
    required this.title,
    required this.category,
    required this.teamLeadUsername,
    required this.userData,
  }) : super(key: key);

  @override
  State<StudentCategoryPage> createState() => _StudentCategoryPageState();
}

class _StudentCategoryPageState extends State<StudentCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Bugungi hafta kunini olish
      final weekday = now.weekday;
      final todayWeekday = switch (weekday) {
        1 => 'dushanba',
        2 => 'seshanba',
        3 => 'chorshanba',
        4 => 'payshanba',
        5 => 'juma',
        6 => 'shanba',
        7 => 'yakshanba',
        _ => '',
      };

      // Faqat bugungi kunda hisoblanadigan o'quvchilarni olish
      final allStudentsSnapshot = await _firestore
          .collection('users')
          .where('team_lead_username', isEqualTo: widget.teamLeadUsername)
          .where('attendance_days', arrayContains: todayWeekday)
          .get();

      List<Map<String, dynamic>> categoryStudents = [];

      for (var studentDoc in allStudentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final studentId = studentDoc.id;

        // O'quvchining bugungi davomati
        final attendanceDoc = await _firestore
            .collection('attendance_records')
            .doc(widget.teamLeadUsername)
            .collection(dateStr)
            .doc(studentId)
            .get();

        if (attendanceDoc.exists) {
          final data = attendanceDoc.data() as Map<String, dynamic>;
          bool shouldAdd = false;

          switch (widget.category) {
            case 'present':
              shouldAdd = data['is_present'] == true;
              break;
            case 'steps_3':
              shouldAdd =
                  data['is_present'] == true && (data['steps'] ?? 0) >= 3;
              break;
            case 'steps_2':
              shouldAdd =
                  data['is_present'] == true && (data['steps'] ?? 0) == 2;
              break;
            case 'steps_1':
              shouldAdd =
                  data['is_present'] == true && (data['steps'] ?? 0) == 1;
              break;
            case 'steps_0':
              shouldAdd = data['is_present'] == true && (data['steps'] ?? 0) == 0;
              break;
            case 'absent':
              shouldAdd = data['is_present'] == false;
              break;
            case 'excused_absent':
              shouldAdd = data['is_present'] == false &&
                  data['absence_reason'] == 'Sababli';
              break;
            case 'unexcused_absent':
              shouldAdd = data['is_present'] == false &&
                  (data['absence_reason'] == null ||
                      data['absence_reason'] != 'Sababli');
              break;
            case 'warned':
              shouldAdd = data['warned'] != null && data['warned'] > 0;
              break;
          }

          if (shouldAdd) {
            categoryStudents.add({
              ...studentData,
              'id': studentId,
              'attendance_data': data,
            });
          }
        } else if (widget.category == 'steps_0') {
          // Agar davomat belgilanmagan bo'lsa, 0 ta qadam bajargan deb hisoblaymiz
          categoryStudents.add({
            ...studentData,
            'id': studentId,
            'attendance_data': {'is_present': true, 'steps': 0},
          });
        } else if (widget.category == 'unexcused_absent') {
          // Agar davomat belgilanmagan bo'lsa, sababsiz kelmagan deb hisoblaymiz
          categoryStudents.add({
            ...studentData,
            'id': studentId,
            'attendance_data': {'is_present': false},
          });
        }
      }

      setState(() {
        students = categoryStudents;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading students: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF512DA8),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text(
                    'Hozircha o\'quvchilar yo\'q',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final warningTime =
                        student['attendance_data']['warning_time'] != null
                            ? (student['attendance_data']['warning_time']
                                    as Timestamp)
                                .toDate()
                            : null;
                    final isReported =
                        student['attendance_data']['is_present'] ?? true;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isReported ? Colors.white : Colors.red[50],
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF512DA8),
                          child: Text(
                            student['full_name']
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'N',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          student['full_name'] ?? 'Nomsiz',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.category == 'warned') ...[
                              if (warningTime != null)
                                Text(
                                  'Vaqt: ${warningTime.hour.toString().padLeft(2, '0')}:${warningTime.minute.toString().padLeft(2, '0')}',
                                ),
                              Text(
                                  'Sabab: ${student['attendance_data']['warning_reason']}'),
                              Text(
                                'Bugungi ogohlantirishlar: #${student['attendance_data']['warned'] ?? 0}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              Text('Sinf: ${student['grade'] ?? 'N/A'}'),
                              Text('Telefon: ${student['phone'] ?? 'N/A'}'),
                              if (!isReported)
                                Text(
                                  'Bugun hisobotda yo\'q!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                    'Bajarilgan qadamlar: ${student['attendance_data']['steps']}'),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
