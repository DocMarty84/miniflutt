import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

void launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw Exception('Could not launch $url');
  }
}

Future<bool> _checkPermission() async {
  var status = await Permission.storage.status;
  if (status.isDenied) {
    await Permission.storage.request();
    status = await Permission.storage.status;
  }
  if (status.isGranted) {
    return true;
  }
  return false;
}

Future<String> downloadURL(String url) async {
  String fileName = url.split('/').last.split('?').first;
  String downloadPath = '/storage/emulated/0/Download';

  // Get permission and download file
  final Future<bool> permissionReadyFut = _checkPermission();
  final Future<http.Response> responseFut = http.get(Uri.parse(url));

  // Get download path
  final bool permissionReady = await permissionReadyFut;
  if (!permissionReady ||
      FileSystemEntity.typeSync(downloadPath) ==
          FileSystemEntityType.notFound) {
    downloadPath = (await getExternalStorageDirectory())!.path;
  }

  // Get absolute file path. If a file with the same name exists, prepend the date.
  String filePath = '$downloadPath${Platform.pathSeparator}$fileName';
  if (FileSystemEntity.typeSync(filePath) != FileSystemEntityType.notFound) {
    final String now = '${DateTime.now().toString().substring(0, 19)}';
    filePath = '$downloadPath${Platform.pathSeparator}$now - $fileName';
  }
  final File file = File(filePath);

  // Save the file
  final http.Response response = await responseFut;
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}
