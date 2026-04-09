import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:update_apk/cubit/main_cubit.dart';
import 'package:update_apk/models/user_model.dart';


class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final age = _ageController.text;

      // Imprimir en consola
      print("Nombre: $name, Edad: $age");

      // Opcional: limpiar campos
      // _nameController.clear();
      // _ageController.clear();

      // Mensaje visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario enviado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Usuario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Edad
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu edad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const Spacer(),

              InkWell(
                onTap: (){

                  if (_formKey.currentState!.validate()) {
                    final cubit = context.read<MainCubit>();
                    final user = User(
                      name: _nameController.text,
                      age: int.parse(_ageController.text),
                    );
                    cubit.addUser(user);

                    Navigator.pop(context);
                  }

                },
                child: Ink(
                  height: size.height * .05,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Guardar usuario',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      )
                    ),
                  ),
                ),
              ),

              // Botón

            ],
          ),
        ),
      ),
    );
  }
}
