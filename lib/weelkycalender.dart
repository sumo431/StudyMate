import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

int weekNumberFromDate(DateTime date) {
  final thursday = date.add(Duration(days: 4 - date.weekday));
  final firstJan = DateTime(thursday.year, 1, 1);
  final weekNum = ((thursday.difference(firstJan).inDays) ~/ 7) + 1;
  return weekNum > 0 ? weekNum : 1;
}

Future<void> recordUserActivity() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;
  final today = DateTime.now();

  final yyyymmdd = "${today.year.toString().padLeft(4,'0')}"
      "${today.month.toString().padLeft(2,'0')}"
      "${today.day.toString().padLeft(2,'0')}";
  final weekNum = weekNumberFromDate(today);
  final weekId = "${today.year}-W${weekNum.toString().padLeft(2,'0')}";


  await FirebaseFirestore.instance
      .collection('user_activity')
      .doc(uid)
      .collection('weekly')
      .doc(weekId)
      .set({yyyymmdd: true}, SetOptions(merge: true));
}


/// --- WeeklyCalendar Widget ---
class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final uid = user.uid;
    final today = DateTime.now();
    final weekId =
        "${today.year}-W${weekNumberFromDate(today).toString().padLeft(2,'0')}";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_activity')
          .doc(uid)
          .collection('weekly')
          .doc(weekId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        final weekDates = List.generate(7, (i) {
          final date = today.subtract(Duration(days: today.weekday - 1 - i));
          final key = "${date.year.toString().padLeft(4, '0')}"
              "${date.month.toString().padLeft(2, '0')}"
              "${date.day.toString().padLeft(2, '0')}";
          return {'key': key, 'weekday': date};
        });

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDates.map((d) {
            final isChecked = data[d['key']] == true;
            final weekday = d['weekday'] as DateTime;
            final weekdayName = DateFormat.E().format(weekday);

            return Column(
              children: [
                Text(weekdayName),
                const SizedBox(height: 4),
                Icon(
                  isChecked ? Icons.check_circle : Icons.circle_outlined,
                  color: isChecked ? Colors.green : Colors.grey,
                  size: 28,
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
