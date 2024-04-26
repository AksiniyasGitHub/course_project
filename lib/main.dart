import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'motivation_api.dart';
import 'history_page.dart';
import 'motivation_page.dart';
import 'firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализируем Firebase при запуске приложения
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motivation Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MotivationPage(), // Теперь используем MotivationPage из отдельного файла
    );
  }
}