import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


int weekNumberFromDate(DateTime date) {
  final thursday = date.add(Duration(days: 4 - date.weekday));
  final firstJan = DateTime(thursday.year, 1, 1);
  final weekNum = ((thursday.difference(firstJan).inDays) ~/ 7) + 1;
  return weekNum > 0 ? weekNum : 1;
}

Future<void> recordUserActivity() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

  final uid = user.uid;
  final today = DateTime.now();

  final yyyymmdd = "${today.year.toString().padLeft(4, '0')}"
  "${today.month.toString().padLeft(2, '0')}"
  "${today.day.toString().padLeft(2, '0')}";

  final weekNum = weekNumberFromDate(today);
  final weekId = "${today.year}-W${weekNum.toString().padLeft(2, '0')}";

  await FirebaseFirestore.instance
      .collection('user_activity')
      .doc(uid)
      .collection('weekly')
      .doc(weekId)
      .set({yyyymmdd: true}, SetOptions(merge: true));
  } catch (e, st) {
      debugPrint('recordUserActivity failed: $e\n$st');
  }
}
