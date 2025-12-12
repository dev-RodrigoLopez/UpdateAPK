class UpdateInfo {
  final String version;
  final int versionCode;
  final String apkUrl;

  UpdateInfo({
    required this.version,
    required this.versionCode,
    required this.apkUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'],
      versionCode: json['versionCode'],
      apkUrl: json['apkUrl'],
    );
  }
}