import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String? id;
  final String name;
  final String address;
  final String contact;
  final double latitude;
  final double longitude;

  Supplier({
    this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.latitude,
    required this.longitude
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id ?? '',
      'name': name,
      'address': address,
      'contact': contact,
      'latitude': latitude,
      'longitude': longitude
    };
  }

  Map<String, dynamic> toFirestore(){
    return <String, dynamic>{
      'name': name,
      'address': address,
      'contact': contact,
      'latitude': latitude,
      'longitude': longitude
    };
  }

  factory Supplier.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ){
    final data = snapshot.data();
    return Supplier(
      id: snapshot.id,
      name: data?['name'] ?? '',
      address: data?['address'] ?? '',
      contact: data?['contact'] ?? '',
      latitude: data?['latitude'] ?? 0.0,
      longitude: data?['longitude'] ?? 0.0
    );
  }

  static Supplier fromMap(Map<String, dynamic> map) {
    return Supplier(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      contact: map['contact'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0
    );
  }
}
