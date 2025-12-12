import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:update_apk/data/database_instance.dart';
import 'package:update_apk/models/user_model.dart';
import 'package:update_apk/rest_provider_update.dart';
import 'package:update_apk/utils.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());


  Future<void> init() async{

    final info = await PackageInfo.fromPlatform();

    // 1.- Consultar el Endpoint de Versiones
    final updateInfo = await UpdateService.checkForUpdate();
    
    // 2.- Comparar versiones
    final needsUpdate = await Utils().isUpdateAvailable(updateInfo);
    if (needsUpdate) {
    // if (!needsUpdate) {

      await getAllUsers();

      emit(
        state.copyWith(
          status: StatusMain.success, 
          message: "La app esta actualizada",
          versionName: info.version,
          versionCode: info.buildNumber,
          users: state.users,
        )
      );
      return;
    }

    emit(state.copyWith(status: StatusMain.loading, message: "Actualizando aplicación..."));

    // 3.- Si la app requiere actualizarse Solicitar permisos de almacenamiento
    //      O validar que esos permisos ya esten otorgados
    await Utils().requestStoragePermissions();

    // 4.- Descargar el APK. -> Este Link debe ser descarga directa
    final apkFile = await Utils().downloadApk(updateInfo.apkUrl);

    // 5.- Solicitar permoisos o validar los permisos para instalar aplicaciones
    final granted = await Utils().checkInstallPermission();
    if (!granted) {
      emit(state.copyWith(status: StatusMain.error, message: "Permisos de Instalación denegados"));
      return;
    }

    // 6.- Instalar APK
    await Utils().installApk(apkFile);

    emit(state.copyWith(status: StatusMain.success, message: ""));


  }

  Future<List<User>> getAllUsers() async {

    final instanceDB = await DatabaseInstance.instance; 
    final user = instanceDB.userDao.getAllUsers();
    return user;

  }


}
