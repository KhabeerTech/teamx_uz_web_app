import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegionsPage extends StatefulWidget {
  const RegionsPage({super.key});

  @override
  _RegionsPageState createState() => _RegionsPageState();
}

class _RegionsPageState extends State<RegionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _regionController = TextEditingController();
  List<Map<String, dynamic>> regions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    try {
      final QuerySnapshot regionsSnapshot =
          await _firestore.collection('regions').get();

      setState(() {
        regions = regionsSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading regions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addRegion() async {
    final regionName = _regionController.text.trim();
    if (regionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Region nomini kiriting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Check if region already exists
      final existingRegions = await _firestore
          .collection('regions')
          .where('name', isEqualTo: regionName)
          .get();

      if (existingRegions.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu region allaqachon mavjud'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Add new region using region name as document ID
      await _firestore.collection('regions').doc(regionName).set({
        'name': regionName,
        'created_at': Timestamp.now(),
      });

      _regionController.clear();
      _loadRegions();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Region muvaffaqiyatli qo\'shildi'),
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

  Future<void> _deleteRegion(String regionId) async {
    try {
      await _firestore.collection('regions').doc(regionId).delete();
      _loadRegions();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Region o\'chirildi'),
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

  Future<void> _showDeleteConfirmation(String regionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Regionni o\'chirish',
          style: TextStyle(
            color: Color(0xFF512D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Haqiqatan ham bu regionni o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Yo\'q',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ha'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _deleteRegion(regionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Regionlar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF512D84),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _regionController,
                    decoration: const InputDecoration(
                      labelText: 'Region nomi',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addRegion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF512D84),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Qo\'shish'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : regions.isEmpty
                    ? const Center(
                        child: Text(
                          'Hozircha regionlar yo\'q',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(region['name']),
                              subtitle: Text(
                                'Yaratilgan vaqti: ${(region['created_at'] as Timestamp).toDate().toString().split('.')[0]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _showDeleteConfirmation(region['id']),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
