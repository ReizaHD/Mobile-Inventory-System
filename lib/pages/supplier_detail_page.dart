import 'package:flutter/material.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/pages/supplier_update_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/supplier.dart';

class SupplierDetailPage extends StatefulWidget{
  final Supplier supplier;
  const SupplierDetailPage({
    super.key,
    required this.supplier
  });

  @override
  State<StatefulWidget> createState() => _SupplierDetailPage(supplier);


}

class _SupplierDetailPage extends State<SupplierDetailPage> {
  Supplier supplier;
  final fb = FirebaseHelper();

  _SupplierDetailPage(this.supplier);

  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  void toUpdatePage(Supplier supplier) async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Supplier"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateSupplierPage(supplier: supplier))
              ).then((value){
                if(value is Supplier){
                  setState(() {
                    supplier = value;
                  });
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext ctx){
                  return AlertDialog(
                    title: Text("Hapus Supplier"),
                    content: Text("Yakin ingin menghapus supplier?"),
                    actions: [
                      TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Tidak")),
                      TextButton(onPressed: () async {
                        await fb.deleteSupplier(supplierId: supplier.id!, onSuccess: (){
                          Navigator.pop(ctx);
                          Navigator.pop(context,true);
                        });
                      }, child: Text("Ya")),
                    ],
                  );
                }
              );
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      supplier.name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent,),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(color: Colors.grey, height: 20),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          supplier.address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Latitude: ${supplier.latitude}\nLongitude: ${supplier.longitude}',
                          style: TextStyle(fontSize: 16),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchGoogleMaps(supplier.latitude, supplier.longitude),
                      icon: Icon(Icons.map),
                      label: Text('Tampilkan di Google Maps'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}