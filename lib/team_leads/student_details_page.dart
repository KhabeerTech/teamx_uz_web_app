import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Qo'shildi
import 'package:firebase_auth/firebase_auth.dart';

class StudentDetailsPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentUsername;
  final Map<String, dynamic> userData;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentUsername,
    required this.userData,
  });

  @override
  _StudentDetailsPageState createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _teamLeaderUsername;
  Map<String, dynamic>? _userData = {'status': 'Bugun kelmadi'};
  bool _showTasks = false;
  bool _isLoading = true;
  int _totalSteps = 0; // Umumiy qadamlar soni

  @override
  void initState() {
    super.initState();
    _teamLeaderUsername = widget.userData['username'];
    print('DEBUG: Team leader username from props: $_teamLeaderUsername');
    _loadTotalSteps();
    _initializeData();
  }

  Future<void> _loadTotalSteps() async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(widget.studentUsername)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _totalSteps = userData['steps'] ?? 0;
        });
        print('DEBUG: Loaded total steps: $_totalSteps');
      } else {
        print('DEBUG: User document not found, setting steps to 0');
        setState(() {
          _totalSteps = 0;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading total steps: $e');
      setState(() {
        _totalSteps = 0;
      });
    }
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error initializing data: $e');
      rethrow;
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final studentDoc = await _firestore
          .collection('users')
          .doc(widget.studentUsername)
          .get();

      if (studentDoc.exists) {
        setState(() {
          _userData = studentDoc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveStudentDataToFirebase() async {
    try {
      if (_teamLeaderUsername == null) {
        print('DEBUG: Team leader username not found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team leader ma\'lumotlari topilmadi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Attendance ni boolean ga o'tkazish
      bool isPresent = _userData?['status'] == 'Bugun keldi';

      // Topshiriqlar sonini int ga o'tkazish
      int todayCompletedTasks = 0; // Bugun qo'shilgan qadamlar
      bool isCompletedOne = false;
      bool isCompletedTwo = false;
      bool isCompletedThree = false;

      switch (_userData?['status']) {
        case '3 ta topshirdi':
          todayCompletedTasks = 3;
          isCompletedOne = true;
          isCompletedTwo = true;
          isCompletedThree = true;
          break;
        case '2 ta topshirdi':
          todayCompletedTasks = 2;
          isCompletedOne = true;
          isCompletedTwo = true;
          break;
        case '1 ta topshirdi':
          todayCompletedTasks = 1;
          isCompletedOne = true;
          break;
        case 'Topshirmadi':
          todayCompletedTasks = 0;
          break;
        case 'Sababli kelmadi':
          // Kelmaganda qadamlar qo'shilmaydi
          final attendanceData = {
            'is_present': false,
            'absence_reason': 'Sababli',
            'timestamp': FieldValue.serverTimestamp(),
            'updated_by': _teamLeaderUsername,
          };
          await _firestore
              .collection('attendance_records')
              .doc(_teamLeaderUsername)
              .collection(dateStr)
              .doc(widget.studentUsername)
              .set(attendanceData, SetOptions(merge: true));
          return;
        case 'Sababsiz kelmadi':
          // Kelmaganda qadamlar qo'shilmaydi
          final attendanceData = {
            'is_present': false,
            'absence_reason': 'Sababsiz',
            'timestamp': FieldValue.serverTimestamp(),
            'updated_by': _teamLeaderUsername,
          };
          await _firestore
              .collection('attendance_records')
              .doc(_teamLeaderUsername)
              .collection(dateStr)
              .doc(widget.studentUsername)
              .set(attendanceData, SetOptions(merge: true));
          return;
        case 'Bugun keldi':
          // Keldi belgisi qo'yilganda
          final attendanceData = {
            'is_present': true,
            'timestamp': FieldValue.serverTimestamp(),
            'updated_by': _teamLeaderUsername,
          };
          await _firestore
              .collection('attendance_records')
              .doc(_teamLeaderUsername)
              .collection(dateStr)
              .doc(widget.studentUsername)
              .set(attendanceData, SetOptions(merge: true));
          return;
      }

      // Bugungi mavjud ma'lumotlarni olish
      final todayDoc = await _firestore
          .collection('attendance_records')
          .doc(_teamLeaderUsername)
          .collection(dateStr)
          .doc(widget.studentUsername)
          .get();

      int existingSteps = 0;
      if (todayDoc.exists) {
        final todayData = todayDoc.data() as Map<String, dynamic>;
        existingSteps = todayData['steps'] ?? 0;
        print('DEBUG: Existing steps today: $existingSteps');
      }

      // Agar mavjud qadamlar 3 tadan ko'p bo'lsa va yangi qadamlar qo'shilayotgan bo'lsa
      if (existingSteps >= 3 && todayCompletedTasks > 0) {
        final shouldContinue =
            await _showConfirmationDialog(existingSteps, todayCompletedTasks);
        if (!shouldContinue) {
          print('DEBUG: User cancelled adding more steps');
          return;
        }
      }

      // Yangi qadamlarni qo'shish
      final totalTodaySteps = existingSteps + todayCompletedTasks;
      print(
          'DEBUG: Total steps today after adding new steps: $totalTodaySteps');

      // Bugungi ma'lumotlar
      final dailyData = {
        'completed_tasks':
            todayCompletedTasks, // Bugun topshirilgan vazifalar soni
        'completed_one': isCompletedOne,
        'completed_two': isCompletedTwo,
        'completed_three': isCompletedThree,
        'steps': totalTodaySteps, // Bugungi jami qadamlar
        'timestamp': FieldValue.serverTimestamp(),
        'updated_by': _teamLeaderUsername,
      };

      print(
          'DEBUG: Saving daily data to attendance_records/$_teamLeaderUsername/$dateStr/${widget.studentUsername}');
      print('DEBUG: Daily data to save: $dailyData');

      // 1. Attendance records ga bugungi ma'lumotlarni saqlash
      await _firestore
          .collection('attendance_records')
          .doc(_teamLeaderUsername)
          .collection(dateStr)
          .doc(widget.studentUsername)
          .set(dailyData, SetOptions(merge: true));

      // 2. Users kolleksiyasidagi umumiy steps ni yangilash
      final newTotalSteps = _totalSteps + todayCompletedTasks;
      await _firestore
          .collection('users')
          .doc(widget.studentUsername)
          .set({'steps': newTotalSteps}, SetOptions(merge: true));

      // Local state ni yangilash
      setState(() {
        _totalSteps = newTotalSteps;
      });

      print('DEBUG: Today completed tasks: $todayCompletedTasks');
      print('DEBUG: Updated total steps to: $newTotalSteps');
      print('DEBUG: Data saved successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ma\'lumotlar saqlandi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      print('DEBUG: Error saving data to Firebase: $e');
      print('DEBUG: Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ma\'lumotlarni saqlashda xatolik yuz berdi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog(int existingSteps, int newSteps) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Diqqat!'),
              content: Text(
                  'Bugun $existingSteps ta qadam mavjud.\nYana $newSteps ta qadam qo\'shmoqchisiz.\nIshonchingiz komilmi?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Yo\'q'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Ha'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Agar dialog yopilsa false qaytaradi
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      if (_userData == null) {
        _userData = {};
      }
      _userData!['status'] = newStatus;
      _showTasks = newStatus == 'Bugun keldi';
    });

    await _saveStudentDataToFirebase();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status muvaffaqiyatli saqlandi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateSteps(int steps) async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Users collectiondan joriy qadamlarni olish
      final userDoc = await _firestore
          .collection('users')
          .doc(widget.studentUsername)
          .get();

      // Attendance records dan bugungi qadamlarni olish
      final todayDoc = await _firestore
          .collection('attendance_records')
          .doc(_teamLeaderUsername)
          .collection(dateStr)
          .doc(widget.studentUsername)
          .get();

      final currentTodaySteps =
          todayDoc.exists ? (todayDoc.data()?['steps'] ?? 0) : 0;

      // Attendance records ga bugungi qadamlarni saqlash
      await _firestore
          .collection('attendance_records')
          .doc(_teamLeaderUsername)
          .collection(dateStr)
          .doc(widget.studentUsername)
          .set({
        'steps': currentTodaySteps + steps,
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));

      // Users collectionda steps ni yangilash
      if (userDoc.exists) {
        final currentSteps = userDoc.data()?['steps'] ?? 0;
        await _firestore
            .collection('users')
            .doc(widget.studentUsername)
            .update({
          'steps': currentSteps + steps,
        });
      } else {
        await _firestore.collection('users').doc(widget.studentUsername).set({
          'steps': steps,
          'username': widget.studentUsername,
        });
      }

      // UI ni yangilash
      setState(() {
        _totalSteps = (_totalSteps + steps);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Qadamlar muvaffaqiyatli saqlandi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi: $e')),
      );
    }
  }

  // Ogohlantirish berish metodi
  Future<void> _giveWarning() async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 1. Users kolleksiyasidagi umumiy ogohlantirish sonini yangilash
      final userDoc = await _firestore
          .collection('users')
          .doc(widget.studentUsername)
          .get();
      if (!userDoc.exists) {
        print('Student document not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      int warningCount = 1; // Boshlang'ich qiymat

      // Agar oldingi ogohlantirish bo'lsa, unga 1 ni qo'shamiz
      if (userData['warned'] is int) {
        warningCount = userData['warned'] + 1;
      }

      // Firebase users kolleksiyasini yangilash
      await _firestore.collection('users').doc(widget.studentUsername).update({
        'warned': warningCount,
        'warning_time': now.toIso8601String(),
      });

      // 2. Attendance records kolleksiyasidagi bugungi ogohlantirish sonini yangilash
      final attendanceDoc = await _firestore
          .collection('attendance_records')
          .doc(_teamLeaderUsername)
          .collection(dateStr)
          .doc(widget.studentUsername)
          .get();

      int todayWarnings = 1; // Boshlang'ich qiymat

      // Agar bugun ogohlantirish olgan bo'lsa, unga 1 ni qo'shamiz
      if (attendanceDoc.exists) {
        final attendanceData = attendanceDoc.data() as Map<String, dynamic>;
        if (attendanceData['warned'] is int) {
          todayWarnings = attendanceData['warned'] + 1;
        }
      }

      // Attendance records'ni yangilash
      await _firestore
          .collection('attendance_records')
          .doc(_teamLeaderUsername)
          .collection(dateStr)
          .doc(widget.studentUsername)
          .set({
        'warned': todayWarnings,
        'warning_time': now.toIso8601String(),
      }, SetOptions(merge: true));

      // UI ni yangilash
      setState(() {
        _userData = {
          ..._userData!,
          'warned': warningCount,
        };
      });

      // Ogohlantirish berilgani haqida xabar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ogohlantirish berildi (Bugun: #$todayWarnings, Jami: #$warningCount)'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print('Error giving warning: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xatolik yuz berdi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showWarningConfirmDialog() async {
    final TextEditingController _warningReasonController =
        TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tasdiqlash',
          style: TextStyle(
            color: Color(0xFF512D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ishonchingiz komilmi, o\'quvchi ogohlantirish oldimi?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _warningReasonController,
              decoration: const InputDecoration(
                labelText: 'Ogohlantirish sababi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              'Yo\'q',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_warningReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Iltimos, ogohlantirish sababini kiriting')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ha',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (confirmed ?? false) {
      try {
        // Users kolleksiyasidan joriy ogohlantirish sonini olish
        final userDoc = await _firestore
            .collection('users')
            .doc(widget.studentUsername)
            .get();

        int warningCount = 1; // Boshlang'ich qiymat
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          // Agar oldingi ogohlantirish bo'lsa, unga 1 ni qo'shamiz
          if (userData['warned'] is int) {
            warningCount = userData['warned'] + 1;
          }
        }

        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        // Users kolleksiyasini yangilash
        await _firestore
            .collection('users')
            .doc(widget.studentUsername)
            .update({
          'warned': warningCount,
          'warning_time': Timestamp.now(),
          'warning_reason': _warningReasonController.text.trim(),
        });

        // Attendance records kolleksiyasini yangilash
        final attendanceDoc = await _firestore
            .collection('attendance_records')
            .doc(_teamLeaderUsername)
            .collection(dateStr)
            .doc(widget.studentUsername)
            .get();

        int todayWarnings = 1; // Boshlang'ich qiymat

        // Agar bugun ogohlantirish olgan bo'lsa, unga 1 ni qo'shamiz
        if (attendanceDoc.exists) {
          final attendanceData = attendanceDoc.data() as Map<String, dynamic>;
          if (attendanceData['warned'] is int) {
            todayWarnings = attendanceData['warned'] + 1;
          }
        }

        await _firestore
            .collection('attendance_records')
            .doc(_teamLeaderUsername)
            .collection(dateStr)
            .doc(widget.studentUsername)
            .update({
          'warned': todayWarnings,
          'warning_time': Timestamp.now(),
          'warning_reason': _warningReasonController.text.trim(),
        });

        // UI ni yangilash
        setState(() {
          _userData = {
            ..._userData!,
            'warned': warningCount,
          };
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ogohlantirish berildi (Bugun: #$todayWarnings, Jami: #$warningCount)'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        print('Error updating warning status: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAbsenceDialog() async {
    // Dialog ochilishidan oldin eng katta tugmani topamiz
    double maxWidth = 0;
    double maxHeight = 0;

    // Barcha tugmalarni tekshirib, eng kattasini topamiz
    final buttons = [
      '3 ta topshirdi',
      '2 ta topshirdi',
      '1 ta topshirdi',
      'Topshirmadi',
      'Bugun keldi',
      'Bugun kelmadi',
      'Ogohlantirish oldi'
    ];

    for (var title in buttons) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }

    // Tugma uchun qo'shimcha padding va border hisobga olinadi
    maxWidth += 48; // 24px padding on each side
    maxHeight = 48; // Standard height

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Kelmaslik sababi',
          style: TextStyle(
            color: Color(0xFF512D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: maxWidth + 16, // Dialog uchun qo'shimcha padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: maxWidth,
                height: maxHeight,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus('Sababli kelmadi');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Sababli',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: maxWidth,
                height: maxHeight,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus('Sababsiz kelmadi');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Sababsiz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _showStepsDialog() async {
    String steps = '';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Qadamlar soni',
          style: TextStyle(
            color: Color(0xFF512D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 2,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Faqat raqamlar
            ],
            decoration: const InputDecoration(
              labelText: 'Qadamlar soni',
              hintText: 'Faqat raqam (1-20)',
              counterText: '',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => steps = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Iltimos, qadamlar sonini kiriting';
              }
              final number = int.tryParse(value);
              if (number == null) {
                return 'Faqat raqam kiriting';
              }
              if (number <= 0) {
                return 'Nol yoki manfiy son kiritish mumkin emas';
              }
              if (number > 20) {
                return 'Maksimal 20 qadam kiritish mumkin';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                _updateSteps(int.parse(steps));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF512D84),
              foregroundColor: Colors.white,
            ),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_teamLeaderUsername == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Team leader ma\'lumotlari topilmadi',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await _initializeData();
                },
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.studentName} holati',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: _userData == null
          ? const Center(child: Text('Ma\'lumotlar topilmadi'))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF8F0FF),
                    Color(0xFFF0F7FF),
                    Color(0xFFF8F0FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF512D84), Color(0xFF7646B8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF512D84).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              widget.studentName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.studentName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<DocumentSnapshot>(
                            future: _firestore
                                .collection('users')
                                .doc(widget.studentUsername)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(
                                    color: Colors.white);
                              }

                              if (snapshot.hasError) {
                                return Text('Xatolik: ${snapshot.error}',
                                    style:
                                        const TextStyle(color: Colors.white));
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text('Ma\'lumot topilmadi',
                                    style: TextStyle(color: Colors.white));
                              }

                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final totalSteps = userData['steps'] ?? 0;

                              return Column(
                                children: [
                                  Text(
                                    'qadamlar: $totalSteps',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: _firestore
                                        .collection('attendance_records')
                                        .doc(_teamLeaderUsername)
                                        .collection(dateStr)
                                        .doc(widget.studentUsername)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          !snapshot.data!.exists) {
                                        return const Text(
                                          'Bugungi qadamlar: 0',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        );
                                      }

                                      final todayData = snapshot.data!.data()
                                          as Map<String, dynamic>;
                                      final todaySteps =
                                          todayData['steps'] ?? 0;

                                      return Text(
                                        'Bugungi qadamlar: $todaySteps',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Davomat tugmalari
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FF),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Davomat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF512D84),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  title: 'Bugun keldi',
                                  color: Colors.green,
                                  onPressed: () => _updateStatus('Bugun keldi'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildActionButton(
                                  title: 'Bugun kelmadi',
                                  color: Colors.red,
                                  onPressed: () => _showAbsenceDialog(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Topshiriq tugmalari
                    if (_showTasks)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F5FF),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Topshiriqlar holati',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF512D84),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    title: '3 ta topshirdi',
                                    color: Colors.green.shade600,
                                    onPressed: () =>
                                        _updateStatus('3 ta topshirdi'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildActionButton(
                                    title: '2 ta topshirdi',
                                    color: Colors.amber.shade700,
                                    onPressed: () =>
                                        _updateStatus('2 ta topshirdi'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    title: '1 ta topshirdi',
                                    color: Colors.orange.shade800,
                                    onPressed: () =>
                                        _updateStatus('1 ta topshirdi'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Topshirmadi',
                                    color: Colors.red.shade700,
                                    onPressed: () =>
                                        _updateStatus('Topshirmadi'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: _buildActionButton(
                                title: 'Qadamlar kiritish',
                                color: const Color(0xFF512D84),
                                onPressed: () => _showStepsDialog(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Pastki padding
                    const SizedBox(
                        height: 100), // Ogohlantirish tugmasi uchun joy
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Ogohlantirish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF512D84),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _buildActionButton(
                title: 'Ogohlantirish oldi',
                color: Colors.red.shade900,
                onPressed: () => _showWarningConfirmDialog(),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Haydash',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _buildActionButton(
                title: 'Haydalib ketdi',
                color: Colors.black,
                onPressed: () {}, // Hozircha hech qanday amal bajarmaydi
              ),
            ),
          ],
        ),
      ),
    );
  }
}
