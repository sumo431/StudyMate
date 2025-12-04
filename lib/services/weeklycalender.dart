import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


int getWeekNumber(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  final weekNumber = ((dayOfYear - (date.weekday - 1) + 3) / 7).ceil();
  return weekNumber;
}

class WeeklyCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final weekId = "${DateTime.now().year}-W${getWeekNumber(DateTime.now())}";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_activity')
          .doc(uid)
          .collection('weekly')
          .doc(weekId)
          .snapshots(),
      builder: (context, snapshot) {
        final days = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final weekDays = List.generate(7, (i) {
          final date = DateTime.now().subtract(
              Duration(days: DateTime.now().weekday - 1 - i));
          final key = "${date.year}${date.month}${date.day}";
          return days[key] == true;
        });

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            return Column(
              children: [
                Text(["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][i]),
                Icon(
                  weekDays[i] ? Icons.check_circle : Icons.circle_outlined,
                  color: weekDays[i] ? Colors.green : Colors.grey,
                )
              ],
            );
          }),
        );
      },
    );
  }
}
