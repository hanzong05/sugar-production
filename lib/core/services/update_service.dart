import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

const _downloadChannel = EventChannel('native/download');

Future<Map<String, dynamic>> updateVersion(
  String apkUrl, {
  void Function(double progress, int received, int total)? onProgress,
}) async {
  try {
    await Permission.storage.request();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/app-update.apk';

    await for (final event in _downloadChannel
        .receiveBroadcastStream({'url': apkUrl, 'filePath': filePath})
        .cast<Map>()) {
      final done = event['done'] as bool? ?? false;
      if (!done) {
        final progress = (event['progress'] as num).toDouble();
        final received = (event['received'] as num).toInt();
        final total = (event['total'] as num).toInt();
        onProgress?.call(progress, received, total);
      } else {
        break;
      }
    }

    final result = await OpenFilex.open(filePath);
    return {
      'update': true,
      'file_path': filePath,
      'install_result': result.message,
    };
  } catch (e) {
    return {'update': false, 'error': e.toString()};
  }
}
