import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../domain/Model/expense/expense_v1.dart';

/// Keep handles rather than all file bytes while a large upload is pending.
class ExpenseUploadFile {
  final XFile file;
  final String name;
  ExpenseUploadFile(this.file, {String? name}) : name = name ?? file.name;

  Future<dio.MultipartFile> multipart() async => dio.MultipartFile.fromStream(
    () => file.openRead(),
    await file.length(),
    filename: name,
    contentType: dio.DioMediaType.parse(contentType(name)),
  );

  static String contentType(String name) =>
      switch (name.split('.').last.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'heic' => 'image/heic',
        'pdf' => 'application/pdf',
        _ => 'application/octet-stream',
      };

  static Future<List<ExpenseUploadFile>> choose({
    required bool camera,
    required Map<String, dynamic> settings,
  }) async {
    final List<ExpenseUploadFile> files;
    if (camera) {
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);
      files = photo == null ? [] : [ExpenseUploadFile(photo)];
    } else {
      files = (await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            RegExp(r'JPEG|JPG|PNG|WEBP|HEIC|PDF', caseSensitive: false)
                .allMatches('${settings['allowed'] ?? 'JPG PNG WEBP HEIC PDF'}')
                .map((m) => m.group(0)!.toLowerCase())
                .expand((e) => e == 'jpg' ? ['jpg', 'jpeg'] : [e])
                .toSet()
                .toList(),
      )).map((f) => ExpenseUploadFile(f.xFile, name: f.name)).toList();
    }
    final maxBytes = expenseNumber(settings['max_mb'] ?? 10) * 1024 * 1024;
    for (final file in files) {
      final length = await file.file.length();
      if (length == 0 || length > maxBytes) {
        throw ExpenseApiException(
          null,
          '${file.name}: choose a non-empty file up to ${settings['max_mb'] ?? 10} MB.',
        );
      }
    }
    return files;
  }
}
