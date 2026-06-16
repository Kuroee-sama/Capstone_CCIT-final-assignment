import 'dart:typed_data';

class PickedImageFile {
  final String name;
  final Uint8List bytes;
  final String? mimeType;

  const PickedImageFile({
    required this.name,
    required this.bytes,
    this.mimeType,
  });

  double get sizeInMb => bytes.lengthInBytes / (1024 * 1024);
}
