import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('O\'quvchilar', style: TextStyle(color: Colors.white)),
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

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 24,
              mainAxisSpacing: 12,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return StudentCard(
                name: userData['name'] ?? 'Noma\'lum',
                surname: userData['surname'] ?? 'Noma\'lum',
                username: userData['username'] ?? 'Noma\'lum',
                isAlternate: index % 2 == 0,
              );
            },
          );
        },
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String surname;
  final String username;
  final bool isAlternate;

  const StudentCard({
    super.key,
    required this.name,
    required this.surname,
    required this.username,
    required this.isAlternate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('O\'quvchi ma\'lumotlari'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ismi: $name'),
                  const SizedBox(height: 8),
                  Text('Familiyasi: $surname'),
                  const SizedBox(height: 8),
                  Text('Username: $username'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Yopish'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isAlternate
                ? const LinearGradient(
                    colors: [Color(0xFFE6E0EE), Color(0xFFEEE9F5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF512D84), Color(0xFF7646B8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: null,
            border: isAlternate
                ? Border.all(
                    color: Color(0xFF512D84).withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.person,
                size: 24,
                color: isAlternate ? const Color(0xFF512D84) : Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$name $surname',
                      style: TextStyle(
                        color: isAlternate
                            ? const Color(0xFF512D84)
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: TextStyle(
                        color: isAlternate
                            ? const Color(0xFF512D84).withOpacity(0.7)
                            : Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isAlternate
                    ? const Color(0xFF512D84).withOpacity(0.6)
                    : Colors.white60,
                size: 12,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
