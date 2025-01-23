import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _linkController = TextEditingController();

  Future<void> _addTelegramLink(String courseType, String link) async {
    try {
      await _firestore.collection('tg_links').doc(courseType).set({
        'links': FieldValue.arrayUnion([link])
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telegram kanal linki qo\'shildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

  void _showLinkDialog(String courseType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$courseType uchun Telegram kanal'),
          content: TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              hintText: 'Telegram kanal linkini kiriting',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () {
                if (_linkController.text.isNotEmpty) {
                  _addTelegramLink(courseType, _linkController.text);
                  _linkController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseContainer(String title, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('tg_links')
                  .doc(title.toLowerCase())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Xatolik yuz berdi');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final links = (snapshot.data?.data()
                        as Map<String, dynamic>?)?['links'] as List<dynamic>? ??
                    [];

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: links.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(links[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _firestore
                                    .collection('tg_links')
                                    .doc(title.toLowerCase())
                                    .update({
                                  'links':
                                      FieldValue.arrayRemove([links[index]])
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showLinkDialog(title.toLowerCase()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Telegram kanal qo\'shish',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurslar', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCourseContainer(
            'Shaxsiy rivojlanish',
            const Color(0xFF512D84),
          ),
          _buildCourseContainer(
            'Kasb',
            const Color(0xFF1976D2),
          ),
          _buildCourseContainer(
            'Ingliz tili',
            const Color(0xFF388E3C),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:teamx_uz_web_app/admins/course_details_page.dart';

// class AddCoursePage extends StatefulWidget {
//   const AddCoursePage({super.key});

//   @override
//   State<AddCoursePage> createState() => _AddCoursePageState();
// }

// class _AddCoursePageState extends State<AddCoursePage> {
//   final _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = screenWidth < 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Kurslar',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF512D84),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('users')
//             .where('case', isEqualTo: 'yes')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Xatolik yuz berdi'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final users = snapshot.data!.docs;

//           return ListView.builder(
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 8 : 12,
//             ),
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               final userData = users[index].data() as Map<String, dynamic>;
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CourseDetailsPage(
//                           // courseData: userData,
//                           // userId: users[index].id, // Use document ID directly from QueryDocumentSnapshot
//                           ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
//                   decoration: BoxDecoration(
//                     gradient: index.isEven
//                         ? const LinearGradient(
//                             colors: [Color(0xFF512D84), Color(0xFF7646B8)],
//                             begin: Alignment.centerLeft,
//                             end: Alignment.centerRight,
//                           )
//                         : const LinearGradient(
//                             colors: [Color(0xFFF8F0FF), Color(0xFFF0F7FF)],
//                             begin: Alignment.centerLeft,
//                             end: Alignment.centerRight,
//                           ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFF512D84).withOpacity(0.1),
//                       width: 1,
//                     ),
//                   ),
//                   child: ListTile(
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 12 : 16,
//                       vertical: isMobile ? 4 : 8,
//                     ),
//                     leading: CircleAvatar(
//                       backgroundColor: index.isEven
//                           ? Colors.white.withOpacity(0.2)
//                           : const Color(0xFF512D84).withOpacity(0.1),
//                       child: Icon(
//                         Icons.person,
//                         color: index.isEven
//                             ? Colors.white
//                             : const Color(0xFF512D84),
//                         size: isMobile ? 20 : 24,
//                       ),
//                     ),
//                     title: Text(
//                       userData['full_name'] ?? 'Noma\'lum',
//                       style: TextStyle(
//                         fontSize: isMobile ? 14 : 16,
//                         fontWeight: FontWeight.w500,
//                         color: index.isEven
//                             ? Colors.white
//                             : const Color(0xFF512D84),
//                       ),
//                     ),
//                     subtitle: Text(
//                       '@${userData['username'] ?? 'Noma\'lum'}',
//                       style: TextStyle(
//                         fontSize: isMobile ? 12 : 14,
//                         color: index.isEven ? Colors.white70 : Colors.grey[600],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
