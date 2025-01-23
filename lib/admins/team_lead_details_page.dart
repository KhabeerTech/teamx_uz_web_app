import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'student_details_page.dart';

class TeamLeadDetailsPage extends StatefulWidget {
  final Map<String, dynamic> teamLead;
  final bool isApproved;

  const TeamLeadDetailsPage({
    super.key,
    required this.teamLead,
    required this.isApproved,
  });

  @override
  State<TeamLeadDetailsPage> createState() => _TeamLeadDetailsPageState();
}

class _TeamLeadDetailsPageState extends State<TeamLeadDetailsPage> {
  Map<String, dynamic>? _selectedStudent;
  List<Map<String, dynamic>> assignedStudents = [];
  List<Map<String, dynamic>> students = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAssignedStudents();
    _loadStudents();
  }

  Future<void> _loadAssignedStudents() async {
    final snapshot = await _firestore
        .collection('users')
        .where('team_lead_username', isEqualTo: widget.teamLead['username'])
        .get();

    setState(() {
      assignedStudents = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      print('DEBUG: Starting to load students...');

      // Team Lead regionini olish
      final teamLeadDoc = await _firestore
          .collection('users')
          .doc(widget.teamLead['username'])
          .get();
      final teamLeadData = teamLeadDoc.data() as Map<String, dynamic>;
      final teamLeadRegion = teamLeadData['region'] as String?;

      if (teamLeadRegion == null) {
        print('Team Lead regioni topilmadi');
        return;
      }

      // O'quvchilarni olish
      final approvedSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('case', isEqualTo: 'yes')
          .where('region', isEqualTo: teamLeadRegion)
          .get();

      print('\nDEBUG: Found students:');
      
      // Faqat team_lead_username = null yoki umuman bo'lmagan o'quvchilarni filtrlash
      final filteredDocs = approvedSnapshot.docs.where((doc) {
        final data = doc.data();
        return !data.containsKey('team_lead_username') || data['team_lead_username'] == null;
      });

      for (var doc in filteredDocs) {
        final data = doc.data();
        print('Student ${doc.id}:');
        print('- full_name: ${data['full_name']}');
        print('- case: ${data['case']}');
        print('- region: ${data['region']}');
        print('- team_lead_username: ${data['team_lead_username']}');
        print('-------------------');
      }

      if (!mounted) return;

      final loadedStudents = filteredDocs.map((doc) {
        final data = doc.data();
        return {
          'username': doc.id,
          'full_name': data['full_name'] ?? 'Nomsiz',
          'grade': data['grade'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        students = loadedStudents;
        _isLoading = false;
      });

      print('\nDEBUG: Final loaded students count: ${loadedStudents.length}');
    } catch (e) {
      print('Error loading students: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('O\'quvchilarni yuklashda xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignStudent(String studentUsername) async {
    try {
      final batch = _firestore.batch();

      // Team lead-ning students array-iga o'quvchini qo'shish
      final teamLeadRef =
          _firestore.collection('users').doc(widget.teamLead['username']);

      batch.update(teamLeadRef, {
        'students': FieldValue.arrayUnion([studentUsername])
      });

      // O'quvchining team_lead_username maydonini yangilash
      final studentRef = _firestore.collection('users').doc(studentUsername);

      batch.update(
          studentRef, {'team_lead_username': widget.teamLead['username']});

      // Barcha o'zgarishlarni bir vaqtda amalga oshirish
      await batch.commit();

      setState(() {
        _selectedStudent = null;
      });

      // Dropdown-ni yangilash
      await _loadStudents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O\'quvchi muvaffaqiyatli biriktirildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error assigning student: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeStudent(String studentUsername) async {
    try {
      final batch = _firestore.batch();

      // Team lead-ning students array-idan o'quvchini o'chirish
      final teamLeadRef =
          _firestore.collection('users').doc(widget.teamLead['username']);

      batch.update(teamLeadRef, {
        'students': FieldValue.arrayRemove([studentUsername])
      });

      // O'quvchining team_lead_username maydonini tozalash
      final studentRef = _firestore.collection('users').doc(studentUsername);

      batch.update(studentRef, {'team_lead_username': null});

      // Barcha o'zgarishlarni bir vaqtda amalga oshirish
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O\'quvchi muvaffaqiyatli o\'chirildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error removing student: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Team Lead-ni o\'chirish',
            style: TextStyle(color: Color(0xFF512D84)),
          ),
          content: Text(
              'Haqiqatan ham ${widget.teamLead['username']} ni o\'chirmoqchimisiz?'),
          actions: [
            TextButton(
              child: const Text('Bekor qilish',
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child:
                  const Text('O\'chirish', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await _firestore
                      .collection('users')
                      .doc(widget.teamLead['username'])
                      .delete();

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Dialog
                  Navigator.of(context).pop(); // Page

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Team Lead muvaffaqiyatli o\'chirildi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Xatolik yuz berdi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveTeamLead() async {
    try {
      // Avval team lead ma'lumotlarini Firestore-dan yangilab olamiz
      final teamLeadDoc = await _firestore
          .collection('users')
          .doc(widget.teamLead['username'])
          .get();

      if (!teamLeadDoc.exists) {
        throw Exception('Team lead topilmadi');
      }

      final teamLeadData = teamLeadDoc.data() as Map<String, dynamic>;
      print(
          'Firestore-dan olingan team lead ma\'lumotlari: $teamLeadData'); // Debug

      final batch = _firestore.batch();
      final teamLeadRef = teamLeadDoc.reference;

      // Team lead ma'lumotlarini yangilash
      batch.update(teamLeadRef, {
        'is_approved': true,
        'case': 'yes', // Case ni yes qilamiz
      });

      await batch.commit();

      // Telegram bot orqali xabar yuborish
      final telegramId = teamLeadData['telegram_id'];
      print('DEBUG: Telegram ID type: ${telegramId.runtimeType}');
      print('DEBUG: Telegram ID value: $telegramId');
      print('DEBUG: Full team lead data: $teamLeadData');

      if (telegramId != null) {
        final botToken = '8107824219:AAHOgdNra07L0ZoxHoN8mNfNAAvo_r_9y8k';
        final url =
            Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

        final message = '''
🎉 Tabriklaymiz ${teamLeadData['full_name']}!

Sizning Team Lead sifatidagi arizangiz tasdiqlandi.
Tizimga kirishingiz mumkin.

Username: ${teamLeadData['username']}
''';

        try {
          print('DEBUG: Sending Telegram message...');
          print('DEBUG: Bot Token: $botToken');
          print('DEBUG: URL: $url');
          print('DEBUG: Message: $message');

          // Telegram ID ni int ga o'tkazamiz
          int chatId = int.parse(telegramId.toString());
          print('DEBUG: Parsed chat ID: $chatId');

          final response = await http.post(
            url,
            body: {
              'chat_id': chatId.toString(),
              'text': message,
              'parse_mode': 'HTML',
            },
          );

          print('DEBUG: Response status code: ${response.statusCode}');
          print('DEBUG: Response body: ${response.body}');

          if (response.statusCode != 200) {
            print('ERROR: Telegram API error: ${response.body}');
            throw Exception(
                'Telegram xabar yuborishda xatolik: ${response.body}');
          } else {
            print('SUCCESS: Telegram message sent successfully!');
          }
        } catch (e) {
          print('Telegram xabar yuborishda xatolik: $e');
          throw e;
        }
      } else {
        print('Telegram ID topilmadi! Team Lead data: $teamLeadData');
        throw Exception('Team lead uchun Telegram ID topilmadi');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team lead tasdiqlandi va xabar yuborildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error approving team lead: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTeamLead() async {
    // Tasdiqlash dialogi
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Team Lead ni o\'chirish'),
              content: const Text(
                  'Haqiqatan ham bu Team Lead ni o\'chirmoqchimisiz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Bekor qilish'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'O\'chirish',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      try {
        // Team Lead ni o'chirish
        await _firestore
            .collection('users')
            .doc(widget.teamLead['username'])
            .delete();

        if (!mounted) return;
        // Asosiy sahifaga qaytish
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team Lead muvaffaqiyatli o\'chirildi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
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

  Widget _buildInfoSection(
      {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF512D84),
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF512D84)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Kiritilmagan' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLeadInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Lead ma\'lumotlari',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF512D84),
          ),
        ),
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Text(
            widget.teamLead['full_name']?.substring(0, 1).toUpperCase() ?? 'T',
            style: const TextStyle(
              fontSize: 40,
              color: Color(0xFF512D84),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.teamLead['full_name'] ?? 'Team Lead',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '@${widget.teamLead['username'] ?? ''}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoSection(
          title: 'Shaxsiy ma\'lumotlar',
          items: [
            _buildInfoItem(
              icon: Icons.location_on,
              title: 'Akademiya',
              value: widget.teamLead['academy_location'] ?? '',
            ),
            _buildInfoItem(
              icon: Icons.phone,
              title: 'Otasining telefoni',
              value: widget.teamLead['father_phone'] ?? '',
            ),
            _buildInfoItem(
              icon: Icons.phone,
              title: 'Onasining telefoni',
              value: widget.teamLead['mother_phone'] ?? '',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentDropdown() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // O'quvchilar ro'yxati
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .where('team_lead_username',
                  isEqualTo: widget.teamLead['username'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Xatolik yuz berdi');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final assignedStudents = snapshot.data?.docs ?? [];

            if (assignedStudents.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Hali o\'quvchilar biriktirilmagan'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignedStudents.length,
              itemBuilder: (context, index) {
                final student =
                    assignedStudents[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(student['full_name'] ?? 'Nomsiz'),
                  subtitle: Text('Sinf: ${student['grade'] ?? 'N/A'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => _removeStudent(assignedStudents[index].id),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        // Yangi o'quvchi qo'shish dropdown-i
        if (students.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Biriktirilishi mumkin bo\'lgan o\'quvchilar yo\'q',
                style: TextStyle(color: Colors.grey)),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedStudent?['username'],
            hint: const Text('Yangi o\'quvchi qo\'shish'),
            isExpanded: true,
            items: students.map((student) {
              final String displayText =
                  '${student['full_name']} (${student['grade']})';
              return DropdownMenuItem<String>(
                value: student['username'],
                child: Text(displayText),
              );
            }).toList(),
            onChanged: (String? username) {
              if (username != null) {
                print(
                    'DEBUG: Selected student username: $username'); // Debug log
                _assignStudent(username);
                setState(() => _selectedStudent = null);
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Team Lead Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
        actions: [
          if (!widget.isApproved)
            TextButton(
              onPressed: _approveTeamLead,
              child: const Text('Tasdiqlash',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTeamLeadInfo(),
              const SizedBox(height: 30),
              if (widget.isApproved) ...[
                _buildStudentDropdown(),
              ],
              if (!widget.isApproved)
                const Center(
                  child: Text(
                    'Team Lead hali tasdiqlanmagan',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _deleteTeamLead,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Team Lead ni o\'chirish',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
