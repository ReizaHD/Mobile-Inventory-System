import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/pages/item_page.dart';
import 'package:mobile_inventory_system/pages/supplier_page.dart';

import 'login_page.dart';

class Dashboard extends StatefulWidget{
  Dashboard({super.key});

  @override
  State<StatefulWidget> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard>{
  int countSupplier = 0;
  int countItem = 0;
  final fb = FirebaseHelper();

  @override
  void initState() {
    super.initState();
    count();
  }

  void count() async {
    // Perform the asynchronous operations first
    final itemCount = await fb.countItem();
    final supplierCount = await fb.countSupplier();

    // Then, update the state synchronously
    setState(() {
      countItem = itemCount;
      countSupplier = supplierCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Dashboard'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "Logout",
                child: Text("Log out"),
              )
            ],
            onSelected: (value) async {
              print("Selected: $value");
              if (value == "Logout") {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    )
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: (8/10)
          ),
          children: [
            gridItem('item'),
            gridItem('supplier')
          ],
        ),
      ),
    );
  }

  Widget gridItem(String type) {
    Icon? icon;
    String text = '';
    Widget nextPage;
    int count = 0;
    if(type == 'item'){
      text = 'List Barang';
      icon = Icon(Icons.storage_rounded, size: 100,);
      nextPage = ItemListPage();
      count = countItem;
    }else {
      text = 'List Supplier';
      icon = Icon(Icons.store, size: 100,);
      nextPage = SupplierListPage();
      count = countSupplier;
    }
    return InkWell(
      onTap: () async {
        // print(_barang[pos].toMap().toString());
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DetailBarangPage(barang: _barang[pos]),
        //   ),
        // ).then((value) {
        //   refreshItemList();
        // });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage)
        ).then((value) async {
          this.count();
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
              icon,
              SizedBox(height: 10,),
              Text(text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              SizedBox(height: 5,),
              Text(count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),)
            ],
          )
      ),
    );
  }
}