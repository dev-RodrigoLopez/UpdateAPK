import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:update_apk/cubit/main_cubit.dart';
import 'package:update_apk/data/app_database.dart';
import 'package:update_apk/data/database_instance.dart';
import 'package:update_apk/modules/add_user/add_user_view.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => MainCubit()..init(),
      child: MaterialApp(
        title: 'Actualizar App',
        home: Scaffold(
          appBar: AppBar(
            title: const Text("UpdateApp Demo"),
            centerTitle: true,
          ),
          body: BlocBuilder<MainCubit, MainState>(
            builder: (context, state) {
              if (state.status == StatusMain.loading ||
                  state.status == StatusMain.initial) {
                return Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(state.message, style: TextStyle(fontSize: 20)),
                  ],
                ));
              }
        
              if (state.status == StatusMain.error) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 50, color: Colors.red),
                        Text(state.message),
                      ]),
                );
              }
        
              return Column(children: [
                Expanded(
                  child: state.users.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.no_accounts, size: 50),
                                Text('No hay usuarios'),
                              ]),
                        )
                      : ListView.builder(
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                              horizontal: size.width * .05,
                              vertical: size.height * .005),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(  
                                    user.name, 
                                    style: TextStyle(
                                      fontSize: 15, 
                                      // fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(  
                                    ' Edad: ${user.age}',  
                                    style: TextStyle(
                                      fontSize: 15, 
                                      // fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  SizedBox(width: size.width * .03),
                                  // IconButton(
                                  //   icon: Icon(
                                  //     Icons.delete,
                                  //     // color: Colors.green,
                                  //     size: 20,
                                  //   ),
                                  //   onPressed: () {
                                  //     context.read<MainCubit>().deleteUser(user);

                                  //     // Navigator.push(
                                  //     //   context,
                                  //     //   MaterialPageRoute(
                                  //     //     builder: (context) =>
                                  //     //         AddUser(user: user), // Reemplaza con tu pantalla
                                  //     //   ),
                                  //     // );
                                  //   },
                                  // ),
                                ],
                              ),
                            );
                            // return ListTile(
                            //   title: Text(user.name),
                            //   subtitle: Text(user.age.toString()),
                            // );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * .05,
                      vertical: size.height * .01),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddUser(), // Reemplaza con tu pantalla
                        ),
                      );
                    },
                    child: Ink(
                      height: size.height * .05,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('Agregar usuario',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text('${state.versionName} (${state.versionCode})',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                )
              ]);
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
