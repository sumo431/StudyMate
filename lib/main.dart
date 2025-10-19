import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Home.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env
  await dotenv.load(fileName: "assets/.env");
  print("GEMINI_API_KEY: ${dotenv.env['GEMINI_API_KEY']}");

  //Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Google Cloud Service Account
  final serviceAccountJson =
  await rootBundle.loadString('assets/speech-to-text-key.json');
  final serviceAccount = jsonDecode(serviceAccountJson);
  print("Google Service Account Loaded: ${serviceAccount['client_email']}");

  // final apiClient = GoogleCloudTTSClient.fromServiceAccount(serviceAccount);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capstone App',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
