import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'team_lead_details_page.dart';

class TeamLeadPage extends StatefulWidget {
  const TeamLeadPage({super.key});

  @override
  State<TeamLeadPage> createState() => _TeamLeadPageState();
}

class _TeamLeadPageState extends State<TeamLeadPage> {
  String? selectedTeamLead;
  String? _selectedRegion;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRegionSelectionDialog() async {
    final regionsSnapshot =
        await FirebaseFirestore.instance.collection('regions').get();
    final regions = regionsSnapshot.docs.map((doc) => doc.id).toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regionni tanlang'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: regions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(regions[index]),
                onTap: () {
                  setState(() {
                    _selectedRegion = regions[index];
                  });
                  Navigator.pop(context);
                  _showUserSelectionDialog();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showUserSelectionDialog() async {
    if (_selectedRegion == null) return;

    try {
      // Get all team leads first to check usernames
      final teamLeadsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'team_lead')
          .get();

      // Create a set of base usernames (without _TL suffix)
      final teamLeadBaseUsernames = teamLeadsSnapshot.docs
          .map((doc) => doc['username'].toString().replaceAll('_TL', ''))
          .toSet();

      // Get users from selected region
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('region', isEqualTo: _selectedRegion)
          .where('role', whereIn: ['student', 'teacher']).get();

      if (!mounted) return;

      // Filter out users who are already team leads
      final availableUsers = usersSnapshot.docs
          .where((doc) => !teamLeadBaseUsernames.contains(doc['username']))
          .toList();

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            // Qidiruv natijalarini filter qilish
            return AlertDialog(
              title: const Text('Foydalanuvchini tanlang'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Qidiruv maydoni
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Ism yoki username bo\'yicha qidirish...',
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
                    // Foydalanuvchilar ro'yxati
                    Expanded(
                      child: availableUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'Bu regionda mavjud foydalanuvchilar topilmadi',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: availableUsers.length,
                            itemBuilder: (context, index) {
                              final user = availableUsers[index].data();
                              final fullName = (user['full_name'] ?? '').toString().toLowerCase();
                              final username = (user['username'] ?? '').toString().toLowerCase();
                              
                              // Qidiruv filtri
                              if (_searchQuery.isNotEmpty &&
                                  !fullName.contains(_searchQuery) &&
                                  !username.contains(_searchQuery)) {
                                return const SizedBox.shrink();
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF512DA8),
                                  child: Text(
                                    user['full_name']
                                            ?.toString()
                                            .substring(0, 1)
                                            .toUpperCase() ??
                                        'N',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(user['full_name'] ?? 'Nomsiz'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('@${user['username'] ?? ''}'),
                                    Text('Role: ${user['role'] ?? 'N/A'}'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showAdditionalInfoDialog(user);
                                },
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bekor qilish'),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foydalanuvchilarni yuklashda xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAdditionalInfoDialog(Map<String, dynamic> userData) {
    final personalPhoneController = TextEditingController();
    final groupLinkController = TextEditingController();
    final groupIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qo\'shimcha ma\'lumotlar'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: personalPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Shaxsiy telefon raqami',
                  hintText: '+998901234567',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, telefon raqamini kiriting';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: groupLinkController,
                decoration: const InputDecoration(
                  labelText: 'Guruh linki',
                  hintText: 'https://t.me/...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, guruh linkini kiriting';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: groupIdController,
                decoration: const InputDecoration(
                  labelText: 'Guruh ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, guruh ID sini kiriting';
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
              if (formKey.currentState!.validate()) {
                final updatedUserData = Map<String, dynamic>.from(userData);
                updatedUserData['phone'] = personalPhoneController.text;
                updatedUserData['group_link'] = groupLinkController.text;
                updatedUserData['group_id'] = groupIdController.text;

                Navigator.pop(context);
                _createTeamLead(updatedUserData);
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _createTeamLead(Map<String, dynamic> userData) async {
    try {
      final newTeamLeadData = Map<String, dynamic>.from(userData);

      // Update username with _TL suffix
      newTeamLeadData['username'] = '${userData['username']}_TL';

      // Set team lead specific fields
      newTeamLeadData['role'] = 'team_lead';
      newTeamLeadData['case'] = 'yes';
      newTeamLeadData['is_approved'] = true;

      // Create new user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newTeamLeadData['username'])
          .set(newTeamLeadData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team Lead muvaffaqiyatli yaratildi'),
          backgroundColor: Color(0xFF512DA8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Team Lead', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'team_lead')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final approvedDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['is_approved'] == true;
          }).toList();
          final pendingDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['is_approved'] != true;
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (approvedDocs.isNotEmpty) ...[
                    const Text(
                      'Tasdiqlangan Team Lead-lar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: approvedDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            approvedDocs[index].data() as Map<String, dynamic>;
                        final isSelected = selectedTeamLead == data['username'];
                        return Card(
                          child: ListTile(
                            title: Text(
                              data['full_name'] ?? 'Noma\'lum',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('@${data['username'] ?? ''}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamLeadDetailsPage(
                                    teamLead: data,
                                    isApproved: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (selectedTeamLead != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text('Team Lead-ni o\'chirish'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Team Lead-ni o\'chirish'),
                                content: const Text(
                                    'Rostdan ham bu Team Lead-ni o\'chirmoqchimisiz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Bekor qilish'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(selectedTeamLead)
                                          .delete();
                                      if (mounted) {
                                        Navigator.pop(context);
                                        setState(() {
                                          selectedTeamLead = null;
                                        });
                                      }
                                    },
                                    child: const Text(
                                      'O\'chirish',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                  if (pendingDocs.isNotEmpty) ...[
                    const Text(
                      'Tasdiqlanmagan Team Lead-lar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            pendingDocs[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(data['full_name'] ?? 'Noma\'lum'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Username: ${data['username'] ?? ''}'),
                                Text(
                                    'Akademiya: ${data['branch']?.toString().toUpperCase() ?? 'Noma\'lum'} filiali'),
                                Text('Ota tel: ${data['father_phone'] ?? ''}'),
                                Text('Ona tel: ${data['mother_phone'] ?? ''}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () async {
                                    try {
                                      // Team Lead ma'lumotlarini olish
                                      final teamLeadDoc =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(data['username'])
                                              .get();

                                      if (!teamLeadDoc.exists) {
                                        print('ERROR: Team lead topilmadi');
                                        return;
                                      }

                                      final teamLeadData = teamLeadDoc.data()!;
                                      print(
                                          'DEBUG: Team Lead data: $teamLeadData');

                                      // Ma'lumotlarni yangilash
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(data['username'])
                                          .update({
                                        'is_approved': true,
                                        'case': 'yes'
                                      });

                                      // Telegram xabar yuborish
                                      final telegramId =
                                          teamLeadData['telegram_id'];
                                      print('DEBUG: Telegram ID: $telegramId');

                                      if (telegramId != null) {
                                        final botToken =
                                            '8107824219:AAHOgdNra07L0ZoxHoN8mNfNAAvo_r_9y8k';
                                        final url = Uri.parse(
                                            'https://api.telegram.org/bot$botToken/sendMessage');

                                        final message = '''
🎉 Tabriklaymiz ${teamLeadData['full_name']}!

Sizning Team Lead sifatidagi arizangiz tasdiqlandi.

Tizimga kirish uchun o'zingiz uchun yangi parol yarating:
/setpassword YANGI_PAROL

Masalan: /setpassword MyPassword123

Eslatma: 
- Parol kamida 6 ta belgidan iborat bo'lishi kerak
- Parolni yaratganingizdan so'ng tizimga kirishingiz mumkin bo'ladi

Username: ${teamLeadData['username']}
''';

                                        final response = await http.post(
                                          url,
                                          body: {
                                            'chat_id': telegramId.toString(),
                                            'text': message,
                                          },
                                        );

                                        print(
                                            'DEBUG: Telegram response: ${response.statusCode} - ${response.body}');

                                        if (response.statusCode != 200) {
                                          print(
                                              'ERROR: Telegram xabar yuborishda xatolik: ${response.body}');
                                        }
                                      }
                                    } catch (e) {
                                      print(
                                          'ERROR: Team Lead tasdiqlashda xatolik: $e');
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(data['username'])
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamLeadDetailsPage(
                                    teamLead: data,
                                    isApproved: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: ElevatedButton.icon(
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
        onPressed: _showRegionSelectionDialog,
        label: const Text(
          'Team Lead qo\'shish',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
