// ignore_for_file: avoid_print, use_build_context_synchronously, file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/models/categories.dart';
import '/database/db_helper.dart';
import '/dataProvider.dart';
import 'package:provider/provider.dart';

class AddCategoriesScreen extends StatefulWidget {
  const AddCategoriesScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddCategoriesScreenState createState() => _AddCategoriesScreenState();
}

class _AddCategoriesScreenState extends State<AddCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedImagePath = '';
  late String _selectedColor = 'Black';
  late TextEditingController _titleController;

  void _deleteCategory(int? categoryId) async {
    if (categoryId != null) {
      await DBHelper.deleteCategory(categoryId);
    }
  }

  _AddCategoriesScreenState() {
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedColor = 'Black'; // O el color que desees como valor inicial
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImagePath = pickedFile?.path ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Agregar Categorias'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selectedImagePath.isNotEmpty &&
                        File(_selectedImagePath).existsSync())
                      Image.file(
                        File(_selectedImagePath),
                        height: 100.0,
                        width: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ElevatedButton(
                      onPressed: _getImage,
                      child: const Text('Select Image'),
                    ),
                    TextFormField(
                      controller: _titleController,
                      decoration:
                          const InputDecoration(labelText: 'Category Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedColor,
                      onChanged: (value) {
                        setState(() {
                          _selectedColor = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'Black',
                          child: Text('Black'),
                        ),
                        DropdownMenuItem(
                          value: 'Red',
                          child: Text('Red'),
                        ),
                        DropdownMenuItem(
                          value: 'Blue',
                          child: Text('Blue'),
                        ),
                        DropdownMenuItem(
                          value: 'Green',
                          child: Text('Green'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Category Color',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        print('Add Category Button Pressed');
                        print('Form state: ${_formKey.currentState}');
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          print('Form is valid');
                          final newCategory = Categories(
                            imagen: _selectedImagePath,
                            texto: _titleController.text,
                            colorCategory: _selectedColor,
                          );
                          print('Calling DBHelper.insert');
                          await DBHelper.insert(newCategory);
                          final dataProvider = Provider.of<DataProvider>(context, listen: false);
                          final newCategories = await DBHelper.getAllCategories();
                          dataProvider.updateCategories(newCategories);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCategoriesScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text('Add Category'),
                    ),
                  ],
                ),
              ),

              // Sección de Categorías
              const SizedBox(
                height: 50.0,
              ),
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),

              // Lista de Categorías
              FutureBuilder<List<Categories>>(
                future: DBHelper.getAllCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No categories available');
                  } else {
                    // Mostrar la lista de categorías
                    return Column(
                      children: snapshot.data!.map((category) {
                        return ListTile(
                          title: Text(category.texto),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _deleteCategory(category.id);
                              setState(() {
                                snapshot.data!.remove(category);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  await DBHelper.deleteAllCategories();
                  setState(() {});
                },
                child: const Text('Eliminar todos los registros'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
