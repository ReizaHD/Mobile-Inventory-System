import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionHistory {
  final String? id;
  final String transactionType;
  final int amount;
  final String date;

  TransactionHistory({
    this.id,
    required this.transactionType,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'transaction_type': transactionType,
      'amount': amount,
      'date': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(date)),
    };
  }

  factory TransactionHistory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final Timestamp timestamp = data?['date']; // Assuming Firestore stores this as a Timestamp.
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
    return TransactionHistory(
      id: snapshot.id as String?,
      transactionType: data?['transaction_type'] as String,
      amount: data?['amount'] as int,
      date: formattedDate,
    );
  }

  factory TransactionHistory.fromMap(Map<String, dynamic> data) {
    final Timestamp timestamp = data['date']; // Firestore stores dates as Timestamps
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
    return TransactionHistory(
      transactionType: data['transaction_type'] as String,
      amount: data['amount'] as int,
      date: formattedDate,
    );
  }

}
