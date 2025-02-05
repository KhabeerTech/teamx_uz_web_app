import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ApproveStudentsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ApproveStudentsPage({Key? key, required this.userData})
      : super(key: key);

  @override
  State<ApproveStudentsPage> createState() => _ApproveStudentsPageState();
}

class _StudentSearchList extends StatefulWidget {
  final List<QueryDocumentSnapshot> students;
  final Function(Map<String, dynamic>) onApprove;

  const _StudentSearchList({
    Key? key,
    required this.students,
    required this.onApprove,
  }) : super(key: key);

  @override
  State<_StudentSearchList> createState() => _StudentSearchListState();
}

class _StudentSearchListState extends State<_StudentSearchList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ism, username yoki telefon bo\'yicha qidirish...',
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
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: widget.students.length,
            itemBuilder: (context, index) {
              final student = widget.students[index].data() as Map<String, dynamic>;
              final fullName = (student['full_name'] ?? '').toString().toLowerCase();
              final username = (student['username'] ?? '').toString().toLowerCase();
              final phone = (student['phone'] ?? student['father_phone'] ?? '').toString().toLowerCase();

              if (_searchQuery.isNotEmpty &&
                  !fullName.contains(_searchQuery) &&
                  !username.contains(_searchQuery) &&
                  !phone.contains(_searchQuery)) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF512DA8)),
                  title: Text(
                    student['full_name'] ?? 'Nomsiz',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${student['username'] ?? ''}'),
                      Text('Tel: ${student['phone'] == 'N/A' || student['phone'] == null ? student['father_phone'] ?? 'N/A' : student['phone']}'),
                      Text('Region: ${student['region'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF512DA8),
                    ),
                    onPressed: () => widget.onApprove(student),
                    child: const Text(
                      'Tasdiqlash',
                      style: TextStyle(color: Colors.white),
                    ),
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

class _ApproveStudentsPageState extends State<ApproveStudentsPage> {
  final List<String> _weekDays = [
    'dushanba',
    'seshanba',
    'chorshanba',
    'payshanba',
    'juma',
    'shanba',
  ];
  final List<String> _selectedDays = [];
  String? _dateText;
  DateTime? _startDate;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isValidDate(String value) {
    if (value.length != 10) return false;

    try {
      final parts = value.split('.');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31) return false;
      if (month < 1 || month > 12) return false;
      if (year < 2024 || year > 2026) return false;

      _startDate = DateTime(year, month, day);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _selectStartDate() async {
    _dateText = null;
    _startDate = null;

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kelgan sanasini kiriting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Sana (dd.mm.yyyy)',
                  hintText: 'Masalan: 06.01.2025',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  setState(() {
                    if (_isValidDate(value)) {
                      _dateText = value;
                    } else {
                      _dateText = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Format: dd.mm.yyyy\nMasalan: 06.01.2025',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _dateText = null;
                _startDate = null;
                Navigator.pop(context);
              },
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF512DA8),
              ),
              onPressed:
                  _dateText != null ? () => Navigator.pop(context) : null,
              child: Text(
                'Saqlash',
                style: TextStyle(
                  color: _dateText != null ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDaysSelectionDialog() async {
    await showDialog<List<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kelish kunlarini tanlang'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _weekDays.length,
              itemBuilder: (context, index) {
                final day = _weekDays[index];
                return CheckboxListTile(
                  title: Text(day),
                  value: _selectedDays.contains(day),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (_selectedDays.length < 3) {
                          _selectedDays.add(day);
                        }
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF512DA8),
              ),
              onPressed: _selectedDays.length == 3
                  ? () => Navigator.pop(context)
                  : null,
              child: Text(
                'Saqlash',
                style: TextStyle(
                  color: _selectedDays.length == 3 ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveStudent(Map<String, dynamic> student) async {
    _selectedDays.clear();
    _dateText = null;
    _startDate = null;

    // Avval kelish kunlarini tanlash
    await _showDaysSelectionDialog();
    if (_selectedDays.length != 3) return;

    // Keyin kelgan sanani tanlash
    await _selectStartDate();
    if (_startDate == null) return;

    try {
      // Sanani dd.mm.yy formatiga o'tkazish
      final formattedDate =
          "${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.year.toString().substring(2)}";

      await FirebaseFirestore.instance
          .collection('users')
          .doc(student['username'])
          .update({
        'case': 'yes',
        'attendance_days': _selectedDays,
        'start_date': formattedDate, // dd.mm.yy formatida saqlash
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O\'quvchi muvaffaqiyatli tasdiqlandi'),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('case', isEqualTo: 'no')
          .where('role', isEqualTo: 'student')
          .where('region', isEqualTo: widget.userData['region'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data?.docs ?? [];

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hozircha tasdiqlanmagan o\'quvchilar yo\'q',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF512DA8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        maxChildSize: 0.9,
                        minChildSize: 0.5,
                        expand: false,
                        builder: (context, scrollController) =>
                            StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('region',
                                  isEqualTo: widget.userData['region'])
                              .where('case', isEqualTo: 'yes')
                              .where('role', isEqualTo: 'student')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Xatolik yuz berdi: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final approvedStudents = snapshot.data!.docs;

                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF512DA8),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tasdiqlangan o\'quvchilar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (approvedStudents.isEmpty)
                                    const Expanded(
                                      child: Center(
                                        child: Text(
                                          'Hozircha tasdiqlangan o\'quvchilar yo\'q',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        padding: const EdgeInsets.all(16),
                                        itemCount: approvedStudents.length,
                                        itemBuilder: (context, index) {
                                          final student =
                                              approvedStudents[index].data()
                                                  as Map<String, dynamic>;
                                          return Card(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    const Color(0xFF512DA8),
                                                child: Text(
                                                  student['full_name']
                                                          ?.toString()
                                                          .substring(0, 1)
                                                          .toUpperCase() ??
                                                      'N',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              title: Text(
                                                student['full_name'] ??
                                                    'Nomsiz',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '@${student['username'] ?? ''}'),
                                                  Text(
                                                      'Tel: ${student['phone'] == 'N/A' || student['phone'] == null ? student['father_phone'] ?? 'N/A' : student['phone']}'),
                                                  Text(
                                                      'Team Lead: ${student['team_lead_username'] ?? 'Biriktirilmagan'}'),
                                                ],
                                              ),
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
                    );
                  },
                  icon: const Icon(Icons.people, color: Colors.white),
                  label: const Text(
                    'Tasdiqlangan o\'quvchilar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            _StudentSearchList(
              students: students,
              onApprove: _approveStudent,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF512DA8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        maxChildSize: 0.9,
                        minChildSize: 0.5,
                        expand: false,
                        builder: (context, scrollController) =>
                            StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('region',
                                  isEqualTo: widget.userData['region'])
                              .where('case', isEqualTo: 'yes')
                              .where('role', isEqualTo: 'student')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Xatolik yuz berdi: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final approvedStudents = snapshot.data!.docs;

                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF512DA8),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tasdiqlangan o\'quvchilar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (approvedStudents.isEmpty)
                                    const Expanded(
                                      child: Center(
                                        child: Text(
                                          'Hozircha tasdiqlangan o\'quvchilar yo\'q',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        padding: const EdgeInsets.all(16),
                                        itemCount: approvedStudents.length,
                                        itemBuilder: (context, index) {
                                          final student =
                                              approvedStudents[index].data()
                                                  as Map<String, dynamic>;
                                          return Card(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    const Color(0xFF512DA8),
                                                child: Text(
                                                  student['full_name']
                                                          ?.toString()
                                                          .substring(0, 1)
                                                          .toUpperCase() ??
                                                      'N',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              title: Text(
                                                student['full_name'] ??
                                                    'Nomsiz',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '@${student['username'] ?? ''}'),
                                                  Text(
                                                      'Tel: ${student['phone'] == 'N/A' || student['phone'] == null ? student['father_phone'] ?? 'N/A' : student['phone']}'),
                                                  Text(
                                                      'Team Lead: ${student['team_lead_username'] ?? 'Biriktirilmagan'}'),
                                                ],
                                              ),
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
                    );
                  },
                  label: const Text(
                    'Tasdiqlangan o\'quvchilar',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
