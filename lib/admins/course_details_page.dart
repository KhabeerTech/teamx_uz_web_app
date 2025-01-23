import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_numbers_page.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key});

  Widget _buildCourseCard(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseNumbersPage(courseType: title),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Kurslar', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCourseCard(
                context,
                'Ingliz tili',
                const Color(0xFF388E3C),
              ),
              _buildCourseCard(
                context,
                'Shaxsiy rivojlanish',
                const Color(0xFF512D84),
              ),
              _buildCourseCard(
                context,
                'Kasb',
                const Color(0xFF1976D2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
