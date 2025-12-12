import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:update_apk/cubit/main_cubit.dart';


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool checking = false;
  String? status;
  String versionName = "";
  String versionCode = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        versionName = info.version;
        versionCode = info.buildNumber;
      });
    });
  }

  /// Función que maneja toda la actualización
  Future<void> handleUpdate() async {
    // setState(() {
    //   checking = true;
    //   status = "Consultando versión...";
    // });

    // try {
    // final updateInfo = await UpdateService.checkForUpdate();
    // if (updateInfo == null) {
    //   setState(() => status = "No hay actualización disponible.");
    //   return;
    // }

    // final needsUpdate = await Utils().isUpdateAvailable(updateInfo);
    // if (!needsUpdate) {
    //   setState(() => status = "La app está actualizada.");
    //   return;
    // }

    // setState(() => status = "Solicitando permisos de almacenamiento...");
    // await Utils().requestStoragePermissions();

    // setState(() => status = "Descargando APK...");

    // Usamos el fileId de Google Drive en lugar de la URL
    // final fileId = "1-nZEnorVTw-vEvoV4c5vXLcwla71MqVL";
    // final apkFile = await Utils().downloadApk(updateInfo.apkUrl);

    // setState(() => status = "Validando permisos de instalación...");
    // final granted = await Utils().checkInstallPermission();
    // if (!granted) {
    //   setState(() => status = "Permiso de instalación denegado.");
    //   return;
    // }

    // setState(() => status = "Instalando actualización...");
    // await Utils().installApk(apkFile);

    //   setState(() => status = "Actualización finalizada correctamente.");
    // } catch (e) {
    //   setState(() => status = "Error: $e");
    // } finally {
    //   setState(() => checking = false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actualizar App',
      home: BlocProvider(
        create: (context) => MainCubit()..init(),
        child: Scaffold(
          appBar: AppBar(title: const Text("Información de versión")),
          body: BlocBuilder<MainCubit, MainState>(
            builder: (context, state) {

              if (state.status == StatusMain.loading) {
                return  Center(child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 20
                      )
                    ),
                  ],
                ));
              }

              return Text(
                "Version Name: ${state.versionName}\nVersion Code: ${state.versionCode}",
                textAlign: TextAlign.center,
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: checking ? null : handleUpdate,
            child: const Icon(Icons.install_mobile),
          ),
        ),
      ),
    );
  }
}
