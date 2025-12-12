import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:update_apk/cubit/main_cubit.dart';
import 'package:update_apk/data/app_database.dart';
import 'package:update_apk/data/database_instance.dart';


late AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseInstance.instance;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'Actualizar App',
      home: BlocProvider(
        create: (context) => MainCubit()..init(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("UpdateApp Demo"),
            centerTitle: true,
          ),
          body: BlocBuilder<MainCubit, MainState>(
            builder: (context, state) {

              if (state.status == StatusMain.loading) {
                return  Center(child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
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

              return Column(
                children: [
                  Expanded(
                    child: state.users.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Icon( Icons.no_accounts, size: 100),
                            Text( 'No hay usuarios' ),
                          ]
                        ),
                      )
                    : ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.age.toString()),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      '${state.versionName} (${state.versionCode})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      )
                    ),
                  )

                ]
              );
            },
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: checking ? null : handleUpdate,
          //   child: const Icon(Icons.install_mobile),
          // ),
        ),
      ),
    );
  }
}
