import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPersonalDevelopmentPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentUsername;
  final Map<String, dynamic> userData;

  const StudentPersonalDevelopmentPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentUsername,
    required this.userData,
  });

  @override
  State<StudentPersonalDevelopmentPage> createState() =>
      _StudentPersonalDevelopmentPageState();
}

class _StudentPersonalDevelopmentPageState
    extends State<StudentPersonalDevelopmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _totalSteps = 0;
  int _todaySteps = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      // Users kolleksiyasidan umumiy qadamlarni olish
      final userDoc = await _firestore
          .collection('users')
          .doc(widget.studentUsername)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _totalSteps = userData['pdsteps'] ?? 0;
        });
      }

      // Attendance_records dan bugungi qadamlarni olish
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final attendanceDoc = await _firestore
          .collection('attendance_records')
          .doc(widget.userData['username'])
          .collection(dateStr)
          .doc(widget.studentUsername)
          .get();

      if (attendanceDoc.exists) {
        final attendanceData = attendanceDoc.data() as Map<String, dynamic>;
        setState(() {
          _todaySteps = attendanceData['pdsteps'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  Future<void> _updateSteps(int stepCount) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Users kolleksiyasida umumiy qadamlarni yangilash
      final userDoc =
          _firestore.collection('users').doc(widget.studentUsername);
      await userDoc.set({
        'pdsteps': _totalSteps + stepCount,
      }, SetOptions(merge: true));

      // Attendance_records da bugungi qadamlarni yangilash
      final attendanceData = {
        'pdsteps': _todaySteps + stepCount,
        'teacher': widget.userData['full_name'],
      };

      await _firestore
          .collection('attendance_records')
          .doc(widget.userData['username'])
          .collection(dateStr)
          .doc(widget.studentUsername)
          .set(attendanceData, SetOptions(merge: true));

      setState(() {
        _totalSteps += stepCount;
        _todaySteps += stepCount;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Qadam muvaffaqiyatli qo\'shildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating steps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF512D84),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              widget.studentName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF512D84),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.studentName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jami qadamlar: $_totalSteps',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            'Bugungi qadamlar: $_todaySteps',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String title, Color color, int stepCount) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _updateSteps(stepCount),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shaxsiy rivojlanish'),
        backgroundColor: const Color(0xFF512D84),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopCard(),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStepCard('3 ta topshirdi', Colors.green, 3),
                    const SizedBox(height: 20),
                    _buildStepCard('2 ta topshirdi', Colors.orange, 2),
                    const SizedBox(height: 20),
                    _buildStepCard('1 ta topshirdi', Colors.deepOrange, 1),
                    const SizedBox(height: 20),
                    // _buildStepCard('Topshirmadi', Colors.red, 0),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
