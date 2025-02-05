import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeamLeadPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AddTeamLeadPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<AddTeamLeadPage> createState() => _AddTeamLeadPageState();
}

class _AddTeamLeadPageState extends State<AddTeamLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupLinkController = TextEditingController();
  final _groupIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  Future<Map<String, String>?> _showGroupInfoDialog() async {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Guruh ma\'lumotlarini kiriting'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Shaxsiy telefon raqami',
                  hintText: '+998 XX XXX XX XX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefon raqamini kiriting';
                  }
                  if (!value.startsWith('+998')) {
                    return 'Raqam +998 bilan boshlanishi kerak';
                  }
                  if (value.length != 13) {
                    return 'Raqam 13 ta belgidan iborat bo\'lishi kerak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupLinkController,
                decoration: const InputDecoration(
                  labelText: 'Telegram guruh linki',
                  hintText: 'https://t.me/...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Guruh linkini kiriting';
                  }
                  if (!value.startsWith('https://t.me/')) {
                    return 'Link https://t.me/ bilan boshlanishi kerak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupIdController,
                decoration: const InputDecoration(
                  labelText: 'Telegram guruh ID si',
                  hintText: '-100...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Guruh ID sini kiriting';
                  }
                  if (!value.startsWith('-100')) {
                    return 'ID -100 bilan boshlanishi kerak';
                  }
                  return null;
                },
              ),
            ],
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'phone': _phoneController.text,
                  'groupLink': _groupLinkController.text,
                  'groupId': _groupIdController.text,
                });
              }
            },
            child: const Text(
              'Saqlash',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _groupLinkController.dispose();
    _groupIdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headTeacherRegion = widget.userData['region'] as String?;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('case', isEqualTo: 'yes')
          .where('role', isEqualTo: 'student')
          .where('region', isEqualTo: headTeacherRegion)
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
          return const Center(
            child: Text(
              'Hozircha o\'quvchilar yo\'q',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _StudentSearchList(
          students: students,
          onStudentSelected: (student) async {
            try {
              final studentData = student;
              final newUsername = '${studentData['username']}_TL';

              // Avval shu username li team lead borligini tekshirish
              final existingTeamLead = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(newUsername)
                  .get();

              if (existingTeamLead.exists) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bu user allaqachon Team Lead qilingan!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              // Agar team lead mavjud bo'lmasa, guruh ma'lumotlarini so'raymiz
              if (context.mounted) {
                final result = await _showGroupInfoDialog();
                if (result != null) {
                  // Yangi team lead uchun ma'lumotlarni tayyorlash
                  final teamLeadData = {
                    ...studentData,
                    'username': newUsername,
                    'role': 'team_lead',
                    'group_link': result['groupLink'],
                    'group_id': result['groupId'],
                    'phone': result['phone'],
                    'is_approved': true,
                    'head_teacher_username': widget.userData['username'],
                  };

                  // Yangi team lead ni username bilan document ID sifatida qo'shish
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(newUsername)
                      .set(teamLeadData);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Team Lead muvaffaqiyatli qo\'shildi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
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
        );
      },
    );
  }
}

class _StudentSearchList extends StatefulWidget {
  final List<QueryDocumentSnapshot> students;
  final Function(Map<String, dynamic>) onStudentSelected;

  const _StudentSearchList({
    Key? key,
    required this.students,
    required this.onStudentSelected,
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
            padding: const EdgeInsets.all(16),
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
                    onPressed: () => widget.onStudentSelected(student),
                    child: const Text(
                      'Team Lead qilish',
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
