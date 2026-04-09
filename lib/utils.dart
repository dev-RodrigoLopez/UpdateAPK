import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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
Future<bool> requestStoragePermissions() async {
  if (!Platform.isAndroid) return true; // iOS no requiere

  if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
    return true;
  }

  // Android 11 o superior
  final manageStatus = await Permission.manageExternalStorage.request();
  if (manageStatus.isGranted) return true;

  // Android 10 o inferior
  final storageStatus = await Permission.storage.request();
  if (storageStatus.isGranted) return true;

  final finalStatus = await Permission.manageExternalStorage.isGranted ||
      await Permission.storage.isGranted;

  return finalStatus;
}

  /// Verifica permisos de instalación
Future<bool> checkInstallPermission() async {

  if (await Permission.requestInstallPackages.isGranted) {
    return true;
  }

  final status = await Permission.requestInstallPackages.request();

  if (status.isGranted) {
    return true;
  }

  if (await Permission.requestInstallPackages.isGranted) {
    return true;
  }

  return false;
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


  /// Instala APK usando OpenFilex
  Future<bool> installApk(File apkFile) async {
    final result = await OpenFilex.open(
      apkFile.path,
      type: "application/vnd.android.package-archive",
    );

    print('-- Resultado de instalación: ${result.type}');

    if (result.type == ResultType.done) {
      // La instalación se inició correctamente
      return true;
    }

    // Si el usuario canceló o ocurrió error
    if (result.type == ResultType.error) {
      print("El usuario canceló la instalación o ocurrió un error.");
      return false;
    }

    return false;

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

  static Future<bool> checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Future<bool> connectionChecker() async {

    bool result = await InternetConnection().hasInternetAccess;
    return result;
  }



}
