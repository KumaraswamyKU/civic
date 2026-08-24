import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class PickedComplaintImage {
  const PickedComplaintImage({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

class ImagePickService {
  ImagePickService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<PickedComplaintImage?> fromGallery() {
    return _pick(ImageSource.gallery);
  }

  Future<PickedComplaintImage?> fromCamera() {
    return _pick(ImageSource.camera);
  }

  Future<PickedComplaintImage?> _pick(ImageSource source) async {
    // Cap the long edge for upload size while keeping enough detail for MobileNetV2.
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) {
      return null;
    }
    final bytes = await file.readAsBytes();
    final name = file.name.trim().isEmpty ? 'complaint.jpg' : file.name;
    return PickedComplaintImage(bytes: bytes, filename: name);
  }
}
