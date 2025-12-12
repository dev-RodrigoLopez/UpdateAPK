import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:update_apk/rest_provider_update.dart';
import 'package:update_apk/update_info_model.dart';
import 'package:http/http.dart' as http;

class Utils {

  /// Verifica si hay actualización
  Future<bool> isUpdateAvailable(UpdateInfo info) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionCode = int.parse(packageInfo.buildNumber);
    return info.versionCode > currentVersionCode;
  }

  /// Solicita permisos de almacenamiento
  Future<void> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted ||
          await Permission.storage.isGranted) {
        return;
      }

      // Android 11 o superior
      if (await Permission.manageExternalStorage.request().isGranted) return;

      // Android 10 o inferior
      if (await Permission.storage.request().isGranted) return;

      throw Exception("Permisos de almacenamiento no otorgados");
    }
  }

  /// Verifica permisos de instalación
  Future<bool> checkInstallPermission() async {
    if (await Permission.requestInstallPackages.isGranted) return true;

    final status = await Permission.requestInstallPackages.request();
    return status.isGranted;
  }

  Future<File> downloadApk(String url) async {
    print('-- Descargando actualización...');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Error al descargar APK: ${response.statusCode}');
      }

      // Carpeta PRIVADA de la app (SEGURA para instalar APK)
      final dir = await getExternalStorageDirectory(); 
      final File file = File('${dir!.path}/update.apk');

      await file.writeAsBytes(response.bodyBytes, flush: true);

      print('-- APK descargado en: ${file.path}');
      print("Tamaño del APK descargado: ${file.lengthSync()} bytes");

      return file;
    } catch (e) {
      print('Error al descargar la actualización: $e');
      throw Exception('Error al descargar la actualización $e');
    }
  }

  /// Descarga APK desde Google Drive correctamente
  // Future<File> downloadGoogleDriveFile(String fileId) async {
  //   final client = http.Client();

  //   final url = Uri.parse("https://drive.google.com/uc?export=download&id=$fileId");
  //   final initialResponse = await client.get(url);

  //   if (initialResponse.headers['content-type']!.contains('text/html')) {
  //     // Google Drive requiere token de confirmación
  //     final html = initialResponse.body;
  //     final exp = RegExp("confirm=([0-9A-Za-z_]+)");
  //     final match = exp.firstMatch(html);

  //     if (match == null) {
  //       throw Exception("No se pudo obtener token de Google Drive.");
  //     }

  //     final confirmToken = match.group(1)!;
  //     final downloadUrl = Uri.parse(
  //         "https://drive.google.com/uc?export=download&confirm=$confirmToken&id=$fileId");

  //     final headers = {"Cookie": initialResponse.headers["set-cookie"] ?? ""};
  //     final downloadResponse = await client.get(downloadUrl, headers: headers);

  //     if (downloadResponse.statusCode != 200) {
  //       throw Exception("Error descargando archivo final.");
  //     }

  //     final dir = await getExternalStorageDirectory();
  //     final file = File("${dir!.path}/update.apk");
  //     await file.writeAsBytes(downloadResponse.bodyBytes, flush: true);

  //     print("-- APK descargado en: ${file.path} (${file.lengthSync()} bytes)");
  //     return file;
  //   }

  //   // Si no requiere confirmación
  //   final dir = await getExternalStorageDirectory();
  //   final file = File("${dir!.path}/update.apk");
  //   await file.writeAsBytes(initialResponse.bodyBytes, flush: true);

  //   print("-- APK descargado en: ${file.path} (${file.lengthSync()} bytes)");
  //   return file;
  // }

  /// Instala APK usando OpenFilex
  Future<void> installApk(File apkFile) async {
    final result = await OpenFilex.open(
      apkFile.path,
      type: "application/vnd.android.package-archive",
    );
    print('-- Resultado de instalación: $result');
  }

  /// Flujo completo: chequea update, permisos, descarga e instalación
  Future<void> checkAndUpdate(String fileId) async {
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo == null) return;

    final hasUpdate = await isUpdateAvailable(updateInfo);
    if (!hasUpdate) return;

    await requestStoragePermissions();

    final granted = await checkInstallPermission();
    if (!granted) return;

    final apkFile = await downloadApk(fileId);
    await installApk(apkFile);
  }
}
