import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AlbumMediaStore {
  const AlbumMediaStore();

  Future<String> importPhoto({
    required String albumId,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Photo file not found');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final albumDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}albums${Platform.pathSeparator}$albumId',
    );
    if (!await albumDirectory.exists()) {
      await albumDirectory.create(recursive: true);
    }

    final extension = _extensionOf(sourcePath);
    final targetPath =
        '${albumDirectory.path}${Platform.pathSeparator}photo-${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '' : '.$extension'}';
    final copied = await sourceFile.copy(targetPath);
    return copied.path;
  }

  String _extensionOf(String path) {
    final index = path.lastIndexOf('.');
    if (index < 0 || index + 1 >= path.length) {
      return '';
    }
    return path.substring(index + 1).toLowerCase();
  }
}
