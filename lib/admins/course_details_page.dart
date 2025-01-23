import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamx_uz_web_app/admins/add_course_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final String userId;

  const CourseDetailsPage({
    super.key,
    required this.courseData,
    required this.userId,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;
  String? _selectedEnglish;
  String? _selectedPersonalDev;
  String? _selectedProfession;
  String? _selectedProgrammingType;
  String? _selectedTradingType;
  List<Map<String, dynamic>> _existingCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingCourses();
    _loadExistingCourseData();
  }

  Future<void> _loadExistingCourses() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists && userDoc.data()?['courses'] != null) {
        setState(() {
          _existingCourses =
              List<Map<String, dynamic>>.from(userDoc.data()?['courses'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kurslarni yuklashda xatolik yuz berdi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadExistingCourseData() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();

      if (userDoc.exists && userDoc.data()?['courses'] != null) {
        final courses =
            List<Map<String, dynamic>>.from(userDoc.data()?['courses'] ?? []);

        if (courses.isNotEmpty) {
          final latestCourse = courses.last; // Get the most recent course

          setState(() {
            // Load English course
            if (latestCourse['english_course'] != null) {
              _selectedEnglish = latestCourse['english_course']['name'];
            }

            // Load Personal Development
            if (latestCourse['personal_development'] != null) {
              _selectedPersonalDev =
                  latestCourse['personal_development']['name'];
            }

            // Load Profession and its subtypes
            if (latestCourse['profession'] != null) {
              _selectedProfession = latestCourse['profession']['name'];

              // Load Programming type if profession is Dasturlash
              if (_selectedProfession == 'Dasturlash' &&
                  latestCourse['programming_type'] != null) {
                _selectedProgrammingType =
                    latestCourse['programming_type']['name'];
              }

              // Load Trading type if profession is Trading
              if (_selectedProfession == 'Trading' &&
                  latestCourse['trading_type'] != null) {
                _selectedTradingType = latestCourse['trading_type']['name'];
              }
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kurs ma\'lumotlarini yuklashda xatolik yuz berdi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCourseTypeText(Map<String, dynamic> course) {
    if (course['english_course'] != null) {
      return 'Ingliz tili: ${course['english_course']['name']}';
    } else if (course['personal_development'] != null) {
      return 'Shaxsiy rivojlanish: ${course['personal_development']['name']}';
    } else if (course['profession'] != null) {
      String text = 'Kasb: ${course['profession']['name']}';
      if (course['programming_type'] != null) {
        text += ' - ${course['programming_type']['name']}';
      } else if (course['trading_type'] != null) {
        text += ' - ${course['trading_type']['name']}';
      }
      return text;
    }
    return 'Noma\'lum kurs';
  }

  Future<void> _saveCourse() async {
    if (_selectedEnglish == null &&
        _selectedPersonalDev == null &&
        _selectedProfession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, kamida bitta kursni tanlang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      Map<String, dynamic> courseData = {
        'created_at': DateTime.now().toIso8601String(),
        'active': true,
      };

      if (_selectedEnglish != null && _selectedEnglish!.isNotEmpty) {
        courseData['english_course'] = {'name': _selectedEnglish};
      }

      if (_selectedPersonalDev != null && _selectedPersonalDev!.isNotEmpty) {
        courseData['personal_development'] = {'name': _selectedPersonalDev};
      }

      if (_selectedProfession != null && _selectedProfession!.isNotEmpty) {
        courseData['profession'] = {'name': _selectedProfession};

        if (_selectedProfession == 'Dasturlash' &&
            _selectedProgrammingType != null &&
            _selectedProgrammingType!.isNotEmpty) {
          courseData['programming_type'] = {'name': _selectedProgrammingType};
        }

        if (_selectedProfession == 'Trading' &&
            _selectedTradingType != null &&
            _selectedTradingType!.isNotEmpty) {
          courseData['trading_type'] = {'name': _selectedTradingType};
        }
      }

      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        List<Map<String, dynamic>> existingCourses =
            List<Map<String, dynamic>>.from(userDoc.data()?['courses'] ?? []);

        bool courseExists = existingCourses.any((course) {
          bool basicMatch = (course['english_course']?['name'] ==
                  courseData['english_course']?['name']) &&
              (course['personal_development']?['name'] ==
                  courseData['personal_development']?['name']) &&
              (course['profession']?['name'] ==
                  courseData['profession']?['name']);

          if (!basicMatch) return false;

          if (courseData['programming_type'] != null ||
              course['programming_type'] != null) {
            if (course['programming_type']?['name'] !=
                courseData['programming_type']?['name']) {
              return false;
            }
          }

          if (courseData['trading_type'] != null ||
              course['trading_type'] != null) {
            if (course['trading_type']?['name'] !=
                courseData['trading_type']?['name']) {
              return false;
            }
          }

          return true;
        });

        if (!courseExists) {
          existingCourses.add(courseData);
          await _firestore.collection('users').doc(widget.userId).update({
            'courses': existingCourses,
          });
        }

        setState(() {
          _isSaving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saqlandi'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );

          // Wait for snackbar to show before navigating
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AddCoursePage(),
                ),
              );
            }
          });
        }
      } else {
        throw Exception('Foydalanuvchi topilmadi');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xatolik yuz berdi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSelections() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Kurslarni bekor qilish',
            style: TextStyle(color: Color(0xFF512D84)),
          ),
          content: const Text(
              'Haqiqatan ham barcha tanlangan kurslarni bekor qilmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Yo\'q',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedEnglish = null;
                  _selectedPersonalDev = null;
                  _selectedProfession = null;
                  _selectedProgrammingType = null;
                  _selectedTradingType = null;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Barcha kurslar bekor qilindi',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text(
                'Ha',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? emptyMessage,
  }) {
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
              hint: Text(emptyMessage ?? 'Tanlang'),
              underline: Container(),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
            if (value == null && emptyMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  emptyMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kurs ma\'lumotlari',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF512D84),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : screenWidth * 0.2,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF512D84)),
                ),
              ),
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
                      Icons.school,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Yangi kurs qo\'shish',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdown(
              label: 'Ingliz tili',
              value: _selectedEnglish,
              items: const ['Ingliz tili'],
              onChanged: (value) {
                setState(() {
                  _selectedEnglish = value;
                });
              },
              emptyMessage: 'Kurs yo\'q',
            ),
            _buildDropdown(
              label: 'Shaxsiy rivojlanish',
              value: _selectedPersonalDev,
              items: const ['Shaxsiy rivojlanish'],
              onChanged: (value) {
                setState(() {
                  _selectedPersonalDev = value;
                });
              },
              emptyMessage: 'Kurs yo\'q',
            ),
            _buildDropdown(
              label: 'Kasblar',
              value: _selectedProfession,
              items: const ['Dasturlash', 'Dizayn', 'Marketing', 'Trading'],
              onChanged: (value) {
                setState(() {
                  _selectedProfession = value;
                  // Reset sub-selections when main selection changes
                  _selectedProgrammingType = null;
                  _selectedTradingType = null;
                });
              },
              emptyMessage: 'Kurs yo\'q',
            ),
            if (_selectedProfession == 'Dasturlash')
              _buildDropdown(
                label: 'Dasturlash turi',
                value: _selectedProgrammingType,
                items: const ['Flutter', 'Full Stack'],
                onChanged: (value) {
                  setState(() {
                    _selectedProgrammingType = value;
                  });
                },
                emptyMessage: null,
              ),
            if (_selectedProfession == 'Trading')
              _buildDropdown(
                label: 'Trading turi',
                value: _selectedTradingType,
                items: const ['Stock', 'Crypto'],
                onChanged: (value) {
                  setState(() {
                    _selectedTradingType = value;
                  });
                },
                emptyMessage: null,
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF512D84),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
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
                            'Kursni saqlash',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearSelections,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bekor qilish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
