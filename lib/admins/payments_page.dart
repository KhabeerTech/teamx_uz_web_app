import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _firestore = FirebaseFirestore.instance;

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
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

  void _showPaymentDetails(
      BuildContext context, Map<String, dynamic> userData) {
    final lastPaymentDate = userData['payment_date'] as Timestamp?;
    final nextPaymentDate =
        lastPaymentDate?.toDate().add(const Duration(days: 30));
    final paymentHistory =
        (userData['payment_history'] as List<dynamic>?) ?? [];

    // isPaid ni to'g'ri formatda olish
    bool isPaid = false;
    if (userData['isPaid'] != null) {
      isPaid = userData['isPaid'] is bool
          ? userData['isPaid'] as bool
          : userData['isPaid'].toString().toLowerCase() == 'true';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${userData['full_name'] ?? 'Noma\'lum'} - To\'lov ma\'lumotlari'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'To\'lov holati:',
                  isPaid ? 'To\'langan ✓' : 'To\'lanmagan ✗',
                  isPaid ? Colors.green : Colors.red),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Oxirgi to\'lov:',
                  lastPaymentDate != null
                      ? '${lastPaymentDate.toDate().day}/${lastPaymentDate.toDate().month}/${lastPaymentDate.toDate().year}'
                      : 'Mavjud emas'),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Keyingi to\'lov:',
                  nextPaymentDate != null
                      ? '${nextPaymentDate.day}/${nextPaymentDate.month}/${nextPaymentDate.year}'
                      : 'Mavjud emas'),
              if (userData['username'] != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Username:', '@${userData['username']}'),
              ],
              if (paymentHistory.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'To\'lovlar tarixi:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...paymentHistory.map((payment) {
                  final paymentDate = payment['date'] as Timestamp;
                  final paidAt = payment['paid_at'] as Timestamp;
                  final amount = payment['amount'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${_formatDate(paymentDate)} - $amount so\'m\n'
                      'To\'lov vaqti: ${_formatDateTime(paidAt)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showTodayPayments(
      BuildContext context, List<QueryDocumentSnapshot> students) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Bugungi to'lovlarni filtrlash
    final todayPayments = students.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final paymentDate = data['payment_date'] as Timestamp?;

      if (paymentDate != null) {
        final paymentDay = DateTime(
          paymentDate.toDate().year,
          paymentDate.toDate().month,
          paymentDate.toDate().day,
        );

        // Bugungi to'lovlarni olish
        return paymentDay.year == today.year &&
            paymentDay.month == today.month &&
            paymentDay.day == today.day;
      }
      return false;
    }).toList();

    // To'lov qilganlar va qilmaganlarni hisoblash
    int totalPayments = todayPayments.length;
    int paidCount = 0;

    for (var doc in todayPayments) {
      final data = doc.data() as Map<String, dynamic>;
      final lastPaymentDate = data['last_payment_date'] as Timestamp?;

      if (lastPaymentDate != null) {
        final lastPaymentDay = DateTime(
          lastPaymentDate.toDate().year,
          lastPaymentDate.toDate().month,
          lastPaymentDate.toDate().day,
        );
        if (lastPaymentDay.year == today.year &&
            lastPaymentDay.month == today.month &&
            lastPaymentDay.day == today.day) {
          paidCount++;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bugungi to\'lovlar'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$paidCount/$totalPayments',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: todayPayments.length,
            itemBuilder: (context, index) {
              final data = todayPayments[index].data() as Map<String, dynamic>;
              final lastPaymentDate = data['last_payment_date'] as Timestamp?;

              // Bugun to'lov qilganmi tekshirish
              bool paidToday = false;
              if (lastPaymentDate != null) {
                final lastPaymentDay = DateTime(
                  lastPaymentDate.toDate().year,
                  lastPaymentDate.toDate().month,
                  lastPaymentDate.toDate().day,
                );
                paidToday = lastPaymentDay.year == today.year &&
                    lastPaymentDay.month == today.month &&
                    lastPaymentDay.day == today.day;
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    data['full_name'] ?? 'Noma\'lum',
                    style: TextStyle(
                      fontWeight:
                          paidToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tel: ${data['phone'] ?? 'Mavjud emas'}'),
                      if (paidToday && lastPaymentDate != null)
                        Text(
                          'To\'lov vaqti: ${_formatDateTime(lastPaymentDate)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                  trailing: paidToday
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'To\'langan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _updatePaymentStatus(todayPayments[index].id, true);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(236, 233, 76, 1),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('To\'lov qilindi'),
                        ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showUnpaidPayments(
      BuildContext context, List<QueryDocumentSnapshot> students) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // To'lov qilmagan va muddati o'tgan o'quvchilarni filtrlash
    final unpaidPayments = students.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final paymentDate = data['payment_date'] as Timestamp?;

      // isPaid ni tekshirish
      bool isPaid = false;
      if (data['isPaid'] != null) {
        isPaid = data['isPaid'] is bool
            ? data['isPaid'] as bool
            : data['isPaid'].toString().toLowerCase() == 'true';
      }

      if (paymentDate != null && !isPaid) {
        final paymentDay = DateTime(
          paymentDate.toDate().year,
          paymentDate.toDate().month,
          paymentDate.toDate().day,
        );

        return paymentDay.isBefore(today); // Muddati o'tgan
      }
      return false;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('To\'lov qilmaganlar'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unpaidPayments.length,
            itemBuilder: (context, index) {
              final data = unpaidPayments[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['full_name'] ?? 'Noma\'lum'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tel: ${data['phone'] ?? 'Mavjud emas'}'),
                      Text(
                          'To\'lov sanasi: ${_formatDate(data['payment_date'] as Timestamp?)}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _updatePaymentStatus(unpaidPayments[index].id, true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(236, 233, 76, 1),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('To\'lov qilindi'),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showTomorrowPayments(
      BuildContext context, List<QueryDocumentSnapshot> students) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    // Ertangi to'lovlarni filtrlash
    final tomorrowPayments = students.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final paymentDate = data['payment_date'] as Timestamp?;

      if (paymentDate != null) {
        final paymentDay = DateTime(
          paymentDate.toDate().year,
          paymentDate.toDate().month,
          paymentDate.toDate().day,
        );

        return paymentDay.year == tomorrow.year &&
            paymentDay.month == tomorrow.month &&
            paymentDay.day == tomorrow.day;
      }
      return false;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ertangi to\'lovlar'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tomorrowPayments.length,
            itemBuilder: (context, index) {
              final data =
                  tomorrowPayments[index].data() as Map<String, dynamic>;

              // isPaid ni to'g'ri formatda olish
              bool isPaid = false;
              if (data['isPaid'] != null) {
                isPaid = data['isPaid'] is bool
                    ? data['isPaid'] as bool
                    : data['isPaid'].toString().toLowerCase() == 'true';
              }

              return Card(
                child: ListTile(
                  title: Text(data['full_name'] ?? 'Noma\'lum'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tel: ${data['phone'] ?? 'Mavjud emas'}'),
                      Text(
                          'To\'lov sanasi: ${_formatDate(data['payment_date'] as Timestamp?)}'),
                    ],
                  ),
                  trailing: isPaid
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'To\'langan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _updatePaymentStatus(
                                tomorrowPayments[index].id, true);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(236, 233, 76, 1),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('To\'lov qilindi'),
                        ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showNextWeekPayments(
      BuildContext context, List<QueryDocumentSnapshot> students) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    // Bir hafta ichidagi to'lovlarni filtrlash
    final nextWeekPayments = students.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final paymentDate = data['payment_date'] as Timestamp?;

      if (paymentDate != null) {
        final paymentDay = DateTime(
          paymentDate.toDate().year,
          paymentDate.toDate().month,
          paymentDate.toDate().day,
        );

        // Bugundan keyingi va bir hafta ichidagi to'lovlar
        return paymentDay.isAfter(today) &&
            paymentDay.isBefore(nextWeek.add(const Duration(days: 1)));
      }
      return false;
    }).toList();

    // To'lov sanasi bo'yicha tartiblash
    nextWeekPayments.sort((a, b) {
      final aDate =
          (a.data() as Map<String, dynamic>)['payment_date'] as Timestamp;
      final bDate =
          (b.data() as Map<String, dynamic>)['payment_date'] as Timestamp;
      return aDate.compareTo(bDate);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyingi hafta to\'lovlari'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: nextWeekPayments.length,
            itemBuilder: (context, index) {
              final data =
                  nextWeekPayments[index].data() as Map<String, dynamic>;

              // isPaid ni to'g'ri formatda olish
              bool isPaid = false;
              if (data['isPaid'] != null) {
                isPaid = data['isPaid'] is bool
                    ? data['isPaid'] as bool
                    : data['isPaid'].toString().toLowerCase() == 'true';
              }

              return Card(
                child: ListTile(
                  title: Text(data['full_name'] ?? 'Noma\'lum'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tel: ${data['phone'] ?? 'Mavjud emas'}'),
                      Text(
                          'To\'lov sanasi: ${_formatDate(data['payment_date'] as Timestamp?)}'),
                    ],
                  ),
                  trailing: isPaid
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'To\'langan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _updatePaymentStatus(
                                nextWeekPayments[index].id, true);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(236, 233, 76, 1),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('To\'lov qilindi'),
                        ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Mavjud emas';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // Bugungi to'lovlar statistikasi
          int todayTotal = 0; // Bugun to'lov qilishi kerak bo'lganlar
          int todayPaid = 0; // Bugun to'lov qilganlar
          int unpaidTotal = 0;
          int tomorrowTotal = 0;
          int tomorrowPaid = 0;
          int nextWeekTotal = 0;
          int nextWeekPaid = 0;
          final tomorrow = DateTime(now.year, now.month, now.day + 1);
          final nextWeek = today.add(const Duration(days: 7));

          for (var student in students) {
            final data = student.data() as Map<String, dynamic>;
            final paymentDate = data['payment_date'] as Timestamp?;
            final lastPaymentDate = data['last_payment_date'] as Timestamp?;

            // Bugungi to'lovlarni hisoblash
            if (paymentDate != null) {
              final paymentDay = DateTime(
                paymentDate.toDate().year,
                paymentDate.toDate().month,
                paymentDate.toDate().day,
              );

              // Bugun to'lov qilishi kerak bo'lganlarni hisoblash
              if (paymentDay.year == today.year &&
                  paymentDay.month == today.month &&
                  paymentDay.day == today.day) {
                todayTotal++; // Bugun to'lov qilishi kerak

                // Bugun to'lov qilganlarni tekshirish
                if (lastPaymentDate != null) {
                  final lastPaymentDay = DateTime(
                    lastPaymentDate.toDate().year,
                    lastPaymentDate.toDate().month,
                    lastPaymentDate.toDate().day,
                  );

                  // Agar bugun to'lov qilgan bo'lsa
                  if (lastPaymentDay.year == today.year &&
                      lastPaymentDay.month == today.month &&
                      lastPaymentDay.day == today.day) {
                    todayPaid++; // Bugun to'lov qilgan
                  }
                }
              }
            }

            // To'lov qilmagan va muddati o'tgan o'quvchilarni hisoblash
            if (paymentDate != null && !data['isPaid']) {
              final paymentDay = DateTime(
                paymentDate.toDate().year,
                paymentDate.toDate().month,
                paymentDate.toDate().day,
              );

              if (paymentDay.isBefore(today)) {
                unpaidTotal++;
              }
            }

            // Ertangi to'lovlarni hisoblash
            if (paymentDate != null) {
              final paymentDay = DateTime(
                paymentDate.toDate().year,
                paymentDate.toDate().month,
                paymentDate.toDate().day,
              );

              if (paymentDay.year == tomorrow.year &&
                  paymentDay.month == tomorrow.month &&
                  paymentDay.day == tomorrow.day) {
                tomorrowTotal++;

                // isPaid ni tekshirish
                if (data['isPaid']) tomorrowPaid++;
              }
            }

            // Bir hafta ichidagi to'lovlarni hisoblash
            if (paymentDate != null) {
              final paymentDay = DateTime(
                paymentDate.toDate().year,
                paymentDate.toDate().month,
                paymentDate.toDate().day,
              );

              if (paymentDay.isAfter(today) &&
                  paymentDay.isBefore(nextWeek.add(const Duration(days: 1)))) {
                nextWeekTotal++;

                // isPaid ni tekshirish
                if (data['isPaid']) nextWeekPaid++;
              }
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
                      GestureDetector(
                        onTap: () =>
                            _showTodayPayments(context, snapshot.data!.docs),
                        child: _buildStatCard(
                          'Bugungi to\'lovlar',
                          '$todayPaid/$todayTotal',
                          const Color(0xFF512D84),
                          Icons.today,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () =>
                            _showUnpaidPayments(context, snapshot.data!.docs),
                        child: _buildStatCard(
                          'To\'lov qilmaganlar',
                          '$unpaidTotal',
                          Colors.red,
                          Icons.warning_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () =>
                            _showTomorrowPayments(context, snapshot.data!.docs),
                        child: _buildStatCard(
                          'Ertangi to\'lovlar',
                          '$tomorrowPaid/$tomorrowTotal',
                          const Color(0xFF00BFA5),
                          Icons.next_plan,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () =>
                            _showNextWeekPayments(context, snapshot.data!.docs),
                        child: _buildStatCard(
                          'Keyingi to\'lovlar',
                          '$nextWeekPaid/$nextWeekTotal',
                          Colors.blue,
                          Icons.calendar_month,
                        ),
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
                    final userData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    final paymentDate = userData['payment_date'] as Timestamp?;
                    final String formattedDate = paymentDate != null
                        ? '${paymentDate.toDate().day}/${paymentDate.toDate().month}/${paymentDate.toDate().year}'
                        : 'Belgilanmagan';

                    // isPaid ni to'g'ri formatda olish
                    bool isPaid = false;
                    if (userData['isPaid'] != null) {
                      isPaid = userData['isPaid'] is bool
                          ? userData['isPaid'] as bool
                          : userData['isPaid'].toString().toLowerCase() ==
                              'true';
                    }

                    return GestureDetector(
                      onTap: () => _showPaymentDetails(context, userData),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: index.isEven
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF512D84),
                                    Color(0xFF7646B8)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFF8F0FF),
                                    Color(0xFFF0F7FF)
                                  ],
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
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFF512D84),
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                          title: Text(
                            userData['full_name'] ?? 'Noma\'lum',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w500,
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFF512D84),
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
                                  color: index.isEven
                                      ? Colors.white70
                                      : Colors.grey[600],
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

  Future<void> _updatePaymentStatus(String docId, bool newStatus) async {
    try {
      if (newStatus) {
        // To'lov qilinganda, keyingi to'lov sanasini 1 oyga surish
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .get();
        final currentPaymentDate =
            (doc.data()?['payment_date'] as Timestamp?)?.toDate();

        if (currentPaymentDate != null) {
          // Keyingi to'lov sanasini hisoblash (1 oy keyinga)
          final nextPaymentDate = DateTime(
            currentPaymentDate.year,
            currentPaymentDate.month + 1,
            currentPaymentDate.day,
          );

          // To'lov tarixiga qo'shish
          final paymentHistory =
              (doc.data()?['payment_history'] as List<dynamic>?) ?? [];
          paymentHistory.add({
            'date': Timestamp.fromDate(currentPaymentDate),
            'amount': doc.data()?['payment_amount'] ?? 0,
            'paid_at': Timestamp.now(),
          });

          // To'lov holatini, yangi sanani va tarixni saqlash
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({
            'isPaid': newStatus,
            'payment_date': Timestamp.fromDate(nextPaymentDate),
            'payment_history': paymentHistory,
            'last_payment_date': Timestamp.now(),
          });
        }
      } else {
        // To'lov bekor qilinganda faqat holatni o'zgartirish
        await FirebaseFirestore.instance.collection('users').doc(docId).update({
          'isPaid': newStatus,
        });
      }
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }
}
