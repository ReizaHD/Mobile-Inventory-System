import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/models/supplier.dart';
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final fb = FirebaseHelper();
  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _selectedSupplier;
  List<Map<String,String>> suppliers = [];

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImageToAppDirectory(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = image.name;
    final File newImage = File('$path/$fileName');

    await image.saveTo(newImage.path);
    setState(() {
      _imagePath = newImage.path;
    });
    print('Image saved at: ${newImage.path}');
  }

  @override
  void initState() {
    setSuppliers();
    super.initState();
  }

  void setSuppliers() async {
    List<Supplier> supplierList = await fb.getSupplier();
    List<Map<String,String>> supplierSelection = [];
    for(Supplier supplier in supplierList){
      supplierSelection.add(
        {
          'name': supplier.name,
          'id': supplier.id!
        }
      );
    }
    setState(() {
      suppliers = supplierSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Barang'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _image != null
                          ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      )
                          : Center(
                        child: Text(
                          'Gambar belum dipilih',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: Icon(Icons.photo),
                            label: Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: Icon(Icons.camera_alt_rounded),
                            label: Text('Kamera'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedSupplier,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Pilih Supplier",
                      ),
                      items: suppliers.map((supplier) {
                        return DropdownMenuItem<String>(
                          value: supplier['id'], // Use the supplier ID as the value
                          child: Text(supplier['name']!), // Display the supplier name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplier = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Supplier tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Nama Barang",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama Barang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Deskripsi Barang",
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi Barang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Kategori Barang",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori Barang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Harga Barang",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga Barang tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Harga Barang harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Stok Awal Barang",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Stok Barang!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Stok Barang harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () => _submitForm(context),
                      icon: Icon(Icons.send),
                      label: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final barang = Item(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: int.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        supplierId: _selectedSupplier!, // Include selected supplier
        image: _imagePath,
      );
      await fb.insertItem(
        item: barang,
        imageFile: _image,
        onSuccess: (snapshot) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barang berhasil ditambahkan!')),
          );
          Navigator.pop(context);
        },
      );
    }
  }
}
