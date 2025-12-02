import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> recordUserActivity() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final today = DateTime.now();
  final yyyymmdd = "${today.year}${today.month}${today.day}";

  final weekId = "${today.year}-W${weekNumber(today)}";

  await FirebaseFirestore.instance
      .collection('user_activity')
      .doc(uid)
      .collection('weekly')
      .doc(weekId)
      .set(
    {yyyymmdd: true},
    SetOptions(merge: true),
  );
}

int weekNumber(DateTime date) {
  return int.parse(DateFormat("w").format(date));
}
