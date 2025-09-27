import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/pages/add_item_page.dart';
import 'package:mobile_inventory_system/pages/item_detail_page.dart';
import 'package:mobile_inventory_system/pages/login_page.dart';
import '../models/item.dart';

class ItemListPage extends StatefulWidget{
  const ItemListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ItemListPage();
}

class _ItemListPage extends State<ItemListPage>{
  List<Item> _barang = [];
  final fb = FirebaseHelper();

  void refreshList() async {
    List<Item> items = await fb.getItem();
    setState(() {
      _barang = items;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Mobile Inventory System'),
      ),
      body: Column(
          children: [
            SizedBox(height: 4,),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.all_inbox_rounded, size: 30,),
              SizedBox(width: 10),
              Text('Daftar Barang', style: TextStyle(fontSize: 30),)
            ]),
            SizedBox(height: 8,),
            Divider(height: 8, indent: 20, endIndent: 20,),
            SizedBox(height: 4,),
            Expanded(
                child: _barang.length == 0
                    ? Text("Belum data barang tersedia",
                  style: TextStyle(color: Colors.black26, fontSize: 16),
                )
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: (1/1.5)
                  ),
                  itemBuilder: (context, pos) {
                    return listBarang(pos);
                  },
                  itemCount: _barang.length,
                )
            )
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddItemPage())
          ).then((value) {
            refreshList();
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget listBarang(int pos) {
    return InkWell(
      onTap: () async {
        // print(_barang[pos].toMap().toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: _barang[pos]),
          ),
        ).then((value) {
          refreshList();
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 178, 178, 178),
                offset: Offset(1.0, 2.0),
                blurRadius: 6.0,
              ),
            ],
          ),
          height: 120,
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    child: _barang[pos].image != null && _barang[pos].image!.isNotEmpty
                        ? Image.network(
                      _barang[pos].image!,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/default_image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(_barang[pos].name, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold, height: 1.0,)),
              Text("${_barang[pos].category}", style: TextStyle(fontSize: 16, color: Colors.black)),
              Text("Rp ${_barang[pos].price.toString()}", style: TextStyle(fontSize: 16, color: Colors.black)),
              Text("Stok: ${_barang[pos].stock}", style: TextStyle(fontSize: 16, color: Colors.black)),

            ],
          )
      ),
    );
  }

}