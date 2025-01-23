import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseNumbersPage extends StatefulWidget {
  final String courseType;
  const CourseNumbersPage({required this.courseType, super.key});

  @override
  State<CourseNumbersPage> createState() => _CourseNumbersPageState();
}

class _CourseNumbersPageState extends State<CourseNumbersPage> {
  final _firestore = FirebaseFirestore.instance;
  final _linkController = TextEditingController();

  Future<void> _addTelegramLink(String range) async {
    try {
      await _firestore
          .collection('course')
          .doc(widget.courseType.toLowerCase())
          .set({
        range: [_linkController.text]
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telegram kanal linki qo\'shildi'),
            backgroundColor: Colors.green,
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

  Future<void> _editTelegramLink(String range, String oldLink) async {
    try {
      final doc =
          _firestore.collection('course').doc(widget.courseType.toLowerCase());

      await doc.update({
        range: FieldValue.arrayRemove([oldLink])
      });

      await doc.update({
        range: FieldValue.arrayUnion([_linkController.text])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link o\'zgartirildi'),
            backgroundColor: Colors.green,
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

  void _showLinkDialog(String range, {String? existingLink}) {
    _linkController.text = existingLink ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${range} uchun Telegram kanal'),
          content: TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              hintText: 'Telegram kanal linkini kiriting',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () {
                if (_linkController.text.isNotEmpty) {
                  if (existingLink != null) {
                    _editTelegramLink(range, existingLink);
                  } else {
                    _addTelegramLink(range);
                  }
                  _linkController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text(existingLink != null ? 'O\'zgartirish' : 'Saqlash'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumberContainer(String range) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('course')
          .doc(widget.courseType.toLowerCase())
          .snapshots(),
      builder: (context, snapshot) {
        final links = (snapshot.data?.data() as Map<String, dynamic>?)?[range]
                as List<dynamic>? ??
            [];
        final link = links.isNotEmpty ? links.first : null;

        return GestureDetector(
          onTap: link != null
              ? () => _showLinkDialog(range, existingLink: link)
              : () => _showLinkDialog(range),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF512D84),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                range,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle:
                  link != null ? Text(link) : const Text('Link kiritilmagan'),
              trailing: link != null
                  ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showLinkDialog(range, existingLink: link),
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_link),
                      onPressed: () => _showLinkDialog(range),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.courseType} kursi',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildNumberContainer('1-30'),
          _buildNumberContainer('31-60'),
          _buildNumberContainer('61-90'),
          _buildNumberContainer('91-120'),
          _buildNumberContainer('121-150'),
          _buildNumberContainer('151-180'),
          _buildNumberContainer('181-210'),
          _buildNumberContainer('211-240'),
          _buildNumberContainer('241-270'),
          _buildNumberContainer('271-300'),
          _buildNumberContainer('301-330'),
          _buildNumberContainer('331-360'),
          _buildNumberContainer('361-390'),
          _buildNumberContainer('391-420'),
          _buildNumberContainer('421-450'),
          _buildNumberContainer('451-480'),
          _buildNumberContainer('481-510'),
          _buildNumberContainer('511-540'),
          _buildNumberContainer('541-570'),
          _buildNumberContainer('571-600'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}
