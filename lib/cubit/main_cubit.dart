import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:update_apk/data/database_instance.dart';
import 'package:update_apk/models/user_model.dart';
import 'package:update_apk/rest_provider_update.dart';
import 'package:update_apk/utils.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());


  Future<void> init() async{

    final info = await PackageInfo.fromPlatform();
    final users = await getAllUsers();

    if (!await Utils.checkInternetConnection() || !await Utils.connectionChecker()) {

      emit(
        state.copyWith(
          status: StatusMain.success, 
          message: "La app esta actualizada",
          versionName: info.version,
          versionCode: info.buildNumber,
          users: users,
          // status: StatusMain.error, 
          // message: "Es necesario contar con conexion a Internet",
        )
      );
      return;
    }


    // 1.- Consultar el Endpoint de Versiones
    final updateInfo = await UpdateService.checkForUpdate();

    print( '-- Validando si necesita actualizacion $updateInfo' );
    
    // 2.- Comparar versiones
    final needsUpdate = await Utils().isUpdateAvailable(updateInfo);

    if (! needsUpdate) {


      emit(
        state.copyWith(
          status: StatusMain.success, 
          message: "La app esta actualizada",
          versionName: info.version,
          versionCode: info.buildNumber,
          users: users,
        )
      );
      return;
    }

    emit(state.copyWith(status: StatusMain.loading, message: "Actualizando aplicación..."));

    // 3.- Si la app requiere actualizarse Solicitar permisos de almacenamiento
    //      O validar que esos permisos ya esten otorgados
    final permissionStorage = await Utils().requestStoragePermissions();

    if (!permissionStorage) {
      emit(state.copyWith(status: StatusMain.error, message: "Permisos de almacenamiento denegados"));
      await openAppSettings();
      return;
    }

    emit(state.copyWith(status: StatusMain.loading, message: "descargando aplicación..."));

    // 4.- Descargar el APK. -> Este Link debe ser descarga directa
    final apkFile = await Utils().downloadApk(updateInfo.apkUrl);

    // 5.- Solicitar permoisos o validar los permisos para instalar aplicaciones
    final granted = await Utils().checkInstallPermission();
    if (!granted) {
      emit(state.copyWith(status: StatusMain.error, message: "Permisos de instalación denegados"));
      await openAppSettings();
      return;
    }

    // 6.- Instalar APK
    await Utils().installApk(apkFile);

    await Future.delayed(const Duration(seconds: 2));
    await init();

    emit(state.copyWith(status: StatusMain.success, message: ""));


  }

  Future<List<User>> getAllUsers() async {

    final instanceDB = await DatabaseInstance.instance; 
    final users = await instanceDB.userDao.getAllUsers();
    return users;

  }

  Future<void> addUser(User user) async {
    final instanceDB = await DatabaseInstance.instance; 
    final idUser = await instanceDB.userDao.insertUser(user);
    print( idUser );

    final listUsers = await getAllUsers();

    emit(state.copyWith(users: listUsers));

  }

  Future<void> deleteUser(User user) async {
    final instanceDB = await DatabaseInstance.instance; 
    await instanceDB.userDao.deleteUser(user);
    final listUsers = await getAllUsers();
    emit(state.copyWith(users: listUsers));
  }


}
