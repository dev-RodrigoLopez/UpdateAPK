import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:update_apk/update_info_model.dart';

class UpdateService {
  static Future<UpdateInfo> checkForUpdate() async {
    // final response = await http.get(
    //   Uri.parse('https://tu-backend.com/app/version'),
    // );

    // if (response.statusCode != 200) return null;

    // final json = jsonDecode(response.body);

    final json = {
      "version": "1.0.0",
      "versionCode": 2,
      "apkUrl": "https://github.com/dev-RodrigoLopez/Video_component/releases/download/v1.0.0/app-release.apk",
      // "apkUrl": "https://drive.google.com/file/d/1-nZEnorVTw-vEvoV4c5vXLcwla71MqVL/view?usp=sharing",
    };

    return UpdateInfo.fromJson(json);
  }
}
