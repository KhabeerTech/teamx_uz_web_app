import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamLeadAssignPage extends StatefulWidget {
  final Map<String, dynamic> headTeacherData;
  final Map<String, dynamic> teamLeadData;

  const TeamLeadAssignPage({
    Key? key,
    required this.headTeacherData,
    required this.teamLeadData,
  }) : super(key: key);

  @override
  State<TeamLeadAssignPage> createState() => _TeamLeadAssignPageState();
}

class _TeamLeadAssignPageState extends State<TeamLeadAssignPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _assignedStudents = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load unassigned students with case=yes from the same region
      final studentsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('case', isEqualTo: 'yes')
          .where('region', isEqualTo: widget.headTeacherData['region'])
          .get();

      // Filter students that have no team_lead_username or team_lead_username is null
      final unassignedStudents = studentsQuery.docs.where((doc) {
        final data = doc.data();
        return !data.containsKey('team_lead_username') ||
            data['team_lead_username'] == null;
      });

      // Load assigned students for this team lead
      final assignedSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('region', isEqualTo: widget.headTeacherData['region'])
          .where('team_lead_username', isEqualTo: widget.teamLeadData['id'])
          .get();

      if (!mounted) return;

      setState(() {
        _students = unassignedStudents
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        _assignedStudents = assignedSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignStudent(Map<String, dynamic> student) async {
    try {
      final batch = _firestore.batch();

      // Update student
      final studentRef = _firestore.collection('users').doc(student['id']);
      batch.update(studentRef, {
        'team_lead_username': widget.teamLeadData['id'],
      });

      // Update team lead's students array
      final teamLeadRef =
          _firestore.collection('users').doc(widget.teamLeadData['id']);
      batch.update(teamLeadRef, {
        'students': FieldValue.arrayUnion([student['id']])
      });

      await batch.commit();

      setState(() {
        _assignedStudents
            .add({...student, 'team_lead_username': widget.teamLeadData['id']});
        _students.removeWhere((s) => s['id'] == student['id']);
      });

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

  Future<void> _removeStudent(Map<String, dynamic> student) async {
    try {
      final batch = _firestore.batch();

      // Update student
      final studentRef = _firestore.collection('users').doc(student['id']);
      batch.update(studentRef, {
        'team_lead_username': null,
      });

      // Update team lead's students array
      final teamLeadRef =
          _firestore.collection('users').doc(student['team_lead_username']);
      batch.update(teamLeadRef, {
        'students': FieldValue.arrayRemove([student['id']])
      });

      await batch.commit();

      setState(() {
        _students.add({...student, 'team_lead_username': null});
        _assignedStudents.removeWhere((s) => s['id'] == student['id']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O\'quvchi muvaffaqiyatli olib tashlandi'),
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

  Widget _buildStudentCard(Map<String, dynamic> student, bool isAssigned) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF512DA8),
          child: Text(
            student['full_name']?.toString().substring(0, 1).toUpperCase() ??
                'N',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(student['full_name'] ?? 'Nomsiz'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${student['username'] ?? ''}'),
            Text(
                'Tel: ${student['phone'] == 'N/A' || student['phone'] == null ? student['father_phone'] ?? 'N/A' : student['phone']}'),
            if (isAssigned)
              Text('Team Lead: ${student['team_lead_username'] ?? 'N/A'}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isAssigned ? Icons.remove_circle : Icons.add_circle,
            color: isAssigned ? Colors.red : Colors.green,
          ),
          onPressed: () {
            if (isAssigned) {
              _removeStudent(student);
            } else {
              _assignStudent(student);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
            '${widget.teamLeadData['full_name']} ga o\'quvchilarni biriktirish',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512DA8),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Mavjud o\'quvchilar'),
                            Tab(text: 'Biriktirilgan o\'quvchilar'),
                          ],
                          labelColor: Color(0xFF512DA8),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Available students tab
                              Column(
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
                                    child: _students.isEmpty
                                      ? const Center(
                                          child: Text('O\'quvchilar topilmadi'))
                                      : ListView.builder(
                                          itemCount: _students.length,
                                          itemBuilder: (context, index) {
                                            final student = _students[index];
                                            final fullName = (student['full_name'] ?? '').toString().toLowerCase();
                                            final username = (student['username'] ?? '').toString().toLowerCase();
                                            final phone = (student['phone'] ?? student['father_phone'] ?? '').toString().toLowerCase();

                                            if (_searchQuery.isNotEmpty &&
                                                !fullName.contains(_searchQuery) &&
                                                !username.contains(_searchQuery) &&
                                                !phone.contains(_searchQuery)) {
                                              return const SizedBox.shrink();
                                            }

                                            return _buildStudentCard(student, false);
                                          },
                                        ),
                                  ),
                                ],
                              ),
                              // Assigned students tab
                              Column(
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
                                    child: _assignedStudents.isEmpty
                                      ? const Center(
                                          child: Text('Biriktirilgan o\'quvchilar yo\'q'))
                                      : ListView.builder(
                                          itemCount: _assignedStudents.length,
                                          itemBuilder: (context, index) {
                                            final student = _assignedStudents[index];
                                            final fullName = (student['full_name'] ?? '').toString().toLowerCase();
                                            final username = (student['username'] ?? '').toString().toLowerCase();
                                            final phone = (student['phone'] ?? student['father_phone'] ?? '').toString().toLowerCase();

                                            if (_searchQuery.isNotEmpty &&
                                                !fullName.contains(_searchQuery) &&
                                                !username.contains(_searchQuery) &&
                                                !phone.contains(_searchQuery)) {
                                              return const SizedBox.shrink();
                                            }

                                            return _buildStudentCard(student, true);
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
