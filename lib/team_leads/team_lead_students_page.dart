import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'student_step_page.dart';
import 'student_details_page.dart';
import 'student_category_page.dart';
import 'student_personal_development_page.dart';
import 'status_students_page.dart';

class TeamLeadStudentsPage extends StatefulWidget {
  final String username;
  final Map<String, dynamic> userData;

  const TeamLeadStudentsPage(
      {Key? key, required this.username, required this.userData})
      : super(key: key);

  @override
  _TeamLeadStudentsPageState createState() => _TeamLeadStudentsPageState();
}

class _TeamLeadStudentsPageState extends State<TeamLeadStudentsPage> {
  late Stream<QuerySnapshot> _studentsStream;
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _inactiveStudents = 0;
  int _newStudents = 0;
  double _averageProgress = 0;
  int _attendedStudents = 0;
  int _submitted3Tasks = 0;
  int _submitted2Tasks = 0;
  int _submitted1Task = 0;
  int _submitted0Tasks = 0;
  int _warnedStudents = 0;
  int _absentStudents = 0;
  int _excusedAbsentStudents = 0;
  int _unexcusedAbsentStudents = 0;
  int _todayWarningCount = 0;
  final GlobalKey _containerKey = GlobalKey();
  final List<GlobalKey> _middleCardKeys = List.generate(9, (_) => GlobalKey());
  Size? _maxSize;
  Map<String, int> _attendanceCounts = {
    'present': 0,
    'absent_with_reason': 0,
    'absent_without_reason': 0,
    'steps_0': 0,
    'steps_1': 0,
    'steps_2': 0,
    'steps_3': 0,
  };
  Map<String, int> _statusCounts = {
    'green': 0,
    'yellow': 0,
    'red': 0,
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  String _todayWeekday = '';

  @override
  void initState() {
    super.initState();
    _todayWeekday = _getTodayWeekday();
    _studentsStream = _firestore
        .collection('users')
        .where('team_lead_username', isEqualTo: widget.username)
        .snapshots();
    _loadStatistics();
    _loadAttendanceData();
    _loadStatusCounts();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadAttendanceData();
    });

