import 'package:flutter/material.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/models/supplier.dart';
import 'package:mobile_inventory_system/pages/add_supplier_page.dart';
import 'package:mobile_inventory_system/pages/supplier_detail_page.dart';

class SupplierListPage extends StatefulWidget{
  const SupplierListPage({super.key});

  @override
  State<StatefulWidget> createState() => _SupplierListPage();

}

class _SupplierListPage extends State<SupplierListPage>{
  List<Supplier> _suppliers = [];
  final fb = FirebaseHelper();

  void refreshList() async {
    List<Supplier> suppliers = await fb.getSupplier();
    setState(() {
      _suppliers = suppliers;
    });
  }

  @override
  void initState() {
    refreshList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Mobile Inventory System'),
      ),
      body: Padding(padding: EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(height: 4,),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.store, size: 30,),
              SizedBox(width: 10),
              Text('Daftar Supplier', style: TextStyle(fontSize: 30),)
            ]),
            SizedBox(height: 8,),
            Divider(height: 8, indent: 20, endIndent: 20,),
            SizedBox(height: 4,),
            _suppliers.isEmpty
              ? Center(child: Text('Tidak ada supplier tersedia.'))
              : Expanded(
                child: ListView.builder(
                  itemCount: _suppliers.length,
                  itemBuilder: (context, index) {
                    return supplierWidget(index);
                  }),
              ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddSupplierPage())
          ).then((value){
            refreshList();
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget supplierWidget(int position){
    final supplier = _suppliers[position];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        title: Text(
          supplier.name.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supplier.address,
                    style: TextStyle(fontSize: 16, ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  supplier.contact,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupplierDetailPage(
                supplier: supplier
              ),
            ),
          ).then((value){
            refreshList();
          });
        },
      ),
    );
  }

}