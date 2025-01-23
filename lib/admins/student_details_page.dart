import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsPage extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> userData;

  const StudentDetailsPage({
    Key? key,
    required this.studentId,
    required this.userData,
  }) : super(key: key);

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String?> _selectedDays = List.filled(3, null);

  final List<String> _weekDays = [
    'dushanba',
    'seshanba',
    'chorshanba',
    'payshanba',
    'juma',
    'shanba',
    'yakshanba',
  ];

  @override
  void initState() {
    super.initState();
    final attendanceDays = widget.userData['attendance_days'] as List<dynamic>?;
    if (attendanceDays != null) {
      for (int i = 0; i < attendanceDays.length && i < 3; i++) {
        _selectedDays[i] = attendanceDays[i].toString();
      }
    }
  }

  Future<void> _updateDays() async {
    try {
      final List<String> days =
          _selectedDays.where((day) => day != null).map((day) => day!).toList();
      await _firestore.collection('users').doc(widget.studentId).update({
        'attendance_days': days,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelish kunlari yangilandi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> userData) {
    final motherPhoneController =
        TextEditingController(text: userData['mother_phone']);
    final fatherPhoneController =
        TextEditingController(text: userData['father_phone']);
    final regionController = TextEditingController(text: userData['region']);
    final schoolController =
        TextEditingController(text: userData['school_number']);
    final gradeController =
        TextEditingController(text: userData['grade']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ma\'lumotlarni tahrirlash'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: motherPhoneController,
                decoration:
                    const InputDecoration(labelText: 'Onasining telefoni'),
              ),
              TextField(
                controller: fatherPhoneController,
                decoration:
                    const InputDecoration(labelText: 'Otasining telefoni'),
              ),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(labelText: 'Manzil'),
              ),
              TextField(
                controller: schoolController,
                decoration: const InputDecoration(labelText: 'Maktab'),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(labelText: 'Sinf'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore
                    .collection('users')
                    .doc(widget.studentId)
                    .update({
                  'mother_phone': motherPhoneController.text,
                  'father_phone': fatherPhoneController.text,
                  'region': regionController.text,
                  'school_number': schoolController.text,
                  'grade': int.tryParse(gradeController.text),
                });
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ma\'lumotlar yangilandi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Xatolik: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('O\'quvchi ma\'lumotlari',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(widget.userData);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('users').doc(widget.studentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              snapshot.data?.data() as Map<String, dynamic>? ?? widget.userData;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with student info
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF512DA8), Color(0xFF673AB7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFF512DA8),
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            userData['full_name'] ?? 'Noma\'lum',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '@${userData['username'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Attendance Days Card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.purple.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF512DA8)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF512DA8),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Kelish kunlari',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF512DA8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              for (int i = 0; i < 3; i++) ...[
                                _buildDaySelector(
                                  'Kun ${i + 1}',
                                  _selectedDays[i],
                                  (value) {
                                    setState(() => _selectedDays[i] = value);
                                    _updateDays();
                                  },
                                ),
                                if (i < 2) const SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contact Info Card
                      _buildInfoCard(
                        'Aloqa ma\'lumotlari',
                        Icons.phone,
                        [
                          _buildInfoTile('Oyisining telefon raqami',
                              userData['mother_phone'] ?? 'Kiritilmagan'),
                          _buildInfoTile('Otasining telefon raqami',
                              userData['father_phone'] ?? 'Kiritilmagan'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Location Info Card
                      _buildInfoCard(
                        'Manzil',
                        Icons.location_on,
                        [
                          _buildInfoTile(
                              'Manzil', userData['region'] ?? 'Kiritilmagan'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // School Info Card
                      _buildInfoCard(
                        'Ta\'lim',
                        Icons.school,
                        [
                          _buildInfoTile('Maktab',
                              userData['school_number'] ?? 'Kiritilmagan'),
                          _buildInfoTile('Sinf',
                              userData['grade']?.toString() ?? 'Kiritilmagan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 8,
      shadowColor: Colors.purple.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF512DA8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF512DA8),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF512DA8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(
      String label, String? selectedDay, Function(String?) onChanged) {
    // Boshqa tanlangan kunlarni olish (joriy tanlangan kundan tashqari)
    final otherSelectedDays = _selectedDays
        .where((day) => day != null && day != selectedDay)
        .toList();

    // Mavjud kunlar ro'yxatini yaratish
    final availableDays = [
      if (selectedDay != null) selectedDay,
      ..._weekDays.where(
          (day) => !otherSelectedDays.contains(day) && day != selectedDay),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF512DA8).withOpacity(0.2), width: 2),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDay,
          hint: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_circle,
            color: Color(0xFF512DA8),
          ),
          items: availableDays.map((String day) {
            return DropdownMenuItem<String>(
              value: day,
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF512DA8),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF512DA8),
            ),
          ),
        ],
      ),
    );
  }
}
