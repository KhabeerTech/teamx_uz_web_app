import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _groupNameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _isCreatingGroup = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createNewGroup() async {
    if (_groupNameController.text.isEmpty) return;

    setState(() {
      _isCreatingGroup = true;
    });

    try {
      await _firestore.collection('groups').add({
        'name': _groupNameController.text,
        'created_at': FieldValue.serverTimestamp(),
        'students': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Guruh muvaffaqiyatli yaratildi',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.fromRGBO(236, 233, 76, 1),
          ),
        );
        _groupNameController.clear();
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
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingGroup = false;
        });
      }
    }
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Guruh o\'chirildi',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.fromRGBO(236, 233, 76, 1),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guruhlar',
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
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      hintText: 'Yangi guruh nomi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.group_add,
                        color: Color(0xFF512D84),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isCreatingGroup ? null : _createNewGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF512D84),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: isMobile ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreatingGroup
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Guruh yaratish',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Xatolik yuz berdi'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groups = snapshot.data?.docs ?? [];

                if (groups.isEmpty) {
                  return const Center(
                    child: Text('Hozircha guruhlar yo\'q'),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 8 : 16,
                  ),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final groupData = group.data() as Map<String, dynamic>;
                    final students = groupData['students'] as List? ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24,
                          vertical: isMobile ? 8 : 16,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: index.isEven
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF512D84).withOpacity(0.1),
                          child: Icon(
                            Icons.group,
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFF512D84),
                          ),
                        ),
                        title: Text(
                          groupData['name'] ?? 'Nomsiz guruh',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w500,
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFF512D84),
                          ),
                        ),
                        subtitle: Text(
                          '${students.length} ta o\'quvchi',
                          style: TextStyle(
                            color: index.isEven
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: index.isEven
                                ? Colors.white70
                                : const Color(0xFF512D84),
                          ),
                          onPressed: () => _deleteGroup(group.id),
                        ),
                        onTap: () {
                          // Group details page will be implemented later
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
