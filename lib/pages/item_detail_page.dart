import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/models/transaction_history.dart';
import 'package:mobile_inventory_system/models/item.dart';
import 'package:mobile_inventory_system/pages/add_transaction_page.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState(item: item);
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final fb = FirebaseHelper();
  List<TransactionHistory> _historyList = [];
  Item item;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _supplierName;
  String? _imagePath;

  _ItemDetailPageState({required this.item});

  @override
  void initState() {
    print(widget.item.toString());
    item  = widget.item;
    getSupplierName();
    _refreshRiwayatList();
    super.initState();
  }

  void getSupplierName() async {
    String supplierName = await fb.getSupplierName(supplierId: item.supplierId);
    setState(() {
      _supplierName = supplierName;
    });

  }

  Future<void> _refreshRiwayatList() async {
    List<TransactionHistory> transaksiList = await fb.getTransactionHistory(itemId: item.id!);
    setState(() {
      _historyList = transaksiList;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // _saveImageToAppDirectory(pickedFile);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // _saveImageToAppDirectory(pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Barang"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showAlertDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx){
                    return AlertDialog(
                      title: Text("Hapus Barang"),
                      content: Text("Yakin ingin menghapus barang?"),
                      actions: [
                        TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Tidak")),
                        TextButton(onPressed: () async {
                          await fb.deleteItem(itemId: item.id!, onSuccess: (){
                            Navigator.pop(ctx);
                            Navigator.pop(context,true);
                          });
                        }, child: Text("Ya")),
                      ],
                    );
                  });
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.image != null)
              Image.network(
                item.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _supplierName!=null
              ? 'Supplier: ${_supplierName}'
              : '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kategori: ${item.category}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harga: Rp${item.price}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (item.stock != null)
              Text(
                'Stok: ${item.stock} pcs',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddTransactionPage(
                      item: item,
                    ))
                ).then((value) {
                  if(value is Item){
                    setState(() {
                      item = value;
                    });
                    _refreshRiwayatList();
                  } else {
                    print(value);
                  }
                });
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text("Tambah Riwayat"),
            ),
            SizedBox(height: 10,),
            _historyList.isEmpty
                ? Center(
              child: Text(
                'Belum ada Riwayat',
                style: TextStyle(fontSize: 16, color: Colors.black12),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                TransactionHistory riwayat = _historyList[index];
                return ListTile(
                  title: Text('${riwayat.transactionType} - ${riwayat.amount}'),
                  subtitle: Text('${riwayat.date}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }



  Future<void> showAlertDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController _namaController =
    TextEditingController(text: item.name);
    final TextEditingController _deskripsiController =
    TextEditingController(text: item.description);
    final TextEditingController _kategoriController =
    TextEditingController(text: item.category);
    final TextEditingController _hargaController =
    TextEditingController(text: item.price.toString());

    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            // Using StateSetter to manage dialog-specific state
            return AlertDialog(
              title: const Text("Perbarui Data"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: _image != null
                          ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                          : item.image != null
                            ? Image.network(
                          item.image!,
                          fit: BoxFit.cover,
                        )
                            : const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _pickImageFromGallery();
                                setDialogState(() {}); // Update dialog state
                              },
                              icon: const Icon(Icons.photo),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _pickImageFromCamera();
                                setDialogState(() {}); // Update dialog state
                              },
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('Kamera'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: "Nama Barang"),
                      ),
                      TextField(
                        controller: _kategoriController,
                        decoration:
                        const InputDecoration(labelText: "Kategori Barang"),
                      ),
                      TextField(
                        controller: _hargaController,
                        decoration:
                        const InputDecoration(labelText: "Harga Barang"),
                      ),
                      TextField(
                        controller: _deskripsiController,
                        decoration:
                        const InputDecoration(labelText: "Deskripsi"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _image = null;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Item barang = item;
                    barang.name = _namaController.text;
                    barang.description = _deskripsiController.text;
                    barang.category = _kategoriController.text;
                    barang.price = int.parse(_hargaController.text);
                    await fb.updateItem(itemId: barang.id!, item: barang, imageFile: _image, onSuccess: (){
                      Navigator.pop(ctx);
                      setState(() {
                        item = barang;
                      });
                    });
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}