// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import '../models/picked_image_file.dart';

Future<PickedImageFile?> pickMenuImage() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/gif'
    ..multiple = false;

  input.click();
  await input.onChange.first;

  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) return null;

  final mimeType = file.type;
  if (mimeType.isNotEmpty && !mimeType.startsWith('image/')) {
    throw Exception('File harus berupa gambar.');
  }

  const maxBytes = 5 * 1024 * 1024;
  if (file.size > maxBytes) {
    throw Exception('Ukuran gambar maksimal 5 MB.');
  }

  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;

  final result = reader.result;
  if (result is! ByteBuffer) {
    throw Exception('Gagal membaca file gambar.');
  }

  return PickedImageFile(
    name: file.name,
    bytes: Uint8List.view(result),
    mimeType: mimeType.isEmpty ? null : mimeType,
  );
}