    // Konteynerlar hajmini o'rnatamiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setContainerSize();
    });
  }

  String _getTodayWeekday() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    // O'zbekcha hafta kunlari
    switch (weekday) {
      case 1:
        return 'dushanba';
      case 2:
        return 'seshanba';
      case 3:
        return 'chorshanba';
      case 4:
        return 'payshanba';
      case 5:
        return 'juma';
      case 6:
        return 'shanba';
      case 7:
        return 'yakshanba';
      default:
        return '';
    }
  }

  // O'quvchi bugun hisoblanadimi tekshirish
  bool _isStudentCountedToday(Map<String, dynamic> studentData) {
    List<dynamic>? attendanceDays =
        studentData['attendance_days'] as List<dynamic>?;
    return attendanceDays?.contains(_todayWeekday) ?? false;
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer ni to'xtatish
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    try {
      // Barcha biriktirilgan o'quvchilarni olish
      final snapshot = await _firestore
          .collection('users')
          .where('team_lead_username', isEqualTo: widget.username)
          .get();

      // Jami o'quvchilar soni - bu team lead ga biriktirilgan barcha o'quvchilar
      setState(() {
        _totalStudents = snapshot.docs.length;
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> _loadAttendanceData() async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      print('Loading attendance for date: $dateStr');

      // Barcha biriktirilgan o'quvchilarni olish
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('team_lead_username', isEqualTo: widget.username)
          .get();

      // Hisoblagichlarni nolga tushirish
      Map<String, int> counts = {
        'present': 0,
        'absent_with_reason': 0,
        'absent_without_reason': 0,
        'steps_0': 0,
        'steps_1': 0,
        'steps_2': 0,
        'steps_3': 0,
      };

      // Har bir o'quvchi uchun bugungi davomatni tekshirish
      for (var studentDoc in studentsSnapshot.docs) {
        // O'quvchi bugun hisoblanadimi tekshirish
        if (!_isStudentCountedToday(
            studentDoc.data() as Map<String, dynamic>)) {
          continue; // Agar bugun hisoblanmasa, keyingi o'quvchiga o'tish
        }

        final studentId = studentDoc.id;
        print('Checking attendance for student: $studentId');

        // O'quvchining bugungi davomati
        final attendanceDoc = await _firestore
            .collection('attendance_records')
            .doc(widget.username)
            .collection(dateStr)
            .doc(studentId)
            .get();

        if (attendanceDoc.exists) {
          final data = attendanceDoc.data() as Map<String, dynamic>;
          print('Found attendance record for $studentId: $data');

          if (data['is_present'] == true) {
            counts['present'] = counts['present']! + 1;

            // Bugun topshirgan qadamlar sonini tekshirish
            int steps = data['steps'] ?? 0;
            print('Steps completed by $studentId today: $steps');

            // Qadamlar soniga qarab kategoriyalarga ajratish
            if (steps >= 3) {
              counts['steps_3'] = counts['steps_3']! + 1;
              print('$studentId added to 3+ steps category');
            } else if (steps == 2) {
              counts['steps_2'] = counts['steps_2']! + 1;
              print('$studentId added to 2 steps category');
            } else if (steps == 1) {
              counts['steps_1'] = counts['steps_1']! + 1;
              print('$studentId added to 1 step category');
            } else {
              counts['steps_0'] = counts['steps_0']! + 1;
              print('$studentId added to 0 steps category');
            }
          } else {
            String absenceReason = data['absence_reason'] ?? '';
            if (absenceReason == 'Sababli') {
              counts['absent_with_reason'] = counts['absent_with_reason']! + 1;
            } else {
              counts['absent_without_reason'] =
                  counts['absent_without_reason']! + 1;
            }
          }
        } else {
          // Agar davomat belgilanmagan bo'lsa, 0 ta topshirgan hisoblanadi
          counts['steps_0'] = counts['steps_0']! + 1;
          print(
              'No attendance record found for $studentId, counted as 0 steps');
        }
      }

      print('Final attendance counts: $counts');

      setState(() {
        _attendanceCounts = counts;
        // UI dagi o'zgaruvchilarni yangilash
        _submitted3Tasks = counts['steps_3'] ?? 0;
        _submitted2Tasks = counts['steps_2'] ?? 0;
        _submitted1Task = counts['steps_1'] ?? 0;
        _submitted0Tasks = counts['steps_0'] ?? 0;
        _attendedStudents = counts['present'] ?? 0;
        _excusedAbsentStudents = counts['absent_with_reason'] ?? 0;
        _unexcusedAbsentStudents = counts['absent_without_reason'] ?? 0;
        _absentStudents = (_excusedAbsentStudents + _unexcusedAbsentStudents);
      });
    } catch (e, stackTrace) {
      print('Error loading attendance data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadStatusCounts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('team_lead_username', isEqualTo: widget.username)
          .get();

      Map<String, int> counts = {
        'green': 0,
        'yellow': 0,
        'red': 0,
      };

      for (var doc in snapshot.docs) {
        String status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
        if (counts.containsKey(status)) {
          counts[status] = counts[status]! + 1;
        }
      }

      setState(() {
        _statusCounts = counts;
      });
    } catch (e) {
      print('Error loading status counts: $e');
    }
  }

  Future<int> _getTodayWarningCount() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      // Bugungi attendance records'ni olish
      final QuerySnapshot attendanceSnapshot = await _firestore
          .collection('attendance_records')
          .doc(widget.username)
          .collection(dateStr)
          .get();

      // Ogohlantirish olgan o'quvchilarni sanash
      int warningCount = 0;
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['warned'] is int && data['warned'] > 0) {
          warningCount++;
        }
      }
      return warningCount;
    } catch (e) {
      print('Error getting today warning count: $e');
      return 0;
    }
  }

  void _setContainerSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ekran o'lchamiga qarab konteyner hajmini hisoblaymiz
    double containerWidth = screenWidth * 0.25; // Ekran enining 25%
    double containerHeight = screenHeight * 0.25; // Ekran bo'yining 25%

    // Minimal hajm
    containerWidth = containerWidth.clamp(200.0, 300.0);
    containerHeight = containerHeight.clamp(180.0, 250.0);

    setState(() {
      _maxSize = Size(containerWidth, containerHeight);
    });
  }

  void _updateMaxSize() {
    Size maxSize = Size.zero;

    // Barcha konteynerlarni tekshirib, eng kattasini topamiz
    for (var key in _middleCardKeys) {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final size = renderBox.size;
        maxSize = Size(
          size.width > maxSize.width ? size.width : maxSize.width,
          size.height > maxSize.height ? size.height : maxSize.height,
        );
      }
    }

    // Agar yangi hajm topilgan bo'lsa, o'rnatamiz
    if (maxSize != Size.zero && maxSize != _maxSize) {
      setState(() {
        _maxSize = maxSize;
      });
    }
  }

  void _navigateToStudentDetails(
      String studentId, Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailsPage(
          studentId: studentId,
          studentName: student['full_name'] ?? 'Noma\'lum',
          studentUsername: student['username'] ?? '',
          userData: widget.userData,
        ),
      ),
    ).then((_) => _loadStatistics());
  }

  void _navigateToStudentCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentCategoryPage(
          title: _getCategoryName(category),
          category: category,
          teamLeadUsername: widget.username,
          userData: widget.userData,
        ),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'present':
        return 'Kelgan O\'quvchilar';
      case 'steps_3':
        return '3 ta Qadam Bajarilganlar';
      case 'steps_2':
        return '2 ta Qadam Bajarilganlar';
      case 'steps_1':
        return '1 ta Qadam Bajarilganlar';
      case 'steps_0':
        return '0 ta Qadam Bajarilganlar';
      case 'absent':
        return 'Kelmagan O\'quvchilar';
      case 'excused_absent':
        return 'Sababli Kelmaganlar';
      case 'unexcused_absent':
        return 'Sababsiz Kelmaganlar';
      default:
        return '';
    }
  }

  void _navigateToStatusStudents(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusStudentsPage(
          username: widget.username,
          status: status,
          statusTitle: status == 'green'
              ? 'Yaxshi o\'quvchilar'
              : status == 'yellow'
                  ? 'O\'rta o\'quvchilar'
                  : 'Yomon o\'quvchilar',
          userData: widget.userData,
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 24, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      String title, String value, IconData icon, Color color, String subtitle,
      {String? category}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (category != null) {
            _navigateToStudentCategory(category);
          }
        },
        child: Container(
          width: _maxSize?.width ?? 250,
          height: _maxSize?.height ?? 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 24, color: color),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getMiddleCardIndex(String category) {
    switch (category) {
      case 'present':
        return 0;
      case 'steps_3':
        return 1;
      case 'steps_2':
        return 2;
      case 'steps_1':
        return 3;
      case 'steps_0':
        return 4;
      case 'absent':
        return 5;
      case 'excused_absent':
        return 6;
      case 'unexcused_absent':
        return 7;
      case 'warned':
        return 8;
      default:
        return 0;
    }
  }

  Future<void> _showWarnedStudentsDialog() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      // Bugungi attendance records'ni olish
      final QuerySnapshot attendanceSnapshot = await _firestore
          .collection('attendance_records')
          .doc(widget.username)
          .collection(dateStr)
          .get();

      // Bugun ogohlantirish olgan o'quvchilar ma'lumotlarini yig'ish
      final List<Map<String, dynamic>> warnedStudents = [];
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['warned'] is int && data['warned'] > 0) {
          // O'quvchi ma'lumotlarini olish
          final studentDoc =
              await _firestore.collection('users').doc(doc.id).get();

          if (studentDoc.exists) {
            final studentData = studentDoc.data() as Map<String, dynamic>;
            warnedStudents.add({
              'name': studentData['full_name'] ?? 'Noma\'lum',
              'username': doc.id,
              'warning_count': data['warned'],
              'total_warnings': studentData['warned'] ?? 0,
              'warning_time': data['warning_time'],
              'warning_reason': data['warning_reason'] ?? '',
            });
          }
        }
      }

      if (!mounted) return;

      // Dialog ko'rsatish
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                'Bugun ogohlantirish olganlar',
                style: TextStyle(color: Color(0xFF512DA8)),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: warnedStudents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Bugun hech kim ogohlantirish olmagan',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: warnedStudents.length,
                    itemBuilder: (context, index) {
                      final student = warnedStudents[index];
                      final warningTime = student['warning_time'] != null
                          ? (student['warning_time'] as Timestamp).toDate()
                          : null;

                      return ListTile(
                        title: Text(student['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (warningTime != null)
                              Text(
                                'Vaqt: ${warningTime.hour.toString().padLeft(2, '0')}:${warningTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 12),
                              ),
                            if (student['warning_reason']?.isNotEmpty ?? false)
                              Text(
                                'Sabab: ${student['warning_reason']}',
                                style: TextStyle(fontSize: 12),
                              ),
                            Text(
                              'Jami ogohlantirishlar: #${student['total_warnings']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bugun: #${student['warning_count']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToStudentDetails(student['username'], {
                            'full_name': student['name'],
                            'username': student['username'],
                            'warned': student['total_warnings'],
                            'warning_time': student['warning_time'],
                            'warning_reason': student['warning_reason'],
                          });
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Yopish'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error showing warned students: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xatolik yuz berdi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.userData['full_name']} ning o\'quvchilari',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _studentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Xatolik yuz berdi'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allStudents = snapshot.data!.docs;
          // Bugun hisoblanadigan o'quvchilarni filtrlash
          final todayStudents = allStudents.where((doc) {
            final studentData = doc.data() as Map<String, dynamic>;
            return _isStudentCountedToday(studentData);
          }).toList();

          if (todayStudents.isEmpty) {
            return const Center(child: Text('Bugun uchun o\'quvchilar yo\'q'));
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 20,
                  vertical: isSmallScreen ? 15 : 30,
                ),
                margin: EdgeInsets.all(isSmallScreen ? 10 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Jami\nO\'quvchilar',
                        _totalStudents.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      GestureDetector(
                        onTap: () => _navigateToStatusStudents('green'),
                        child: _buildStatCard(
                          'Yaxshi\nO\'quvchilar',
                          _statusCounts['green'].toString(),
                          Icons.check_circle,
                          Colors.green.shade600,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      GestureDetector(
                        onTap: () => _navigateToStatusStudents('yellow'),
                        child: _buildStatCard(
                          'O\'rta\nO\'quvchilar',
                          _statusCounts['yellow'].toString(),
                          Icons.warning,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      GestureDetector(
                        onTap: () => _navigateToStatusStudents('red'),
                        child: _buildStatCard(
                          'Yomon\nO\'quvchilar',
                          _statusCounts['red'].toString(),
                          Icons.error,
                          Colors.red.shade600,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildStatCard(
                        'Qora\nO\'quvchilar',
                        '0',
                        Icons.block,
                        Colors.grey.shade800,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 20,
                  vertical: isSmallScreen ? 15 : 30,
                ),
                margin: EdgeInsets.all(isSmallScreen ? 10 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildDetailCard(
                        'Kelgan O\'quvchilar',
                        _attendedStudents.toString(),
                        Icons.how_to_reg,
                        Colors.green,
                        'Bugun darsga kelgan o\'quvchilar soni',
                        category: 'present',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        '3 ta Qadam Bajarilganlar',
                        _submitted3Tasks.toString(),
                        Icons.assignment_turned_in,
                        Colors.blue,
                        'Barcha qadamlarni bajargan o\'quvchilar',
                        category: 'steps_3',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        '2 ta Qadam Bajarilganlar',
                        _submitted2Tasks.toString(),
                        Icons.assignment,
                        Colors.orange,
                        '2 ta qadamlarni bajargan o\'quvchilar',
                        category: 'steps_2',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        '1 ta Qadam Bajarilganlar',
                        _submitted1Task.toString(),
                        Icons.assignment_late,
                        Colors.amber,
                        '1 ta qadamlarni bajargan o\'quvchilar',
                        category: 'steps_1',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        '0 ta Qadam Bajarilganlar',
                        _submitted0Tasks.toString(),
                        Icons.assignment_ind,
                        Colors.red,
                        'Hech qanday qadamlarni bajarmagan o\'quvchilar',
                        category: 'steps_0',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      FutureBuilder<int>(
                        future: _getTodayWarningCount(),
                        builder: (context, snapshot) {
                          return _buildDetailCard(
                            'Ogohlantirish\nOlganlar',
                            snapshot.data?.toString() ?? '0',
                            Icons.warning_amber,
                            Colors.deepOrange,
                            'Bugun ogohlantirish olgan o\'quvchilar',
                            category: 'warned',
                          );
                        },
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        'Kelmagan O\'quvchilar',
                        _absentStudents.toString(),
                        Icons.person_off,
                        Colors.grey,
                        'Bugun darsga kelmagan o\'quvchilar soni',
                        category: 'absent',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        'Sababli Kelmaganlar',
                        _excusedAbsentStudents.toString(),
                        Icons.sick,
                        Colors.purple,
                        'Sababli darsga kelmagan o\'quvchilar',
                        category: 'excused_absent',
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 20),
                      _buildDetailCard(
                        'Sababsiz Kelmaganlar',
                        _unexcusedAbsentStudents.toString(),
                        Icons.person_remove,
                        Colors.brown,
                        'Sababsiz darsga kelmagan o\'quvchilar',
                        category: 'unexcused_absent',
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loadAttendanceData();
                    });
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    'Yangilash',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF512DA8),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  itemCount: todayStudents.length,
                  itemBuilder: (context, index) {
                    final student =
                        todayStudents[index].data() as Map<String, dynamic>;
                    final studentId = todayStudents[index].id;
                    final currentStep = student['current_step'] as String?;
                    final lastActive = student['last_active'] as Timestamp?;
                    final isActive = lastActive != null &&
                        DateTime.now().difference(lastActive.toDate()).inDays <=
                            7;

                    return Container(
                      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                      decoration: BoxDecoration(
                        gradient: index.isEven
                            ? const LinearGradient(
                                colors: [Color(0xFF512D84), Color(0xFF7646B8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFF8F0FF), Color(0xFFF0F7FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF512D84).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: index.isEven
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF512D84).withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFF512D84),
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['full_name'] ?? 'Nomsiz',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w500,
                                color: index.isEven
                                    ? Colors.white
                                    : const Color(0xFF512D84),
                              ),
                            ),
                            if (currentStep != null && currentStep.isNotEmpty)
                              Text(
                                'Qadam: $currentStep',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: index.isEven
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sinf: ${student['grade'] ?? 'N/A'} | Tel: ${student['father_phone'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: index.isEven
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                            if (lastActive != null)
                              Text(
                                'Oxirgi faollik: ${lastActive.toDate().toString().substring(0, 16)}',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 13,
                                  color: index.isEven
                                      ? Colors.white60
                                      : (isActive
                                          ? Colors.green
                                          : Colors.orange),
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: index.isEven
                              ? Colors.white60
                              : const Color(0xFF512D84),
                          size: isSmallScreen ? 16 : 20,
                        ),
                        onTap: () {
                          _navigateToStudentDetails(studentId, student);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
