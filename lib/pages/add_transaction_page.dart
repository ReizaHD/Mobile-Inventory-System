import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/models/transaction_history.dart';
import '../models/item.dart';

class AddTransactionPage extends StatefulWidget {
  final Item item;
  const AddTransactionPage({super.key, required this.item});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPage();
}

class _AddTransactionPage extends State<AddTransactionPage>{
  String? _warningMessage;
  final _formKey = GlobalKey<FormState>();
  final fb = FirebaseHelper();
  String _transactionType = 'Masuk';
  int? _amount;
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _saveTransactionHistory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      TransactionHistory history = TransactionHistory(
        transactionType: _transactionType,
        amount: _amount!,
        date: _date,
      );
      int? itemStock = widget.item.stock;

      if(_transactionType == 'Masuk'){
        itemStock = (itemStock! + _amount!);
      } else {
        if(widget.item.stock! < _amount!){
          setState(() {
            _warningMessage = "Jumlah yang dikeluarkan melebihi stok saat ini!";
          });
          return;
        }else {
          setState(() {
            itemStock = (itemStock! - _amount!);
          });
        }
      }

      await fb.insertTransactionHistory(itemId: widget.item.id!, history: history,
        onSuccess: () async {
          Item item = widget.item;
          item.stock = itemStock;
          await fb.updateItem(itemId: widget.item.id!, item: item,
            onSuccess: (){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Riwayat berhasil ditambahkan!')),
              );

              Navigator.pop(context, widget.item);
            }
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Riwayat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'ID Barang'),
                initialValue: widget.item.id.toString(),
                readOnly: true,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Jenis Transaksi'
                ),
                items: ['Masuk', 'Keluar']
                    .map((jenis) => DropdownMenuItem(
                  value: jenis,
                  child: Text(jenis),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _transactionType = value!;
                  });
                },
                onSaved: (value) => _transactionType = value!,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Jumlah',
                    errorText: _warningMessage
                ),
                keyboardType: TextInputType.number,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  return null;
                },
                onSaved: (value) => _amount = int.parse(value!),
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tanggal'
                ),
                initialValue: _date,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _date = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransactionHistory,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}