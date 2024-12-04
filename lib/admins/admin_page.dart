import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamx_uz_web_app/admins/admin_settings.dart';
import 'package:teamx_uz_web_app/admins/students_page.dart';
import 'package:teamx_uz_web_app/admins/payments_page.dart';
import 'package:teamx_uz_web_app/admins/add_course_page.dart';

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

InputDecoration inputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle:
        const TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0), // Faqat chap va o'ng chetlarga padding
  );
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateUserCase(String username, String newCase) async {
    try {
      await _firestore
          .collection('users')
          .doc(username)
          .update({'case': newCase});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foydalanuvchi $username muvaffaqiyatli yangilandi'),
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

  Future<void> _editUserData(
      String oldUsername, Map<String, dynamic> userData) async {
    // Ma'lumotlarni xavfsiz olish
    final username = userData['username'] as String? ?? '';
    final password = userData['password'] as String? ?? '';
    final fullName = userData['full_name'] as String? ?? '';
    final grade = userData['grade']?.toString() ?? '';
    final region = userData['region'] as String? ?? '';
    final city = userData['city'] as String? ?? '';
    final schoolNumber = userData['school_number'] as String? ?? '';
    final fatherPhone = userData['father_phone'] as String? ?? '';
    final motherPhone = userData['mother_phone'] as String? ?? '';
    final branch = userData['branch'] as String? ?? '';

    final TextEditingController usernameController =
        TextEditingController(text: username);
    final TextEditingController passwordController =
        TextEditingController(text: password);
    final TextEditingController fullNameController =
        TextEditingController(text: fullName);
    final TextEditingController gradeController =
        TextEditingController(text: grade);
    final TextEditingController regionController =
        TextEditingController(text: region);
    final TextEditingController cityController =
        TextEditingController(text: city);
    final TextEditingController schoolNumberController =
        TextEditingController(text: schoolNumber);
    final TextEditingController fatherPhoneController =
        TextEditingController(text: fatherPhone);
    final TextEditingController motherPhoneController =
        TextEditingController(text: motherPhone);
    final TextEditingController branchController =
        TextEditingController(text: branch);

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Foydalanuvchi ma\'lumotlarini tahrirlash',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 24,
            color: const Color(0xFF512D84),
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: screenSize.width * (isSmallScreen ? 0.8 : 0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, 'Username', isSmallScreen),
                _buildTextField(passwordController, 'Parol', isSmallScreen),
                _buildTextField(
                    fullNameController, 'To\'liq ismi', isSmallScreen),
                _buildTextField(gradeController, 'Sinf', isSmallScreen,
                    isNumber: true),
                _buildTextField(regionController, 'Viloyat', isSmallScreen),
                _buildTextField(cityController, 'Shahar', isSmallScreen),
                _buildTextField(
                    schoolNumberController, 'Maktab raqami', isSmallScreen),
                _buildTextField(
                    fatherPhoneController, 'Otasining telefoni', isSmallScreen),
                _buildTextField(
                    motherPhoneController, 'Onasining telefoni', isSmallScreen),
                _buildTextField(branchController, 'Filial', isSmallScreen),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final newData = {
                  'username': usernameController.text,
                  'password': passwordController.text,
                  'full_name': fullNameController.text,
                  'grade': int.tryParse(gradeController.text),
                  'region': regionController.text,
                  'city': cityController.text,
                  'school_number': schoolNumberController.text,
                  'father_phone': fatherPhoneController.text,
                  'mother_phone': motherPhoneController.text,
                  'branch': branchController.text,
                };

                if (oldUsername != usernameController.text) {
                  await _firestore
                      .collection('users')
                      .doc(usernameController.text)
                      .set(newData);
                  await _firestore
                      .collection('users')
                      .doc(oldUsername)
                      .delete();
                } else {
                  await _firestore
                      .collection('users')
                      .doc(oldUsername)
                      .update(newData);
                }

                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('Ma\'lumotlar muvaffaqiyatli yangilandi'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                      bottom: screenSize.height * 0.02,
                      left: screenSize.width * 0.02,
                      right: screenSize.width * 0.02,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Xatolik yuz berdi: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                      bottom: screenSize.height * 0.02,
                      left: screenSize.width * 0.02,
                      right: screenSize.width * 0.02,
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Saqlash',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: const Color(0xFF512D84),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String username) async {
    try {
      // Foydalanuvchini o'chirish
      await _firestore.collection('users').doc(username).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foydalanuvchi $username muvaffaqiyatli o\'chirildi'),
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

  Future<void> _confirmDeleteUser(String username) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hisobni o\'chirish',
            style: TextStyle(color: Color(0xFF512D84)),
          ),
          content: Text('Haqiqatan ham $username hisobini o\'chirmoqchimisiz?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'O\'chirish',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(username);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isSmallScreen,
      {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8.0 : 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFF512D84),
            fontSize: isSmallScreen ? 14 : 16,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF512D84)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF512D84), width: 2),
          ),
        ),
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 1),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double animValue, child) {
          return Transform.rotate(
            angle: animValue * 2 * 3.14159,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: animValue * 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, color: color),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    Widget buildMenuContent({bool isDrawer = false}) {
      return Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            padding: const EdgeInsets.all(15),
            child: (!isSmallScreen && !isDrawer)
                ? const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  )
                : const Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'TeamX Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 30),
          // Menu items
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: true,
            isSmallScreen: !isDrawer && isSmallScreen,
          ),
          _buildMenuItem(
            icon: Icons.people,
            title: 'O\'quvchilar',
            isSelected: false,
            isSmallScreen: !isDrawer && isSmallScreen,
            onTap: () {
              if (isSmallScreen) {
                Navigator.pop(context); // Drawer'ni yopish
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentsPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'To\'lovlar',
            isSelected: false,
            isSmallScreen: !isDrawer && isSmallScreen,
            onTap: () {
              if (isSmallScreen) {
                Navigator.pop(context); // Drawer'ni yopish
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentsPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.add_circle,
            title: 'Kurs qo\'shish',
            isSelected: false,
            isSmallScreen: !isDrawer && isSmallScreen,
            onTap: () {
              if (isSmallScreen) {
                Navigator.pop(context); // Drawer'ni yopish
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCoursePage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Sozlamalar',
            isSelected: false,
            isSmallScreen: !isDrawer && isSmallScreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSettings(),
                ),
              );
              if (isSmallScreen) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const AdminSettings(),
                //   ),
                // ); // Drawer'ni yopish
              }
            },
          ),
          const Spacer(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Chiqish',
            isSelected: false,
            isSmallScreen: !isDrawer && isSmallScreen,
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return Scaffold(
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: const Color(0xFF512D84),
              title: const Text('TeamX Admin'),
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      drawer: isSmallScreen
          ? Drawer(
              child: Container(
                color: const Color(0xFF512D84),
                child: buildMenuContent(isDrawer: true),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            Container(
              width: 250,
              color: const Color(0xFF512D84),
              child: buildMenuContent(),
            ),
          // Asosiy content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top panel
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          'O\'quvchilar ro\'yxati',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF512D84),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  // Main content with StreamBuilder
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Xatolik yuz berdi',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF512D84),
                              ),
                            ),
                          );
                        }

                        final filteredDocs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['user_type'] != 'admin' &&
                              data['user_type'] != 'assistant';
                        }).toList();

                        // Statistikani hisoblash
                        int totalStudents = filteredDocs.length;
                        int approvedStudents = filteredDocs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['case'] == 'yes';
                        }).length;
                        int pendingStudents = totalStudents - approvedStudents;

                        return Column(
                          children: [
                            // Statistika paneli
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildStatCard(
                                      'Jami o\'quvchilar',
                                      totalStudents.toString(),
                                      Icons.people,
                                      const Color(0xFF512D84),
                                    ),
                                    const SizedBox(width: 20),
                                    _buildStatCard(
                                      'Tasdiqlangan',
                                      approvedStudents.toString(),
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                    const SizedBox(width: 20),
                                    _buildStatCard(
                                      'Kutilmoqda',
                                      pendingStudents.toString(),
                                      Icons.pending,
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // O'quvchilar ro'yxati
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: ListView.builder(
                                      itemCount: filteredDocs.length,
                                      itemBuilder: (context, index) {
                                        final doc = filteredDocs[index];
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        final username =
                                            data['username'] ?? 'Noma\'lum';
                                        final fullName =
                                            data['full_name'] ?? 'Noma\'lum';
                                        final userCase = data['case'] ?? 'no';

                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xFF512D84)
                                                      .withOpacity(0.1),
                                              child: Text(
                                                username[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color(0xFF512D84),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(username),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: userCase == 'yes'
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : Colors.orange
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: userCase == 'yes'
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    userCase == 'yes'
                                                        ? 'Tasdiqlangan'
                                                        : 'Kutilmoqda',
                                                    style: TextStyle(
                                                      color: userCase == 'yes'
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.edit,
                                                                  color: Color(
                                                                      0xFF512D84),
                                                                ),
                                                                title: const Text(
                                                                    'Tahrirlash'),
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  _editUserData(
                                                                      username,
                                                                      data);
                                                                },
                                                              ),
                                                              ListTile(
                                                                leading: Icon(
                                                                  userCase == 'yes'
                                                                      ? Icons
                                                                          .close
                                                                      : Icons
                                                                          .check,
                                                                  color: userCase ==
                                                                          'yes'
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green,
                                                                ),
                                                                title: Text(
                                                                  userCase ==
                                                                          'yes'
                                                                      ? 'Rad etish'
                                                                      : 'Tasdiqlash',
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  _updateUserCase(
                                                                    username,
                                                                    userCase ==
                                                                            'yes'
                                                                        ? 'no'
                                                                        : 'yes',
                                                                  );
                                                                },
                                                              ),
                                                              ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  'O\'chirish',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  _confirmDeleteUser(
                                                                      username);
                                                                },
                                                              ),
                                                            ],
                                                          ),
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
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isSmallScreen,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 15,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 24,
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
