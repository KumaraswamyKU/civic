import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/location_service.dart';

class UploadComplaintScreen extends StatefulWidget {
  const UploadComplaintScreen({super.key});

  @override
  State<UploadComplaintScreen> createState() => _UploadComplaintScreenState();
}

class _UploadComplaintScreenState extends State<UploadComplaintScreen> {
  final _descriptionController = TextEditingController();
  final _apiService = ApiService();
  final _locationService = LocationService();

  File? _imageFile;
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;
  bool _submitting = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _captureLocation() async {
    setState(() {
      _fetchingLocation = true;
      _error = null;
    });
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (_imageFile == null) {
      setState(() => _error = 'Please add a photo of the issue.');
      return;
    }
    if (_latitude == null || _longitude == null) {
      setState(() => _error = 'Please capture your GPS location first.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _apiService.submitComplaint(
        imageFile: _imageFile!,
        description: _descriptionController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a civic issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile == null
                    ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Streetlight has been off for 3 nights',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.my_location),
              title: Text(_latitude == null
                  ? 'Location not captured yet'
                  : 'Lat ${_latitude!.toStringAsFixed(5)}, Lng ${_longitude!.toStringAsFixed(5)}'),
              trailing: _fetchingLocation
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(onPressed: _captureLocation, child: const Text('Capture GPS')),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit complaint'),
            ),
          ],
        ),
      ),
    );
  }
}
