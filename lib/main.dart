import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем библиотеку Firestore
import 'motivation_api.dart';
import 'history_page.dart';

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
      home: MotivationPage(),
    );
  }
}

class MotivationPage extends StatefulWidget {
  @override
  _MotivationPageState createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  late MotivationApi motivationApi;
  String quote = '';
  String author = '';
  String backgroundImageUrl = '';
  bool isLoading = true;
  int refreshCount = 0;
  DateTime? nextRefreshTime;

  @override
  void initState() {
    super.initState();
    motivationApi = MotivationApi(
      quoteApiUrl: 'https://api.api-ninjas.com/v1/quotes?category=happiness',
      unsplashAccessKey: 'T65sku3sFA13jiOOCOuoQyNXjv-lB6nj0b7ecloffaI',
    );
    fetchData();
  }

  Future<void> fetchData() async {
    if (isRefreshAllowed()) {
      try {
        // Получаем мотивационные данные и URL изображения
        final motivationalData = await motivationApi.fetchMotivationalData();
        final imageUrl = await motivationApi.fetchRandomImageUrl(query: 'Inspirational');
        setState(() {
          quote = motivationalData['quote'] ?? '';
          author = motivationalData['author'] ?? 'Unknown';
          backgroundImageUrl = imageUrl;
          isLoading = false;
          refreshCount++;
          updateNextRefreshTime();
        });
        // Сохраняем цитату в Firestore
        saveQuoteToFirestore(quote, author);
      } catch (e) {
        print('Error fetching data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("That's enough motivation for today!");
    }
  }

  bool isRefreshAllowed() {
    return refreshCount < 3;
  }

  void updateNextRefreshTime() {
    nextRefreshTime = DateTime.now().add(Duration(days: 1));
  }

  Future<void> saveQuoteToFirestore(String quote, String author) async {
    // Добавляем цитату в коллекцию Firestore с меткой времени
    await FirebaseFirestore.instance.collection('quotes').add({
      'quote': quote,
      'author': author,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, String>>> fetchQuoteHistoryFromFirestore() async {
    try {
      // Получаем список документов из коллекции Firestore и преобразуем их в список цитат
      final querySnapshot = await FirebaseFirestore.instance.collection('quotes').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, String>).toList();
    } catch (e) {
      print('Error fetching quote history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Inspirations'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              // Получаем список цитат из Firestore перед переходом на страницу истории
              final quoteHistory = await fetchQuoteHistoryFromFirestore();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage(quoteHistory: quoteHistory)),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImageUrl.isNotEmpty)
            Image.network(backgroundImageUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (quote.isNotEmpty)
                    Text(
                      quote,
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: 8.0),
                  Text(
                    '- $author',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}