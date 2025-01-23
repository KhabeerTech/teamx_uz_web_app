import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'add_head_teacher_page.dart';
import 'add_team_lead_page.dart';

class HeadTeachersPage extends StatefulWidget {
  const HeadTeachersPage({super.key});

  @override
  _HeadTeachersPageState createState() => _HeadTeachersPageState();
}

class _HeadTeachersPageState extends State<HeadTeachersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _headTeachers = [];
  bool _isLoading = true;
  List<String> _regions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load regions
      final regionsSnapshot = await _firestore.collection('regions').get();
      _regions =
          regionsSnapshot.docs.map((doc) => doc['name'] as String).toList();
      _regions.sort();

      // Load head teachers
      final headTeachersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'head_teacher')
          .get();

      setState(() {
        _headTeachers = headTeachersSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editHeadTeacher(Map<String, dynamic> headTeacher) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: headTeacher['name']);
    final phoneController = TextEditingController(text: headTeacher['phone']);
    final passwordController = TextEditingController();
    String? selectedRegion = headTeacher['region'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Head Teacher tahrirlash',
          style: TextStyle(color: Color(0xFF512D84)),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ism',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, ismni kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon raqam',
                    border: OutlineInputBorder(),
                    hintText: '+998901234567',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$')),
                    LengthLimitingTextInputFormatter(13),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.length < 4 &&
                          !newValue.text.startsWith('+998')) {
                        return const TextEditingValue(
                          text: "+998",
                          selection: TextSelection.collapsed(offset: 4),
                        );
                      }
                      return newValue;
                    }),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, telefon raqamni kiriting';
                    }
                    if (!value.startsWith('+998')) {
                      return 'Raqam +998 bilan boshlanishi kerak';
                    }
                    if (value.length != 13) {
                      return 'Raqam 13 ta belgidan iborat bo\'lishi kerak';
                    }
                    final numberAfterCode = value.substring(4);
                    if (numberAfterCode.length != 9 ||
                        !RegExp(r'^\d{9}$').hasMatch(numberAfterCode)) {
                      return '+998 dan keyin 9 ta raqam kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Yangi parol (ixtiyoriy)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Filial joyi',
                    border: OutlineInputBorder(),
                  ),
                  items: _regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedRegion = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, filial joyini tanlang';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF512D84),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final updateData = {
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'region': selectedRegion,
                  };

                  if (passwordController.text.isNotEmpty) {
                    updateData['password'] = passwordController.text;
                  }

                  await _firestore
                      .collection('users')
                      .doc(headTeacher['id'])
                      .update(updateData);

                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  print('Error updating head teacher: $e');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Xatolik yuz berdi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadData(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Head Teacherlar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _headTeachers.isEmpty
                  ? const Center(
                      child: Text(
                        'Head teacherlar mavjud emas',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _headTeachers.length,
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: 80, // Pastda floating button uchun joy
                      ),
                      itemBuilder: (context, index) {
                        final headTeacher = _headTeachers[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF512D84),
                              child: Text(
                                headTeacher['name']
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(headTeacher['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Username: ${headTeacher['username']}'),
                                Text('Filial: ${headTeacher['region']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _editHeadTeacher(headTeacher),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HeadTeacherPage(
                                          username: headTeacher['username'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isDesktop = screenWidth > 600;

                  return SizedBox(
                    width: isDesktop
                        ? 800
                        : null, // Desktop da 400px, telefonda auto
                    height: isDesktop
                        ? 60
                        : null, // Desktop da 56px, telefonda auto
                    child: FloatingActionButton.extended(
                      backgroundColor: const Color(0xFF512D84),
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddHeadTeacherPage(),
                          ),
                        );
                        _loadData(); // Refresh the list after returning
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Head Teacher qo\'shish',
                        style: TextStyle(
                          fontSize:
                              isDesktop ? 18 : 14, // Desktop da kattaroq shrift
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeadTeacherPage extends StatefulWidget {
  final String username;
  const HeadTeacherPage({Key? key, required this.username}) : super(key: key);

  @override
  State<HeadTeacherPage> createState() => _HeadTeacherPageState();
}

class _HeadTeacherPageState extends State<HeadTeacherPage> {
  final _firestore = FirebaseFirestore.instance;
  String? _selectedRegion;
  List<String> _regions = [];
  String? _headTeacherRegion;

  @override
  void initState() {
    super.initState();
    _loadHeadTeacherData();
  }

  Future<void> _loadHeadTeacherData() async {
    try {
      final headTeacherDoc =
          await _firestore.collection('users').doc(widget.username).get();
      if (headTeacherDoc.exists) {
        setState(() {
          _headTeacherRegion = headTeacherDoc.data()?['region'] as String?;
        });
      }
    } catch (e) {
      print('Error loading head teacher data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Head Teacher Page'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Row(
        children: [
          // Left sidebar
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              // Handle navigation
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Asosiy'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Team Lead\'lar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Sozlamalar'),
              ),
            ],
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Team Lead section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Team Lead qo\'shish',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTeamLeadPage(
                                    headTeacherUsername: widget.username,
                                    headTeacherRegion: _headTeacherRegion ?? '',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Yangi Team Lead qo\'shish'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Team Leads list section
                  const Text(
                    'Team Lead\'lar ro\'yxati',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('users')
                          .where('role', isEqualTo: 'team_lead')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Xatolik yuz berdi: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final teamLeads = snapshot.data!.docs;

                        if (teamLeads.isEmpty) {
                          return const Center(
                            child: Text('Hozircha Team Lead\'lar yo\'q'),
                          );
                        }

                        return ListView.builder(
                          itemCount: teamLeads.length,
                          itemBuilder: (context, index) {
                            final teamLead = teamLeads[index];
                            final data =
                                teamLead.data() as Map<String, dynamic>;
                            final name = data['name'] as String? ?? 'Noma\'lum';
                            final username = data['username'] as String? ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Username: $username'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Edit team lead
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        // Delete team lead
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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
