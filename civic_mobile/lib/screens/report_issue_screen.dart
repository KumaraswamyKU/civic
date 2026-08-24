import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../providers/auth_provider.dart';
import '../services/image_pick_service.dart';
import '../utils/error_messages.dart';
import '../utils/formatters.dart';
import '../utils/issue_visual.dart';
import '../utils/session_guard.dart';

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
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  bool get _canSubmit =>
      _image != null && _latitude != null && _longitude != null && !_submitting;

  Future<void> _submit() async {
    final image = _image;
    final latitude = _latitude;
    final longitude = _longitude;
    if (image == null || latitude == null || longitude == null) {
      return;
    }
    final services = AuthScope.of(context).services;
    setState(() => _submitting = true);
    try {
      final complaint = await services.complaints.create(
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
      await _showSuccess(complaint);
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

  Future<void> _showSuccess(Complaint complaint) async {
    final openDetail = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CivicTokens.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: CivicTokens.success, size: 52),
              const SizedBox(height: 12),
              Text(
                'Issue identified',
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                formatComplaintId(complaint.id),
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CivicTokens.hero,
                  borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
                ),
                child: Column(
                  children: [
                    Icon(issueTypeIcon(complaint.issueType), color: CivicTokens.mint, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      formatDisplayLabel(complaint.issueType),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatConfidence(complaint.classificationConfidence)} confidence',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Assigned to',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                    Text(
                      complaint.departmentName?.isNotEmpty == true
                          ? complaint.departmentName!
                          : 'Unassigned',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('View complaint'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Back to home'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context, openDetail == true ? complaint : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue')),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: _Stepper(step: _step),
                ),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      if (_step == 0) _captureStep(),
                      if (_step == 1) _locationStep(),
                      if (_step == 2) _reviewStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : () => setState(() => _step -= 1),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _primaryEnabled ? _onPrimary : null,
                          child: Text(_primaryLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_submitting)
              ColoredBox(
                color: CivicTokens.hero.withValues(alpha: 0.88),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: CivicTokens.mint),
                        SizedBox(height: 20),
                        Text(
                          'Analyzing your report',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'AI is identifying the civic issue…',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _primaryLabel {
    if (_step == 0) {
      return 'Continue';
    }
    if (_step == 1) {
      return 'Review report';
    }
    return 'Submit report';
  }

  bool get _primaryEnabled {
    if (_submitting) {
      return false;
    }
    if (_step == 0) {
      return _image != null;
    }
    if (_step == 1) {
      return _latitude != null && _longitude != null;
    }
    return _canSubmit;
  }

  void _onPrimary() {
    if (_step < 2) {
      setState(() => _step += 1);
      return;
    }
    _submit();
  }

  Widget _captureStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Take a photo of the problem', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _ImagePreview(
          image: _image,
          onRemove: _image == null ? null : () => setState(() => _image = null),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(
                  AuthScope.of(context).services.images.fromCamera,
                  unavailable: kIsWeb
                      ? 'Camera is not available in this browser. Choose a photo instead.'
                      : 'Could not open the camera.',
                ),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(_image == null ? 'Take photo' : 'Retake'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(
                  AuthScope.of(context).services.images.fromGallery,
                  unavailable: 'Could not open the gallery.',
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(_image == null ? 'Gallery' : 'Replace'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _description,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Tell us what happened…',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _locationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm where this is', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _LocationCard(
          locating: _locating,
          address: _address.text,
          latitude: _latitude,
          longitude: _longitude,
          onRetry: _locate,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Address',
            hintText: 'You can edit the address if needed',
          ),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final place = _address.text.trim().isEmpty ? 'Current location' : _address.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review report', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _ImagePreview(image: _image),
        const SizedBox(height: 12),
        Text(
          _description.text.trim().isEmpty ? 'No description added.' : _description.text.trim(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: CivicTokens.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(place)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'The department will be assigned automatically after AI classification.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Capture', 'Location', 'Review'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step ? CivicTokens.primary : CivicTokens.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == step ? FontWeight.w800 : FontWeight.w600,
                    color: i <= step ? CivicTokens.navy : CivicTokens.muted,
                  ),
                ),
              ],
            ),
          ),
          if (i < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, this.onRemove});

  final PickedComplaintImage? image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image == null)
              ColoredBox(
                color: CivicTokens.surfaceAlt,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera_outlined, size: 42, color: CivicTokens.primary.withValues(alpha: 0.8)),
                    const SizedBox(height: 8),
                    const Text('Add a photo', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            else
              Image.memory(image!.bytes, fit: BoxFit.cover),
            if (onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: 'Remove photo',
                  style: IconButton.styleFrom(backgroundColor: CivicTokens.hero.withValues(alpha: 0.8)),
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locating,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onRetry,
  });

  final bool locating;
  final String address;
  final double? latitude;
  final double? longitude;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasFix = latitude != null && longitude != null;
    String title;
    String subtitle;
    if (locating) {
      title = 'Getting location…';
      subtitle = 'Please keep location services on.';
    } else if (hasFix) {
      title = address.trim().isEmpty ? 'Current location' : address.trim();
      subtitle = '${formatCoordinate(latitude!)}, ${formatCoordinate(longitude!)}';
    } else {
      title = 'Location unavailable';
      subtitle = 'Enable GPS and try again so the department can find the issue.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CivicTokens.surface,
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
        border: Border.all(color: CivicTokens.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: CivicTokens.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          locating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  tooltip: 'Refresh location',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                ),
        ],
      ),
    );
  }
}
