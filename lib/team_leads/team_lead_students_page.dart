import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_step_page.dart';
import 'student_details_page.dart';

class TeamLeadStudentsPage extends StatefulWidget {
  final String username;

  const TeamLeadStudentsPage({Key? key, required this.username})
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
  final GlobalKey _containerKey = GlobalKey();
  Size? _maxSize;

  @override
  void initState() {
    super.initState();
    _studentsStream = FirebaseFirestore.instance
        .collection('users')
        .where('team_lead_username', isEqualTo: widget.username)
        .snapshots();
    _loadStatistics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMaxSize();
    });
  }

  Future<void> _loadStatistics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('team_lead_username', isEqualTo: widget.username)
          .get();

      int total = snapshot.docs.length;
      int active = 0;
      int inactive = 0;
      int newOnes = 0;
      int withStep = 0;
      int attended = 0;
      int submitted3Tasks = 0;
      int submitted2Tasks = 0;
      int submitted1Task = 0;
      int submitted0Tasks = 0;
      int warned = 0;
      int absent = 0;
      int excusedAbsent = 0;
      int unexcusedAbsent = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lastActive = data['last_active'] as Timestamp?;
        final currentStep = data['current_step'] as String?;
        final attendance = data['attendance'] as String?;
        final tasks = data['tasks'] as Map<String, dynamic>?;
        final warnedStatus = data['warned'] as bool?;
        final excusedAbsentStatus = data['excused_absent'] as bool?;

        if (lastActive != null) {
          final difference = DateTime.now().difference(lastActive.toDate());
          if (difference.inDays <= 7) {
            active++;
          } else {
            inactive++;
          }
        } else {
          newOnes++;
        }

        if (currentStep != null && currentStep.isNotEmpty) {
          withStep++;
        }

        if (attendance == 'attended') {
          attended++;
        } else if (attendance == 'absent') {
          absent++;
          if (excusedAbsentStatus ?? false) {
            excusedAbsent++;
          } else {
            unexcusedAbsent++;
          }
        }

        if (tasks != null) {
          int completedTasks = 0;
          tasks.forEach((key, value) {
            if (value as bool) {
              completedTasks++;
            }
          });

          if (completedTasks == 3) {
            submitted3Tasks++;
          } else if (completedTasks == 2) {
            submitted2Tasks++;
          } else if (completedTasks == 1) {
            submitted1Task++;
          } else {
            submitted0Tasks++;
          }
        }

        if (warnedStatus ?? false) {
          warned++;
        }
      }

      setState(() {
        _totalStudents = total;
        _activeStudents = active;
        _inactiveStudents = inactive;
        _newStudents = newOnes;
        _averageProgress = total > 0 ? (withStep / total) * 100 : 0;
        _attendedStudents = attended;
        _submitted3Tasks = submitted3Tasks;
        _submitted2Tasks = submitted2Tasks;
        _submitted1Task = submitted1Task;
        _submitted0Tasks = submitted0Tasks;
        _warnedStudents = warned;
        _absentStudents = absent;
        _excusedAbsentStudents = excusedAbsent;
        _unexcusedAbsentStudents = unexcusedAbsent;
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  void _updateMaxSize() {
    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _maxSize = renderBox.size;
      });
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 1),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double animValue, child) {
          return Transform.rotate(
            angle: animValue * 2 * 3.14159,
            child: Container(
              key: title == "3 ta Topshiriq Topshirganlar" ? _containerKey : null,
              width: _maxSize?.width,
              height: _maxSize?.height,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: animValue * 2,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      width: _maxSize?.width,
      height: _maxSize?.height,
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
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

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
                _buildStatCard(
                  'Yashil\nO\'quvchilar',
                  '0',
                  Icons.check_circle,
                  Colors.green.shade600,
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildStatCard(
                  'Sariq\nO\'quvchilar',
                  '0',
                  Icons.warning,
                  Colors.orange,
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildStatCard(
                  'Qizil\nO\'quvchilar',
                  '0',
                  Icons.error,
                  Colors.red.shade600,
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
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  '3 ta Topshiriq Topshirganlar',
                  _submitted3Tasks.toString(),
                  Icons.assignment_turned_in,
                  Colors.blue,
                  'Barcha topshiriqlarni topshirgan o\'quvchilar',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  '2 ta Topshiriq Topshirganlar',
                  _submitted2Tasks.toString(),
                  Icons.assignment,
                  Colors.orange,
                  '2 ta topshiriqni topshirgan o\'quvchilar',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  '1 ta Topshiriq Topshirganlar',
                  _submitted1Task.toString(),
                  Icons.assignment_late,
                  Colors.amber,
                  '1 ta topshiriqni topshirgan o\'quvchilar',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  '0 ta Topshiriq Topshirganlar',
                  _submitted0Tasks.toString(),
                  Icons.assignment_ind,
                  Colors.red,
                  'Hech qanday topshiriq topshirmagan o\'quvchilar',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  'Ogohlantirish Olganlar',
                  _warnedStudents.toString(),
                  Icons.warning,
                  Colors.deepOrange,
                  'Ogohlantirish olgan o\'quvchilar soni',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  'Kelmagan O\'quvchilar',
                  _absentStudents.toString(),
                  Icons.person_off,
                  Colors.grey,
                  'Bugun darsga kelmagan o\'quvchilar soni',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  'Sababli Kelmaganlar',
                  _excusedAbsentStudents.toString(),
                  Icons.sick,
                  Colors.purple,
                  'Sababli darsga kelmagan o\'quvchilar',
                ),
                SizedBox(width: isSmallScreen ? 10 : 20),
                _buildDetailCard(
                  'Sababsiz Kelmaganlar',
                  _unexcusedAbsentStudents.toString(),
                  Icons.person_remove,
                  Colors.brown,
                  'Sababsiz darsga kelmagan o\'quvchilar',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _studentsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Xatolik yuz berdi'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final students = snapshot.data!.docs;

              if (students.isEmpty) {
                return const Center(
                  child: Text('Hozircha o\'quvchilar yo\'q'),
                );
              }

              return Container(
                margin: EdgeInsets.all(isSmallScreen ? 10 : 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF8F0FF),
                      Color(0xFFF0F7FF),
                      Color(0xFFF8F0FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF512D84).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF512DA8),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'O\'quvchilar ro\'yxati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Jami: ${students.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index].data() as Map<String, dynamic>;
                          final studentId = students[index].id;
                          final currentStep = student['current_step'] as String?;
                          final lastActive = student['last_active'] as Timestamp?;
                          final isActive = lastActive != null &&
                              DateTime.now().difference(lastActive.toDate()).inDays <= 7;

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
                                  color: index.isEven ? Colors.white : const Color(0xFF512D84),
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
                                      color: index.isEven ? Colors.white : const Color(0xFF512D84),
                                    ),
                                  ),
                                  if (currentStep != null && currentStep.isNotEmpty)
                                    Text(
                                      'Qadam: $currentStep',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                        color: index.isEven ? Colors.white70 : Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sinf: ${student['grade'] ?? 'N/A'} | Tel: ${student['phone'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: index.isEven ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                  if (lastActive != null)
                                    Text(
                                      'Oxirgi faollik: ${lastActive.toDate().toString().substring(0, 16)}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 13,
                                        color: index.isEven ? Colors.white60 : (isActive ? Colors.green : Colors.orange),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: index.isEven ? Colors.white60 : const Color(0xFF512D84),
                                size: isSmallScreen ? 16 : 20,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailsPage(
                                      studentId: studentId,
                                      studentName: student['full_name'] ?? 'Nomsiz',
                                    ),
                                  ),
                                ).then((_) => _loadStatistics());
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
