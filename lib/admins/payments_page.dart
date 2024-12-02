import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _firestore = FirebaseFirestore.instance;

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          'To\'lovlar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF512D84),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Xatolik yuz berdi'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data?.docs ?? [];

          // Statistika hisoblash
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          int todayPayments = 0;
          int unpaidCount = 0;
          int upcomingPayments = 0;

          for (var student in students) {
            final data = student.data() as Map<String, dynamic>;
            final bool isPaid = data['isPaid'] ?? false;
            final Timestamp? paymentDate = data['payment_date'];

            if (paymentDate != null) {
              final date = paymentDate.toDate();
              if (date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day) {
                todayPayments++;
              }

              // Keyingi to'lov sanasi (30 kun)
              final nextPayment = date.add(const Duration(days: 30));
              if (nextPayment.difference(today).inDays <= 7 && isPaid) {
                upcomingPayments++;
              }
            }

            if (!isPaid) {
              unpaidCount++;
            }
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Bugungi to\'lovlar',
                        '$todayPayments ta',
                        const Color(0xFF512D84),
                        Icons.today,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'To\'lov qilmaganlar',
                        '$unpaidCount ta',
                        Colors.red,
                        Icons.warning,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Yaqinlashayotgan to\'lovlar',
                        '$upcomingPayments ta',
                        Colors.orange,
                        Icons.schedule,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final userData =
                        snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final bool isPaid = userData['isPaid'] ?? false;
                    final Timestamp? paymentDate = userData['payment_date'];
                    final String formattedDate = paymentDate != null
                        ? '${paymentDate.toDate().day}/${paymentDate.toDate().month}/${paymentDate.toDate().year}'
                        : 'Belgilanmagan';

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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: index.isEven
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF512D84).withOpacity(0.1),
                          child: Icon(
                            isPaid ? Icons.check_circle : Icons.pending,
                            color:
                                index.isEven ? Colors.white : const Color(0xFF512D84),
                            size: isMobile ? 20 : 24,
                          ),
                        ),
                        title: Text(
                          userData['full_name'] ?? 'Noma\'lum',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color:
                                index.isEven ? Colors.white : const Color(0xFF512D84),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To\'lov sanasi: $formattedDate',
                              style: TextStyle(
                                color: index.isEven
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              '@${userData['username'] ?? 'Noma\'lum'}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: index.isEven ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _updatePaymentStatus(
                              snapshot.data!.docs[index].id, !isPaid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPaid
                                ? Colors.green.withOpacity(0.8)
                                : Colors.orange.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isPaid ? 'To\'langan' : 'To\'lanmagan',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updatePaymentStatus(String id, bool isPaid) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'isPaid': isPaid,
        'payment_date': isPaid ? FieldValue.serverTimestamp() : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPaid ? 'To\'lov tasdiqlandi' : 'To\'lov bekor qilindi',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: const Color.fromRGBO(236, 233, 76, 1),
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
}
