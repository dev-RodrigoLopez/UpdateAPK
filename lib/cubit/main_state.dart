part of 'main_cubit.dart';

enum StatusMain {
  initial,
  loading,
  success,
  error,
}

class MainState extends Equatable{

  const MainState({
    this.status = StatusMain.initial,
    this.message = '',
    this.versionName = '',
    this.versionCode = '',
    this.users = const [],
    
  });

  final StatusMain status;
  final String message;
  final String versionName;
  final String versionCode;
  final List<User> users;

  MainState copyWith({
    StatusMain? status,
    String? message,
    String? versionName,
    String? versionCode,
    List<User>? users,
  }) => MainState(
    status: status ?? this.status,
    message: message ?? this.message,
    versionName: versionName ?? this.versionName,
    versionCode: versionCode ?? this.versionCode,
    users: users ?? this.users,
  );
  
  @override
  List<Object?> get props => [
    status, 
    message,
    versionName,
    versionCode,
    users,
  ];

}


