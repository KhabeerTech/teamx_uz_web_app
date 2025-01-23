import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MyStudentsPage extends StatefulWidget {
  final String username;
  final Map<String, dynamic> userData;

  const MyStudentsPage({
    Key? key,
    required this.username,
    required this.userData,
  }) : super(key: key);

  @override
  State<MyStudentsPage> createState() => _MyStudentsPageState();
}

class _MyStudentsPageState extends State<MyStudentsPage> {
  late Stream<QuerySnapshot> _studentsStream;
  TimeOfDay? _selectedTime;
  String _timeString = '';

  @override
  void initState() {
    super.initState();
    _studentsStream = FirebaseFirestore.instance
        .collection('users')
        .where('team_lead_username', isEqualTo: widget.username)
        .snapshots();
  }

  Color _getStepColor(int step) {
    switch (step) {
      case 3:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _formatAttendanceDays(List<dynamic> days) {
    if (days.isEmpty || days.length != 3) return 'Belgilanmagan';

    print('Attendance days: $days'); // Debug qilish uchun

    final dayNames = days.map((day) {
      final name = switch (day) {
        'dushanba' => 'Du',
        'seshanba' => 'Se',
        'chorshanba' => 'Chor',
        'payshanba' => 'Pay',
        'juma' => 'Ju',
        'shanba' => 'Sha',
        'yakshanba' => 'Yak',
        _ => day.toString(),
      };
      print('Day: $day -> $name'); // Debug qilish uchun
      return name;
    }).toList();

    print('Formatted days: $dayNames'); // Debug qilish uchun
    return dayNames.join(' va ');
  }

  void _showColorPicker(BuildContext context, String studentId) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('O\'quvchi holatini tanlang'),
        message: const Text('Rangni tanlang'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              _updateStudentStatus(studentId, 'green');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Yaxshi'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _updateStudentStatus(studentId, 'yellow');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('O\'rta'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _updateStudentStatus(studentId, 'red');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Yomon'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Bekor qilish'),
        ),
      ),
    );
  }

  Future<void> _updateStudentStatus(String studentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({'status': status});
    } catch (e) {
      debugPrint('Error updating student status: $e');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        // Format time as HH:mm
        _timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mening O\'quvchilarim',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF512DA8)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF512DA8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF512DA8).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _timeString.isEmpty ? 'Vaqtni tanlang' : _timeString,
                      style: TextStyle(
                        color: _timeString.isEmpty
                            ? Colors.grey
                            : const Color(0xFF512DA8),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _studentsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Xatolik yuz berdi'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final students = snapshot.data!.docs;

              if (students.isEmpty) {
                return const Center(child: Text('O\'quvchilar topilmadi'));
              }

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index].data() as Map<String, dynamic>;
                    final steps = student['steps'] as int? ?? 0;
                    final stepColor = _getStepColor(steps);
                    final attendanceDays =
                        student['attendance_days'] as List<dynamic>? ?? [];
                    final status = student['status'];

                    print(
                        'Student: ${student['full_name']}, Days: $attendanceDays'); // Debug qilish uchun

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: stepColor.withOpacity(0.2),
                          child: Icon(Icons.person, color: stepColor),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    student['full_name'] ?? 'Nomsiz',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () =>
                                        _showColorPicker(context, students[index].id),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width < 600
                                          ? 20
                                          : 30,
                                      height: MediaQuery.of(context).size.width < 600
                                          ? 20
                                          : 30,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: MediaQuery.of(context).size.width < 600
                                              ? 1
                                              : 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width < 600 ? 5 : 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: stepColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$steps-qadam',
                                style: TextStyle(
                                  color: stepColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sinf: ${student['grade'] ?? 'N/A'}'),
                            Text('Tel: ${student['father_phone'] ?? 'N/A'}'),
                            Text(
                              'Kelish kunlari: ${_formatAttendanceDays(attendanceDays)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
