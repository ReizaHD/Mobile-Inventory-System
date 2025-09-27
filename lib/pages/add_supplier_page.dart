import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:mobile_inventory_system/config.dart';
import 'package:mobile_inventory_system/models/supplier.dart';

class AddSupplierPage extends StatefulWidget {
  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final fb = FirebaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await location.getLocation();

    setState(() {
      _currentLocation =
          LatLng(_locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
    });
  }

  void _saveSupplier() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      final supplierData = Supplier(
          name: _nameController.text,
          address: _addressController.text,
          contact: _contactController.text,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude);

      await fb.insertSupplier(supplier: supplierData, onSuccess: (){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supplier berhasil disimpan!')),
        );
        Navigator.pop(context);
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon pilih lokasi pada peta.')),
      );
    }
  }

  void _openFullscreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenMapPage(
          initialLocation: _currentLocation ?? LatLng(0, 0),
          selectedLocation: _selectedLocation,
          onLocationSelected: (LatLng location) {
            setState(() {
              _selectedLocation = location;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Supplier'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentLocation == null
                ? Center(child: CircularProgressIndicator())
                : Stack(
              children: [
                Hero(
                  tag: 'mapHero',
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 15,
                    ),
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: _selectedLocation != null
                        ? {
                      Marker(
                        markerId: MarkerId('selectedLocation'),
                        position: _selectedLocation!,
                      ),
                    }
                        : {},
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nama Supplier'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Alamat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(labelText: 'Kontak'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kontak harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    _selectedLocation != null
                        ? 'Lokasi terpilih: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})'
                        : 'Tekan pada peta untuk memilih lokasi.',
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _saveSupplier,
                    child: Text('Simpan Supplier'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenMapPage extends StatelessWidget {
  final LatLng initialLocation;
  final LatLng? selectedLocation;
  final Function(LatLng) onLocationSelected;

  const FullscreenMapPage({
    super.key,
    required this.initialLocation,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'mapHero',
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLocation,
            zoom: 15,
          ),
          onTap: (LatLng location) {
            onLocationSelected(location);
            Navigator.pop(context); // Return to the previous screen
          },
          markers: selectedLocation != null
              ? {
            Marker(
              markerId: MarkerId('selectedLocation'),
              position: selectedLocation!,
            ),
          }
              : {},
        ),
      ),
    );
  }
}
