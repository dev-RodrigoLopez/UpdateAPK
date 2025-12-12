import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:update_apk/rest_provider_update.dart';
import 'package:update_apk/update_info_model.dart';
import 'package:http/http.dart' as http;

class Utils {


  Future<bool> isUpdateAvailable(UpdateInfo info) async {
    print('-- Validando actualización...');
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionCode = int.parse(packageInfo.buildNumber);

    return info.versionCode > currentVersionCode;
  }

  Future<void> checkPermissions() async {
    print('-- Pidiendo permisos...');

    if (!await Permission.storage.request().isGranted) {
      print('-- Error al solicitar permisos...');

      throw Exception('Permiso de almacenamiento no otorgado');
    }
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


  /// Instala el APK descargado usando OpenFilex (funciona en Huawei y Android 10+)
  Future<void> installApk(File apkFile) async {
    print('-- Instalando actualización...');

    try {
      final result = await OpenFilex.open(
        apkFile.path,
        type: "application/vnd.android.package-archive",
      );

      print('-- Resultado de instalación: $result');
      print('-- Fin de instalación');
    } catch (e) {
      print('Error al instalar la actualización: $e');
      throw Exception('Error al instalar la actualización $e');
    }
  }



  Future<bool> checkInstallPermission() async {
    print('-- Validando permisos de actualización...');

    if (await Permission.requestInstallPackages.isGranted) {
      return true;
    }

    final status = await Permission.requestInstallPackages.request();
    return status.isGranted;
  }


  Future<void> checkAndUpdate() async {
    final updateInfo = await UpdateService.checkForUpdate();

    if (updateInfo == null) return;

    final hasUpdate = await isUpdateAvailable(updateInfo);
    if (!hasUpdate) return;

    final hasPermission = await checkInstallPermission();
    if (!hasPermission) return;

    final apkFile = await downloadApk(updateInfo.apkUrl);
    await installApk(apkFile);
  }


  Future<void> requestStoragePermissions() async {
    print('-- Solicitando permisos de almacenamiento...');

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        print('-- Permiso MANAGE_EXTERNAL_STORAGE otorgado');
        return;
      }

      if (await Permission.storage.isGranted) {
        print('-- Permiso STORAGE otorgado');
        return;
      }

      // Android 11 o superior pide MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.request().isGranted) {
        print('-- Permiso MANAGE_EXTERNAL_STORAGE otorgado');
        return;
      }

      // Android 10 o inferior pide READ/WRITE
      if (await Permission.storage.request().isGranted) {
        print('-- Permiso STORAGE otorgado');
        return;
      }

      // Si llega aquí → permisos denegados
      print('-- Permisos de almacenamiento denegados');
      throw Exception("No se otorgaron permisos de almacenamiento");
    }
  }

  Future<File> downloadGoogleDriveFile(String fileId) async {
    final client = http.Client();

    // URL inicial
    final url = Uri.parse(
        "https://drive.google.com/uc?export=download&id=$fileId");

    print('-- Solicitando archivo de Google Drive...');

    final initialResponse = await client.get(url);

    // Si el archivo es grande, Google envía una página HTML con token de confirmación
    if (initialResponse.headers['content-type']!.contains('text/html')) {
      print('-- Google Drive requiere confirmación, extrayendo token...');

      final html = initialResponse.body;

      // ESTE REGEX EXTRAE EL TOKEN DE CONFIRMACIÓN
      final exp = RegExp("confirm=([0-9A-Za-z_]+)");
      final match = exp.firstMatch(html);

      if (match == null) {
        throw Exception("No se pudo obtener token de Google Drive.");
      }

      final confirmToken = match.group(1)!;

      // Segunda solicitud con token
      final downloadUrl = Uri.parse(
          "https://drive.google.com/uc?export=download&confirm=$confirmToken&id=$fileId");

      final headers = {
        "Cookie": initialResponse.headers["set-cookie"] ?? ""
      };

      final downloadResponse = await client.get(downloadUrl, headers: headers);

      if (downloadResponse.statusCode != 200) {
        throw Exception("Error descargando archivo final.");
      }

      final dir = await getExternalStorageDirectory();
      final file = File("${dir!.path}/update.apk");

      await file.writeAsBytes(downloadResponse.bodyBytes);

      print("-- Descarga completa (Google Drive). Tam: ${file.lengthSync()} bytes");
      return file;
    }

    // Si no hay confirmación y devolvió el archivo directamente
    final dir = await getExternalStorageDirectory();
    final file = File("${dir!.path}/update.apk");

    await file.writeAsBytes(initialResponse.bodyBytes);

    print("-- Descarga directa completa (Google Drive). Tam: ${file.lengthSync()} bytes");
    return file;
  }

}