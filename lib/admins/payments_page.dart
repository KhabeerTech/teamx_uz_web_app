import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _firestore = FirebaseFirestore.instance;
  String? _selectedRegion;
  final TextEditingController _paymentDateController = TextEditingController();
  String _viewType = 'today';

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    return Container(
      width: isPhone ? 140 : 200,
      height: isPhone ? 90 : 120,
      padding: EdgeInsets.all(isPhone ? 8 : 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: isPhone ? 16 : 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isPhone ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
  }

  String _getTomorrowDate() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return "${tomorrow.day.toString().padLeft(2, '0')}.${tomorrow.month.toString().padLeft(2, '0')}.${tomorrow.year}";
  }

  String _getDateAfterDays(int days) {
    final date = DateTime.now().add(Duration(days: days));
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  Future<void> _addPayment(Map<String, dynamic> student) async {
    _paymentDateController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('To\'lov sanasini kiriting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('O\'quvchi: ${student['full_name']}'),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentDateController,
              decoration: const InputDecoration(
                labelText: 'Keyingi to\'lov sanasi (dd.MM.yyyy)',
                hintText: '12.01.2025',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF512DA8),
            ),
            onPressed: () {
              final dateStr = _paymentDateController.text.trim();
              if (!_isValidDateFormat(dateStr)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Sana formati noto\'g\'ri! dd.MM.yyyy formatida kiriting'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text(
              'Saqlash',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true && _paymentDateController.text.isNotEmpty) {
      try {
        final batch = _firestore.batch();
        final today = _getTodayDate();
        final nextPaymentDate = _paymentDateController.text.trim();

        // 1. users kolleksiyasida payment=true va payments_date ni yangilash
        final userRef = _firestore.collection('users').doc(student['username']);
        batch.update(userRef, {
          'payment': true,
          'payments_date': nextPaymentDate,
        });

        // 2. payments kolleksiyasiga to'lov ma'lumotlarini saqlash
        final paymentRef = _firestore
            .collection('payments')
            .doc(_selectedRegion)
            .collection(today)
            .doc(student['username']); // Username dokumenti

        batch.set(paymentRef, {
          'student_username': student['username'],
          'student_name': student['full_name'],
          'region': student['region'],
          'payment_time': FieldValue.serverTimestamp(),
          'start_date': student['start_date'],
          'payments_date': nextPaymentDate,
          'father_phone': student['father_phone'],
        });

        await batch.commit();

        // Keyingi to'lov sanasi kelganda payment=false qilib qo'yamiz
        if (nextPaymentDate == today) {
          await _firestore.collection('users').doc(student['username']).update({
            'payment': false,
          });
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('To\'lov muvaffaqiyatli saqlandi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xatolik yuz berdi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  bool _isValidDateFormat(String date) {
    if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(date)) return false;

    try {
      final parts = date.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (year < 2024 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> _getStudentsForPayment(String region) {
    final today = _getTodayDate();

    switch (_viewType) {
      case 'tomorrow':
        final tomorrow = _getTomorrowDate();
        return _firestore
            .collection('users')
            .where('case', isEqualTo: 'yes')
            .where('role', isEqualTo: 'student')
            .where('region', isEqualTo: region)
            .where('payments_date', isEqualTo: tomorrow)
            .snapshots();

      case 'week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekDates = List.generate(7, (i) {
          final date = weekStart.add(Duration(days: i));
          return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
        });

        return _firestore
            .collection('users')
            .where('case', isEqualTo: 'yes')
            .where('role', isEqualTo: 'student')
            .where('region', isEqualTo: region)
            .where('payments_date', whereIn: weekDates)
            .snapshots();

      case 'today':
      default:
        // Bugungi to'lovlar uchun barcha talabalarni olamiz
        return _firestore
            .collection('users')
            .where('case', isEqualTo: 'yes')
            .where('role', isEqualTo: 'student')
            .where('region', isEqualTo: region)
            .snapshots();
    }
  }

  bool _shouldShowStudent(Map<String, dynamic> student) {
    final today = _getTodayDate();

    switch (_viewType) {
      case 'today':
        // 3 xil holatni tekshirish:
        // 1. payment field umuman yo'q bo'lsa
        // 2. payment=false bo'lsa
        // 3. payments_date=today bo'lsa

        // 1. payment field umuman yo'q bo'lsa
        if (!student.containsKey('payment')) {
          return true;
        }

        // 2. payment=false bo'lsa
        if (student['payment'] == false) {
          return true;
        }

        // 3. payments_date=today bo'lsa
        if (student.containsKey('payments_date') &&
            student['payments_date'] == today) {
          return true;
        }

        return false;

      case 'tomorrow':
      case 'week':
        return true;
      default:
        return false;
    }
  }

  Stream<int> _getTodayPaymentsCount(String region) {
    return _firestore
        .collection('users')
        .where('case', isEqualTo: 'yes')
        .where('role', isEqualTo: 'student')
        .where('region', isEqualTo: region)
        .where('start_date', isEqualTo: _getTodayDate())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where(
              (doc) => _shouldShowStudent(doc.data() as Map<String, dynamic>))
          .length;
    });
  }

  Stream<int> _getTomorrowPaymentsCount(String region) {
    final tomorrow = _getTomorrowDate();
    return _firestore
        .collection('users')
        .where('case', isEqualTo: 'yes')
        .where('role', isEqualTo: 'student')
        .where('region', isEqualTo: region)
        .where('payments_date', isEqualTo: tomorrow)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getWeekPaymentsCount(String region) {
    final dates = List.generate(7, (i) => _getDateAfterDays(i));
    return _firestore
        .collection('users')
        .where('case', isEqualTo: 'yes')
        .where('role', isEqualTo: 'student')
        .where('region', isEqualTo: region)
        .where('payments_date', whereIn: dates)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  String _getViewTypeTitle() {
    switch (_viewType) {
      case 'tomorrow':
        return 'Ertangi to\'lovlar';
      case 'week':
        return 'Haftalik to\'lovlar';
      case 'today':
      default:
        return 'Bugungi to\'lovlar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _getTodayDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To\'lovlar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF512D84),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('regions').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Xatolik yuz berdi');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final regions = snapshot.data!.docs;

                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Regionni tanlang',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedRegion,
                      items: regions.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] as String? ?? 'Nomsiz';
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          if (_selectedRegion != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    StreamBuilder<int>(
                      stream: _getTodayPaymentsCount(_selectedRegion!),
                      builder: (context, snapshot) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _viewType = 'today';
                            });
                          },
                          child: _buildStatCard(
                            'Bugungi to\'lovlar',
                            snapshot.data?.toString() ?? '0',
                            _viewType == 'today'
                                ? const Color(0xFF512D84)
                                : const Color(0xFF512D84).withOpacity(0.7),
                            Icons.today,
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      stream: _getTomorrowPaymentsCount(_selectedRegion!),
                      builder: (context, snapshot) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _viewType = 'tomorrow';
                            });
                          },
                          child: _buildStatCard(
                            'Ertangi to\'lovlar',
                            snapshot.data?.toString() ?? '0',
                            _viewType == 'tomorrow'
                                ? Colors.orange
                                : Colors.orange.withOpacity(0.7),
                            Icons.next_plan,
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      stream: _getWeekPaymentsCount(_selectedRegion!),
                      builder: (context, snapshot) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _viewType = 'week';
                            });
                          },
                          child: _buildStatCard(
                            'Haftalik to\'lovlar',
                            snapshot.data?.toString() ?? '0',
                            _viewType == 'week'
                                ? Colors.green
                                : Colors.green.withOpacity(0.7),
                            Icons.date_range,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _getViewTypeTitle(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _getStudentsForPayment(_selectedRegion!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Xatolik yuz berdi'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final students = snapshot.data!.docs;

                          if (students.isEmpty) {
                            return const Center(
                              child: Text(
                                'Bugun to\'lov qilishi kerak bo\'lgan o\'quvchilar yo\'q',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          // To'lov qilmaganlarni filter qilish
                          final filteredStudents = students
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .where((student) => _shouldShowStudent(student))
                              .toList();

                          if (filteredStudents.isEmpty) {
                            return const Center(
                              child: Text(
                                'Bugun to\'lov qilishi kerak bo\'lgan o\'quvchilar yo\'q',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          return StudentSearchList(
                            students: filteredStudents,
                            onPaymentAdd: _addPayment,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _selectedRegion == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                try {
                  // Sanalarni yaratish
                  final startDate = DateTime(2025, 1, 13); // 13.01.2025
                  final endDate = DateTime.now();
                  
                  final dates = <String>[];
                  for (var date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
                    final formattedDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                    dates.add(formattedDate);
                  }

                  // Test qilish uchun bitta sanani tekshiramiz
                  final testSnapshot = await _firestore
                      .collection('payments')
                      .doc(_selectedRegion)
                      .collection('20.01.2025')
                      .get();

                  if (testSnapshot.docs.isEmpty) {
                    // Agar test sana topilmasa, demak bu region uchun to'lovlar yo'q
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bu region uchun to\'lovlar tarixi topilmadi'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;

                  // Sanalarni tartiblash (eng yangisi tepada)
                  dates.sort((a, b) => b.compareTo(a));

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('$_selectedRegion to\'lovlar tarixi'),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: dates.isEmpty
                            ? const Center(
                                child: Text('To\'lovlar tarixi topilmadi'),
                              )
                            : ListView.builder(
                                itemCount: dates.length,
                                itemBuilder: (context, index) {
                                  final date = dates[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(date),
                                      trailing:
                                          const Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // print('DEBUG: Tanlangan sana: $date');

                                        // Tanlangan sanadagi to'lovlarni ko'rsatish
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('$date to\'lovlari'),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.8,
                                              child:
                                                  StreamBuilder<QuerySnapshot>(
                                                stream: _firestore
                                                    .collection('payments')
                                                    .doc(_selectedRegion)
                                                    .collection(date)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    // print('DEBUG: Xatolik: ${snapshot.error}');
                                                    return const Text(
                                                        'Xatolik yuz berdi');
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }

                                                  final payments =
                                                      snapshot.data?.docs ?? [];
                                                  // print('DEBUG: Tanlangan sanadagi to\'lovlar soni: ${payments.length}');

                                                  if (payments.isEmpty) {
                                                    return const Center(
                                                      child: Text(
                                                          'To\'lovlar topilmadi'),
                                                    );
                                                  }

                                                  return ListView.builder(
                                                    itemCount: payments.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final payment =
                                                          payments[index].data()
                                                              as Map<String,
                                                                  dynamic>;
                                                      // print('DEBUG: To\'lov ma\'lumotlari: $payment');

                                                      final paymentTime =
                                                          payment['payment_time']
                                                              as Timestamp?;
                                                      final formattedTime =
                                                          paymentTime != null
                                                              ? '${paymentTime.toDate().hour.toString().padLeft(2, '0')}:${paymentTime.toDate().minute.toString().padLeft(2, '0')}'
                                                              : '';

                                                      return Card(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 4,
                                                            horizontal: 8),
                                                        child: ListTile(
                                                          leading: CircleAvatar(
                                                            backgroundColor:
                                                                const Color(
                                                                    0xFF512D84),
                                                            child: Text(
                                                              payment['student_name']
                                                                          ?[0]
                                                                      ?.toUpperCase() ??
                                                                  'N',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          title: Text(payment[
                                                                  'student_name'] ??
                                                              ''),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  '@${payment['student_username'] ?? ''}'),
                                                              Text(
                                                                  'Tel: ${payment['father_phone'] ?? ''}'),
                                                              Text(
                                                                  'Keyingi to\'lov: ${payment['payments_date'] ?? ''}'),
                                                              if (formattedTime
                                                                  .isNotEmpty)
                                                                Text(
                                                                    'To\'lov vaqti: $formattedTime'),
                                                            ],
                                                          ),
                                                          isThreeLine: true,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Yopish'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Yopish'),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  // print('DEBUG: Xatolik yuz berdi: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xatolik yuz berdi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              label: const Text('Tarix'),
              icon: const Icon(Icons.history),
              backgroundColor: const Color(0xFF512D84),
            ),
    );
  }

  @override
  void dispose() {
    _paymentDateController.dispose();
    super.dispose();
  }
}

// StudentSearchList widget
class StudentSearchList extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final Function(Map<String, dynamic>) onPaymentAdd;

  const StudentSearchList({
    Key? key,
    required this.students,
    required this.onPaymentAdd,
  }) : super(key: key);

  @override
  State<StudentSearchList> createState() => _StudentSearchListState();
}

class _StudentSearchListState extends State<StudentSearchList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _filteredStudents = widget.students;
  }

  @override
  void didUpdateWidget(StudentSearchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students) {
      _filterStudents();
    }
  }

  void _filterStudents() {
    setState(() {
      _filteredStudents = widget.students.where((student) {
        final fullName = (student['full_name'] ?? '').toString().toLowerCase();
        final username = (student['username'] ?? '').toString().toLowerCase();
        final phone = (student['father_phone'] ?? '').toString().toLowerCase();
        
        return _searchQuery.isEmpty ||
            fullName.contains(_searchQuery) ||
            username.contains(_searchQuery) ||
            phone.contains(_searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Qidiruv maydoni
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'O\'quvchi ismi, username yoki telefon raqami...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF512D84)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF512D84)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF512D84), width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
                _filterStudents();
              });
            },
          ),
        ),
        // O'quvchilar ro'yxati
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              final student = _filteredStudents[index];
              final fullName = student['full_name']?.toString() ?? 'Nomsiz';
              final firstLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'N';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF512D84),
                    child: Text(
                      firstLetter,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${student['username'] ?? ''}'),
                      Text('Tel: ${student['father_phone'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: MediaQuery.of(context).size.width < 600
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(student['username'])
                                        .update({
                                      'payment': false,
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('To\'lov qilmadi deb belgilandi'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Xatolik yuz berdi: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 113, 192, 116),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => widget.onPaymentAdd(student),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(student['username'])
                                      .update({
                                    'payment': false,
                                  });

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('To\'lov qilmadi deb belgilandi'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Xatolik yuz berdi: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'To\'lov qilmadi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF512D84),
                              ),
                              onPressed: () => widget.onPaymentAdd(student),
                              child: const Text(
                                'To\'lov qildi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
