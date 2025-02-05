import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'english_course_page.dart';
import 'coming_soon_page.dart';

class MyCoursesPage extends StatefulWidget {
  final String username;
  const MyCoursesPage({required this.username, super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  int userStep = 1;
  Map<int, bool> expandedContainers = {};
  Map<String, bool> expandedCourses = {
    'english': false,
    'personal': false,
    'career': false,
  };

  Color _getContainerColor(int startStep, int endStep) {
    // Agar qadam 0 yoki 1 bo'lsa yoki umuman bo'lmasa, birinchi container yashil
    if ((userStep == 0 || userStep == 1) && startStep == 1) {
      return const Color(0xFF00BF63);
    }

    // Agar foydalanuvchining qadami shu konteynerning oxirgi qadamidan katta bo'lsa,
    // bu va undan oldingi barcha konteynerlar yashil bo'lishi kerak
    if (startStep <= userStep) {
      return const Color(0xFF00BF63);
    }

    // Agar foydalanuvchining qadami shu konteyner oralig'ida bo'lsa,
    // bu konteynerni ham yashil qilish kerak
    if (userStep >= startStep && userStep <= endStep) {
      return const Color(0xFF00BF63);
    }

    // Boshqa barcha containerlar binafsha rangda
    return const Color(0xFF8C52FF);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserStep();
  }

  Future<void> _fetchUserStep() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.username)
          .get();

      if (userDoc.exists && userDoc.data()?['steps'] != null) {
        setState(() {
          userStep = userDoc.data()?['steps'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching user step: $e');
    }
  }

  Widget _buildStepGrid(int startStep) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double buttonSize = (screenWidth * 0.85) / 10;
    double fontSize = screenWidth <= 500 ? 14 : 16;

    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 240, 255),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF8C52FF),
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        alignment: WrapAlignment.center,
        children: List.generate(30, (index) {
          final stepNumber = startStep + index;
          Color buttonColor;

          // Agar foydalanuvchi shu konteynerdan o'tib ketgan bo'lsa
          if (userStep > startStep + 29) {
            buttonColor = const Color(0xFF00BF63); // Hammasi yashil
          }
          // Agar foydalanuvchi shu konteyner ichida bo'lsa
          else if (userStep >= startStep && userStep <= startStep + 29) {
            if (stepNumber <= userStep) {
              buttonColor = const Color(0xFF00BF63); // O'tgan qadamlar yashil
            } else if (stepNumber <= userStep + 3) {
              buttonColor = const Color(0xFFFFA726); // Keyingi 3 ta sariq
            } else {
              buttonColor = Colors.white; // Qolganlari oq
            }
          }
          // Agar foydalanuvchi bu konteynergacha yetib kelmagan bo'lsa
          else {
            buttonColor = Colors.white; // Hammasi oq
          }

          return Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: buttonColor == Colors.white ? Colors.grey : buttonColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      buttonColor == Colors.white ? Colors.black : Colors.white,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCourseButton(String title, Color color, VoidCallback? onTap) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    double fontSize = screenWidth <= 500 ? 16 : 20;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.06,
        margin: EdgeInsets.symmetric(
          vertical: screenHeight * 0.005,
          horizontal: screenWidth * 0.005,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Nexa',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContainer(int startStep, int endStep, bool isLocked) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    double fontSize = screenWidth <= 500 ? 18 : 24;

    return Column(
      children: [
        GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnglishCoursePage(
                        startStep: startStep,
                        userStep: userStep,
                      ),
                    ),
                  );
                },
          child: Container(
            width: screenWidth * 0.98,
            height: screenHeight * 0.08,
            margin: EdgeInsets.symmetric(
              vertical: screenHeight * 0.01,
              horizontal: screenWidth * 0.005,
            ),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color.fromRGBO(200, 200, 200, 1)
                  : _getContainerColor(startStep, endStep),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isLocked
                    ? const Color.fromRGBO(200, 200, 200, 1)
                    : _getContainerColor(startStep, endStep),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLocked)
                  Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: fontSize * 1.2,
                  ),
                SizedBox(width: isLocked ? 16 : 0),
                Text(
                  '$startStep - $endStep qadamlar',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'Nexa',
                    fontWeight: FontWeight.w800,
                    color: isLocked ? Colors.grey : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepContainer() {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    double fontSize = screenWidth <= 500 ? 18 : 24;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.username)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final currentStep = userData['steps'] ?? 0;
        final startDate = userData['start_date'] as String?;
        final expectedStep = _calculateExpectedStep(startDate);

        return Column(
          children: [
           
            Container(
              width: screenWidth * 0.98,
              height: screenHeight * 0.08,
              margin: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.005,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8C52FF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF8C52FF),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tartib bo’yicha: $expectedStep-qadam',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Nexa',
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ), Container(
              width: screenWidth * 0.98,
              height: screenHeight * 0.08,
              margin: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.005,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8C52FF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF8C52FF),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hozirgi qadam: $currentStep-qadam',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Nexa',
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _calculateExpectedStep(String? startDateStr) {
    if (startDateStr == null) return '0';
    
    try {
      // Sanani parse qilish (format: dd.MM.yyyy)
      final dateParts = startDateStr.split('.');
      if (dateParts.length != 3) return '0';
      
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      
      final startDate = DateTime(year, month, day);
      final today = DateTime.now();
      
      // Kunlar farqini hisoblash
      final difference = today.difference(startDate).inDays;
      
      // Har kuni 1 qadam
      final expectedStep = difference + 1; // Bugungi kun ham hisoblanadi
      
      // 600 dan oshib ketmasligi kerak
      return expectedStep > 600 ? '600' : expectedStep.toString();
      
    } catch (e) {
      print('Sana parse qilishda xatolik: $e');
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;

    List<Widget> buildStepContainers() {
      List<Widget> containers = [];
      for (int i = 0; i < 600; i += 30) {
        final startStep = i + 1;
        final endStep = i + 30;
        // Agar foydalanuvchining qadami shu konteynerning boshlanish qadamidan katta bo'lsa,
        // yoki shu konteynerni ichida bo'lsa, konteyner ochiq bo'lishi kerak
        final isLocked = (userStep < startStep) && userStep != 0;

        containers.add(_buildStepContainer(startStep, endStep, isLocked));
      }
      return containers;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Qadamlarim',
          style: TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.w800,
            color: Color(0xFF512D84),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF512D84)),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 249, 248, 198),
              Color.fromARGB(255, 218, 200, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.01,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCurrentStepContainer(),
                ...buildStepContainers(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
