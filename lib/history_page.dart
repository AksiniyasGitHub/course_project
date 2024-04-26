import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> quoteHistory;

  HistoryPage({required this.quoteHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quote History"),
      ),
      body: quoteHistory.isEmpty
          ? Center(child: Text("No quote history available"))
          : ListView.builder(
        itemCount: quoteHistory.length,
        itemBuilder: (context, index) {
          print("i: ${index}, total: ${quoteHistory.length}");
          print(quoteHistory[index]);
          return ListTile(
            title: Text(quoteHistory[index]['quote']),
            subtitle: Text('- ' + quoteHistory[index]['author']),
          );
        },
      ),
    );
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
}