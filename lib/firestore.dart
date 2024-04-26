import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveQuoteToFirestore(String quote, String author) async {
  // Добавляем цитату в коллекцию Firestore с меткой времени
  await FirebaseFirestore.instance.collection('quotes').add({
    'quote': quote,
    'author': author,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<List<Map<String, dynamic>>> fetchQuoteHistoryFromFirestore() async {
  try {
    // Получаем список документов из коллекции Firestore и преобразуем их в список цитат
    final querySnapshot = await FirebaseFirestore.instance.collection('quotes').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print('Error fetching quote history: $e');
    return [];
  }
}