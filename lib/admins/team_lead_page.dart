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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Lead'),
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
    );
  }

  Widget _buildTeamLeadList(List<QueryDocumentSnapshot> docs, bool isApproved) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
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
                if (!isApproved)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      try {
                        // Team Lead ma'lumotlarini olish
                        final teamLeadDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(docs[index].id)
                            .get();

                        if (!teamLeadDoc.exists) {
                          print('ERROR: Team lead topilmadi');
                          return;
                        }

                        final teamLeadData = teamLeadDoc.data()!;
                        print('DEBUG: Team Lead data: $teamLeadData');

                        // Ma'lumotlarni yangilash
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(docs[index].id)
                            .update({'is_approved': true, 'case': 'yes'});

                        // Telegram xabar yuborish
                        final telegramId = teamLeadData['telegram_id'];
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
                        print('ERROR: Team Lead tasdiqlashda xatolik: $e');
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(docs[index].id)
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
                    isApproved: isApproved,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
