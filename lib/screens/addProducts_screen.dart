// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/database/helperProducts.dart';
import '/models/products.dart';
import 'dart:io';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  // Controladores para los campos del formulario
  final TextEditingController imageController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController rankingController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController additivesController = TextEditingController();
  final TextEditingController vitaminsController = TextEditingController();
  String? imagePath;
  List<ProductsItems> productList = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    List<ProductsItems> products = await dbHelper.getFoodItems();
    setState(() {
      productList
          .clear(); // Limpia la lista actual antes de cargar los productos
      productList.addAll(products);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agregar Productos'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Agrega la lógica para regresar a la pantalla principal
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen
                imagePath != null ? Image.file(File(imagePath!)) : Container(),

                // Botón para abrir la cámara
                ElevatedButton(
                  onPressed: _takePicture,
                  child: const Text('Tomar Foto'),
                ),
                // Categoría
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
                const SizedBox(height: 16.0),

                // Precio
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),

                // Ranking (utilizando un RatingBar)
                TextFormField(
                  controller: rankingController,
                  decoration: const InputDecoration(labelText: 'Ranking'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),

                // Título
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16.0),

                // Descripción
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),

                // Calorías
                TextFormField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Calorías'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),

                // Aditivos
                TextFormField(
                  controller: additivesController,
                  decoration: const InputDecoration(labelText: 'Aditivos'),
                ),
                const SizedBox(height: 16.0),

                // Vitaminas
                TextFormField(
                  controller: vitaminsController,
                  decoration: const InputDecoration(labelText: 'Vitaminas'),
                ),
                const SizedBox(height: 16.0),

                const SizedBox(height: 16.0),
                // Botón para enviar el formulario
                ElevatedButton(
                  onPressed: () {
                    // Aquí puedes agregar la lógica para enviar el formulario
                    _addProduct();
                    _clearForm();
                  },
                  child: const Text('Añadir Producto'),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Lista de Productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                productList.isEmpty
                    ? const Text('No hay productos añadidos.')
                    : DataTable(
                        columns: const [
                          DataColumn(label: Text('Título')),
                          DataColumn(label: Text('Eliminar')),
                        ],
                        rows: productList.map((product) {
                          return DataRow(cells: [
                            DataCell(Text(product.title)),
                            DataCell(
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Aquí puedes agregar la lógica para eliminar el producto
                                  _deleteProduct(product
                                      .id); // Llama a la función para eliminar el producto
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                ),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                label: const Text(
                                  '',
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  void _clearForm() {
    categoryController.clear();
    priceController.clear();
    rankingController.clear();
    titleController.clear();
    descriptionController.clear();
    caloriesController.clear();
    additivesController.clear();
    vitaminsController.clear();
    setState(() {
      imagePath = null;
    });
  }

  void _addProduct() async {
    // Obtener los valores de los controladores
    String category = categoryController.text;
    double price = double.parse(priceController.text);
    int ranking = int.parse(rankingController.text);
    String title = titleController.text;
    String description = descriptionController.text;
    int calories = int.parse(caloriesController.text);
    int additives = int.parse(additivesController.text);
    int vitamins = int.parse(vitaminsController.text);

    // Verificar si hay una imagen seleccionada
    if (imagePath == null || imagePath!.isEmpty) {
      // Aquí puedes manejar el caso de que no se haya seleccionado una imagen
      print('Error: Debes seleccionar una imagen');
      return;
    }

    // Crear un objeto ProductsItems con los valores del formulario
    ProductsItems product = ProductsItems(
      id: 0, // El ID se asignará automáticamente en la base de datos
      title: title,
      description: description,
      category: category,
      image: imagePath!, // Utiliza la ruta de la imagen seleccionada
      price: price,
      ranking: ranking,
      calories: calories,
      additives: additives,
      vitamins: vitamins,
    );

    // Insertar el producto en la base de datos
    int result = await dbHelper.insertFoodItem(product);

    // Verificar si la inserción fue exitosa
    if (result != 0) {
      // Mostrar un mensaje de éxito o navegar a otra pantalla
      print('Producto añadido con éxito');
      // Actualizar la lista de productos después de agregar uno nuevo
      _loadProducts();
      // Limpiar el formulario
      _clearForm();
    } else {
      // Mostrar un mensaje de error
      print('Error al añadir el producto');
    }
  }

  void _deleteProduct(int productId) async {
    // Llama al método en DatabaseHelper para eliminar el producto
    int result = await dbHelper.deleteFoodItem(productId);

    // Verificar si la eliminación fue exitosa
    if (result != 0) {
      // Mostrar un mensaje de éxito o realizar cualquier otra acción necesaria
      print('Producto eliminado con éxito');
      // Actualizar la lista de productos después de eliminar uno
      _loadProducts();
    } else {
      // Mostrar un mensaje de error
      print('Error al eliminar el producto');
    }
  }
}
