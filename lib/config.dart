import 'dart:io';
import 'package:path/path.dart' as path; // Add this package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobile_inventory_system/models/transaction_history.dart';
import 'package:mobile_inventory_system/models/item.dart';
import 'package:mobile_inventory_system/pages/dashboard.dart';
import 'package:mobile_inventory_system/pages/item_page.dart';

import 'models/supplier.dart';


class FirebaseHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final _supplierRef = _firestore.collection("suppliers")
      .withConverter(fromFirestore: Supplier.fromFirestore, toFirestore: (Supplier supplier, _) => supplier.toFirestore());

  static final _itemRef = _firestore
      .collection("items")
      .withConverter(
        fromFirestore: Item.fromFirestore,
        toFirestore: (Item item, _) => item.toFirestore());

  static final _storage = FirebaseStorage.instance;
  static final _storageRef = _storage.ref();

  Future<String> uploadImage({
    required File imageFile,
    void Function(Exception e)? onError
  }) async {
    try {
      // Step 1: Get the file extension dynamically
      print(imageFile.path);
      final fileExtension = path.extension(imageFile.path); // e.g., ".jpg", ".png"

      // Step 2: Define the storage path with the correct extension
      final storageRef = _storageRef
          .child('item_images/${DateTime.now().millisecondsSinceEpoch}$fileExtension');
      print(storageRef.fullPath);

      // Step 3: Upload the image to Firebase Storage
      await storageRef.putFile(imageFile);

      // Step 4: Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      print('done');
      return downloadUrl;
    } on Exception catch (e) {
      print("Error uploading image or storing data: $e");
      if(onError != null){
        onError(e);
      }
      return "";
    }
  }

  Future<void> deleteImage({
    required String imageUrl,
    void Function(Exception e)? onError
  }) async {
    try {
      final storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } on Exception catch (e){
      if(onError != null){
        onError(e);
      }
    }
  }

  Future<void> insertSupplier({
    required Supplier supplier,
    required void Function() onSuccess,
    void Function(Exception e)? onError
  }) async {
    try{
      await _supplierRef
          .add(supplier);
      onSuccess();
    } on Exception catch(e){
      if(onError!=null){
        onError(e);
      }
    }
  }

  Future<int> countItem() async {
    int total = 0 ;
    await _itemRef.get().then((snapshot){
      total = snapshot.docs.length;
    });
    return total;
  }

  Future<int> countSupplier() async {
    int total = 0;
    await _supplierRef.get().then((snapshot){
      total = snapshot.docs.length;
    });
    return total;
}

  Future<List<Supplier>> getSupplier({
    void Function(Exception e)? onError
  }) async {
    List<Supplier> suppliers = [];
    await _supplierRef.get().then((querySnapshot) {
      for(var docSnapshot in querySnapshot.docs){
        suppliers.add(docSnapshot.data());
      }}, onError: onError);
    return suppliers;
  }

  Future<void> deleteSupplier({
    required supplierId,
    required void Function() onSuccess,
    void Function(Exception e)? onError
  }) async {
    try {
      QuerySnapshot querySnapshot =  await _firestore.collection('items').where('supplier_id', isEqualTo: supplierId).get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      await _supplierRef.doc(supplierId).delete();
      onSuccess();
    } on Exception catch(e){
      if(onError != null){
        onError(e);
      }
    }
  }

  Future<void> updateSupplier({
    required Supplier supplier,
    required void Function() onSuccess,
    void Function(Exception e)? onError
  }) async {
    await _supplierRef.doc(supplier.id).update(supplier.toFirestore()).onError((Exception e,_) {
      if(onError != null){
        onError(e);
      }
    });
    onSuccess();
  }

  Future<void> insertItem({
    required Item item,
    File? imageFile,
    required void Function(DocumentReference snapshot) onSuccess,
    void Function(Exception e)? onError
  }) async {
    try {
      if(imageFile != null){
        print('not null');
        item.image = await uploadImage(imageFile: imageFile);
      }
      await _firestore
          .collection("items").add({
            ...item.toFirestore(),
            'transaction_history': []
          })
          .then((snapshot){
            onSuccess(snapshot);
          });
    } on Exception catch (e){
      print(e);
      if(onError != null){
        onError(e);
      }
    }
  }

  Future<String> getSupplierName({
    required String supplierId
  }) async {
    final snapshot = await _firestore.collection('suppliers').doc(supplierId).get();
    return snapshot.data()!['name'];
  }

  Future<void> updateItem({
    required String itemId,
    required Item item,
    File? imageFile,
    required void Function() onSuccess,
    void Function(Exception e)? onError
  }) async {
    if(imageFile != null){
      if(item.image!=null) {
        await deleteImage(imageUrl: item.image!);
      }
      item.image = await uploadImage(imageFile: imageFile);
    }
    await _itemRef.doc(itemId).update(item.toFirestore()).onError((Exception e,_) {
      if(onError != null){
        onError(e);
      }
    });
    onSuccess();
  }

  Future<List<Item>> getItem({
    void Function(Exception e)? onError
  }) async {
    List<Item> items = [];
    await _itemRef.get().then(
      (querySnapshot) {
        for(var docSnapshot in querySnapshot.docs){
          items.add(docSnapshot.data());
        }
      },
      onError: onError
    );
    return items;
  }

  Future<void> deleteItem({
    required String itemId,
    required void Function() onSuccess,
    void Function()? onError
  }) async {
    await _itemRef.doc(itemId).delete();
    onSuccess();
  }

  Future<void> insertTransactionHistory({
    required String itemId,
    required TransactionHistory history,
    required void Function() onSuccess,
    void Function(Exception e)? onError
  }) async {
    print(itemId);
    print(history.toFirestore());
    try {
      await _firestore.collection("items").doc(itemId).update({
        'transaction_history':
            FieldValue.arrayUnion([history.toFirestore()]),
      });
      onSuccess();
    } on Exception catch (e) {
      print("Error writing document: $e");
      if(onError != null) {
        onError(e);
      }
    }
  }

  Future<List<TransactionHistory>> getTransactionHistory({
    required String itemId,
    List<TransactionHistory> Function(Exception e)? onError
  }) async {
    try{
      final snapshot = await _firestore
          .collection("items")
          .doc(itemId)
          .get();
      final List<dynamic>? historyData = snapshot
          .data()?['transaction_history'];
      if (historyData != null) {
        return historyData
            .map((entry) =>
            TransactionHistory.fromMap(entry as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on Exception catch (e) {
      if(onError != null){
        return onError(e);
      }
      return [];
    }
  }

  Future<void> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required void Function(UserCredential credential) onSuccess,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if(credential.user != null){
        User? user = credential.user;
        await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
          'uid': user?.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      onSuccess(credential);
    } on FirebaseAuthException catch (e) {
      onError(e);
    }
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
    required void Function(UserCredential credential) onSuccess,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess(credential);
    } on FirebaseAuthException catch (e) {
      onError(e);
    }
  }
}
