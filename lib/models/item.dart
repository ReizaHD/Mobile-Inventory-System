import 'dart:ffi';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class Item{
  //nama, deskripsi, harga, stok, dan gambar barang
  final String? id;
  String name;
  String description;
  int price;
  String category;
  int? stock;
  String? image;
  String supplierId;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.stock,
    this.image,
    required this.supplierId
  });

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'image':image,
      'supplier_id':supplierId
    };
  }

  factory Item.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
  ){
    final data = snapshot.data();
    return Item(
        id: snapshot.id as String?,
        name: data?['name'] as String,
        description: data?['description'] as String,
        category: data?['category'] as String,
        price: data?['price'] as int,
        stock: data?['stock'] as int?,
        image: data?['image'] as String?,
        supplierId: data?['supplier_id'] as String
    );
  }
}