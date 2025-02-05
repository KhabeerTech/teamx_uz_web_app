import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_details_page.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: [
          // Qidiruv maydoni
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'O\'quvchi ismini yoki usernameni kiriting...',
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
          // O'quvchilar ro'yxati
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('case', isEqualTo: 'yes')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Xatolik yuz berdi'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final username = (data['username'] ?? '').toString().toLowerCase();
          final fullName = (data['full_name'] ?? '').toString().toLowerCase();
          
          return _searchQuery.isEmpty || 
                 username.contains(_searchQuery) || 
                 fullName.contains(_searchQuery);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
            vertical: MediaQuery.of(context).size.width < 600 ? 8 : 12,
          ),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final userData = filteredDocs[index].data() as Map<String, dynamic>;
            return Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width < 600 ? 8 : 12),
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
                  horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                  vertical: MediaQuery.of(context).size.width < 600 ? 4 : 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: index.isEven
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF512D84).withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color:
                        index.isEven ? Colors.white : const Color(0xFF512D84),
                    size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                  ),
                ),
                title: Text(
                  userData['full_name'] ?? 'Noma\'lum',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color:
                        index.isEven ? Colors.white : const Color(0xFF512D84),
                  ),
                ),
                subtitle: Text(
                  '@${userData['username'] ?? 'Noma\'lum'}',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                    color: index.isEven ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color:
                      index.isEven ? Colors.white60 : const Color(0xFF512D84),
                  size: MediaQuery.of(context).size.width < 600 ? 16 : 20,
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
    );
  }
}
