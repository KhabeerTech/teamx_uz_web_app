import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_details_page.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'O\'quvchilar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF512D84),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Xatolik yuz berdi'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: index.isEven
                      ? const LinearGradient(
                          colors: [Color(0xFF512D84), Color(0xFF7646B8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : const LinearGradient(
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
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 4 : 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: index.isEven
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF512D84).withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color:
                          index.isEven ? Colors.white : const Color(0xFF512D84),
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  title: Text(
                    userData['full_name'] ?? 'Noma\'lum',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w500,
                      color:
                          index.isEven ? Colors.white : const Color(0xFF512D84),
                    ),
                  ),
                  subtitle: Text(
                    '@${userData['username'] ?? 'Noma\'lum'}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: index.isEven ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color:
                        index.isEven ? Colors.white60 : const Color(0xFF512D84),
                    size: isMobile ? 16 : 20,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDetailsPage(
                          userData: userData,
                          studentId: userData['username'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
