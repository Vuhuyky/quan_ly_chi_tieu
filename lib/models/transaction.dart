import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'income' hoặc 'expense'
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawType = (data['type'] ?? 'expense').toString();
    final normalizedType = rawType.trim().toLowerCase(); // "expense" hoặc "income"

    final rawDate = data['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else {
      parsedDate = DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();
    }
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: normalizedType,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: (data['category'] ?? 'Khác').toString(),
      description: (data['description'] ?? '').toString(),
      date: parsedDate,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'year': date.year,
      'month': date.month,
    };
  }
}
