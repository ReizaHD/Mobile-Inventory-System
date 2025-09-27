import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mobile_inventory_system/models/supplier.dart';
import '../config.dart';

class UpdateSupplierPage extends StatefulWidget {
  final Supplier supplier;

  const UpdateSupplierPage({Key? key, required this.supplier}) : super(key: key);

  @override
  State<UpdateSupplierPage> createState() => _UpdateSupplierPageState();
}

class _UpdateSupplierPageState extends State<UpdateSupplierPage> {
  final fb = FirebaseHelper();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;

  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _addressController = TextEditingController(text: widget.supplier.address);
    _contactController = TextEditingController(text: widget.supplier.contact);
    _selectedLocation = LatLng(widget.supplier.latitude, widget.supplier.longitude);
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

  void _updateSupplier() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      final updatedSupplier = Supplier(
        id: widget.supplier.id,
        name: _nameController.text,
        address: _addressController.text,
        contact: _contactController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );

      await fb.updateSupplier(supplier: updatedSupplier, onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil diubah!')),
        );
        Navigator.pop(context, updatedSupplier);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih lokasi pada peta.')),
      );
    }
  }

  void _openFullscreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenMapPage(
          initialLocation: _selectedLocation!,
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
        title: const Text('Update Supplier'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
              children: [
                Hero(
                  tag: 'mapHero',
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation!,
                      zoom: 15,
                    ),
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selectedLocation'),
                        position: _selectedLocation!,
                      ),
                    },
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
                    decoration: const InputDecoration(labelText: 'Nama Supplier'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: 'Kontak'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kontak harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    _selectedLocation != null
                        ? 'Lokasi terpilih: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})'
                        : 'Tekan pada peta untuk memilih lokasi.',
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _updateSupplier,
                    child: const Text('Update Supplier'),
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
              markerId: const MarkerId('selectedLocation'),
              position: selectedLocation!,
            ),
          }
              : {},
        ),
      ),
    );
  }
}
