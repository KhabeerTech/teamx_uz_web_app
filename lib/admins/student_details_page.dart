import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String studentId;

  const StudentDetailsPage({
    super.key,
    required this.userData,
    required this.studentId,
  });

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedDay1;
  String? _selectedDay2;
  String? _selectedTeamLeader;
  DateTime? _selectedPaymentDate;

  final List<String> _weekDays = [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ];

  Future<void> _editUserData(String oldUsername) async {
    final userData = widget.userData;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

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

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'O\'quvchi ma\'lumotlarini tahrirlash',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 24,
            color: const Color(0xFF512D84),
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: screenSize.width * (isSmallScreen ? 0.8 : 0.4),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, 'Username', isSmallScreen),
                _buildTextField(passwordController, 'Parol', isSmallScreen),
                _buildTextField(
                    fullNameController, 'To\'liq ism', isSmallScreen),
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
                Navigator.pop(context); // Orqaga qaytish
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ma\'lumotlar muvaffaqiyatli yangilandi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Xatolik yuz berdi: $e'),
                    backgroundColor: Colors.red,
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
      // Avval foydalanuvchi mavjudligini tekshirish
      final userDoc = await _firestore.collection('users').doc(username).get();

      if (!userDoc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foydalanuvchi topilmadi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // O'chirish
      await _firestore.collection('users').doc(username).delete();

      if (!mounted) return;
      // Muvaffaqiyatli o'chirildi
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$username muvaffaqiyatli o\'chirildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('O\'chirish xatosi: $e');
      if (!mounted) return;

      // Xato xabarini ko'rsatish
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'O\'chirishda xatolik yuz berdi. Qayta urinib ko\'ring'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Qayta urinish',
            textColor: Colors.white,
            onPressed: () => _deleteUser(username),
          ),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: const Color(0xFF512D84).withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF512D84), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF512D84),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDropdown(
      String label, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF512D84),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text('Kunni tanlang'),
              underline: Container(),
              items: _weekDays.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Firestore'dan kunlarni olish
    _selectedDay1 = widget.userData['day1'];
    _selectedDay2 = widget.userData['day2'];
    _selectedTeamLeader = widget.userData['team_leader'];
    // Initialize payment date
    if (widget.userData['payment_date'] != null) {
      _selectedPaymentDate =
          (widget.userData['payment_date'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'O\'quvchi ma\'lumotlari',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF512D84),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(widget.userData['username'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Xatolik yuz berdi: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF512D84),
              ),
            );
          }

          final userData =
              snapshot.data?.data() as Map<String, dynamic>? ?? widget.userData;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : screenWidth * 0.2,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF512D84), Color(0xFF7646B8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['full_name'] ?? 'Noma\'lum',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${userData['username'] ?? 'Noma\'lum'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard('Sinf', '${userData['grade'] ?? 'Noma\'lum'}'),
                _buildInfoCard('Viloyat', userData['region'] ?? 'Noma\'lum'),
                _buildInfoCard('Shahar', userData['city'] ?? 'Noma\'lum'),
                _buildInfoCard(
                    'Maktab', userData['school_number'] ?? 'Noma\'lum'),
                _buildInfoCard('Otasining telefoni',
                    userData['father_phone'] ?? 'Noma\'lum'),
                _buildInfoCard('Onasining telefoni',
                    userData['mother_phone'] ?? 'Noma\'lum'),
                _buildInfoCard('Filial', userData['branch'] ?? 'Noma\'lum'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF512D84).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF512D84),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'To\'lov sanasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF512D84),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedPaymentDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2025),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF512D84),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Color(0xFF512D84),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedPaymentDate = picked;
                            });
                            // Save to Firebase
                            await _firestore
                                .collection('users')
                                .doc(widget.studentId)
                                .update({
                              'payment_date': Timestamp.fromDate(picked),
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'To\'lov sanasi saqlandi',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(236, 233, 76, 1),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF512D84).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedPaymentDate != null
                                    ? '${_selectedPaymentDate!.day}/${_selectedPaymentDate!.month}/${_selectedPaymentDate!.year}'
                                    : 'Sanani tanlang',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedPaymentDate != null
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF512D84),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDayDropdown(
                  'Birinchi kelish kuni',
                  _selectedDay1,
                  (String? newValue) {
                    setState(() {
                      _selectedDay1 = newValue;
                    });
                    // Firestore'ga saqlash
                    _firestore
                        .collection('users')
                        .doc(userData['username'])
                        .update({'day1': newValue});
                  },
                ),
                _buildDayDropdown(
                  'Ikkinchi kelish kuni',
                  _selectedDay2,
                  (String? newValue) {
                    setState(() {
                      _selectedDay2 = newValue;
                    });
                    // Firestore'ga saqlash
                    _firestore
                        .collection('users')
                        .doc(userData['username'])
                        .update({'day2': newValue});
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8F0FF), Color(0xFFF0F7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF512D84).withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF512D84).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.supervisor_account,
                              color: Color(0xFF512D84),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Team Leader',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF512D84),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('user_type', isEqualTo: 'team_leader')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Xatolik yuz berdi');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF512D84),
                                ),
                              ),
                            );
                          }

                          final teamLeaders = snapshot.data?.docs ?? [];

                          if (teamLeaders.isEmpty) {
                            return const Text('Team leaderlar topilmadi');
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedTeamLeader,
                              decoration: InputDecoration(
                                labelText: 'Team Leader tanlang',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: teamLeaders.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem(
                                  value: data['username'] as String,
                                  child: Text(data['name'] ?? 'Nomsiz'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                if (newValue != null) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection(
                                            'users') // Changed from 'students' to 'users'
                                        .doc(widget.studentId)
                                        .update({
                                      'team_leader': newValue,
                                      'team_leader_update_time':
                                          FieldValue.serverTimestamp(),
                                    });

                                    setState(() {
                                      _selectedTeamLeader = newValue;
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Team Leader muvaffaqiyatli o\'zgartirildi',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          backgroundColor:
                                              Color.fromRGBO(236, 233, 76, 1),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Xatolik yuz berdi: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _editUserData(userData['username']),
                        icon: const Icon(Icons.edit, color: Color(0xFF512D84)),
                        label: const Text(
                          'Tahrirlash',
                          style: TextStyle(color: Color(0xFF512D84)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF512D84)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _confirmDeleteUser(userData['username']),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'O\'chirish',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
