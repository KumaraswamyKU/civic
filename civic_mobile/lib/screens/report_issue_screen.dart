import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../services/image_pick_service.dart';
import '../utils/error_messages.dart';
import '../utils/formatters.dart';
import '../utils/session_guard.dart';
import '../widgets/app_info_row.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _description = TextEditingController();
  final _address = TextEditingController();

  PickedComplaintImage? _image;
  double? _latitude;
  double? _longitude;
  bool _locating = false;
  bool _submitting = false;
  bool _reviewing = false;

  @override
  void dispose() {
    _description.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pick(Future<PickedComplaintImage?> Function() source, {required String unavailable}) async {
    try {
      final picked = await source();
      if (picked != null) {
        setState(() => _image = picked);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$unavailable ${userFacingError(error)}')),
      );
    }
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final location = await AuthScope.of(context).services.location.current();
      if (!mounted) {
        return;
      }
      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        if (location.address != null && location.address!.isNotEmpty) {
          _address.text = location.address!;
        }
      });
    } catch (error) {
      if (mounted) {
        await showAppError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  bool get _readyToReview =>
      _image != null && _latitude != null && _longitude != null && !_submitting;

  Future<void> _submit() async {
    final image = _image;
    final latitude = _latitude;
    final longitude = _longitude;
    if (image == null || latitude == null || longitude == null) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final complaint = await AuthScope.of(context).services.complaints.create(
        imageBytes: image.bytes,
        imageFilename: image.filename,
        description: _description.text.trim(),
        latitude: latitude,
        longitude: longitude,
        addressText: _address.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint #${complaint.id} submitted.')),
      );
      Navigator.pop(context, complaint);
    } catch (error) {
      if (mounted) {
        await showAppError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_reviewing ? 'Review complaint' : 'Report an issue')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_reviewing) _reviewBody() else _formBody(),
            ],
          ),
          if (_submitting)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _formBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Photo, description, and GPS are sent to Django as multipart form data.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (_image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_image!.bytes, height: 220, fit: BoxFit.cover),
          )
        else
          Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('No photo selected'),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _submitting
                    ? null
                    : () => _pick(
                          AuthScope.of(context).services.images.fromGallery,
                          unavailable: 'Could not open the photo picker.',
                        ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _submitting
                    ? null
                    : () => _pick(
                          AuthScope.of(context).services.images.fromCamera,
                          unavailable: kIsWeb
                              ? 'Camera capture is not available in this browser. Use an Android device, or choose a file.'
                              : 'Could not open the camera.',
                        ),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _description,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Description',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _locating || _submitting ? null : _locate,
          icon: _locating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(_locating ? 'Getting location…' : 'Use current GPS location'),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppInfoRow(
                  label: 'Latitude',
                  value: _latitude == null ? 'Not captured' : formatCoordinate(_latitude!),
                ),
                AppInfoRow(
                  label: 'Longitude',
                  value: _longitude == null ? 'Not captured' : formatCoordinate(_longitude!),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Address',
            helperText: kIsWeb
                ? 'Reverse geocoding is not used in the browser. You can type an address.'
                : 'Filled from GPS when available. You can edit it.',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _readyToReview ? () => setState(() => _reviewing = true) : null,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Review before submit'),
          ),
        ),
        if (!_readyToReview)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Add a photo and GPS coordinates before reviewing.'),
          ),
      ],
    );
  }

  Widget _reviewBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_image!.bytes, height: 220, fit: BoxFit.cover),
          ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppInfoRow(
                  label: 'Description',
                  value: _description.text.trim().isEmpty ? '(none)' : _description.text.trim(),
                ),
                AppInfoRow(label: 'Latitude', value: formatCoordinate(_latitude!)),
                AppInfoRow(label: 'Longitude', value: formatCoordinate(_longitude!)),
                AppInfoRow(
                  label: 'Address',
                  value: _address.text.trim().isEmpty ? '(none)' : _address.text.trim(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Submit complaint'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _submitting ? null : () => setState(() => _reviewing = false),
          child: const Text('Edit details'),
        ),
      ],
    );
  }
}
