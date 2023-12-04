// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dataProvider.dart';
import 'package:provider/provider.dart';
//database
import 'database/db_helper.dart';
import 'database/helperProducts.dart';
//models
import 'models/categories.dart';
import 'models/products.dart';
//screens
import 'screens/product_details.dart';
import 'screens/addCategories.dart';
import 'screens/cart_screen.dart';
import 'screens/addProducts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initializeDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: HomePage(), debugShowCheckedModeBanner: false);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Categories> categories = [];
  late DatabaseHelper dbHelper;
  ProductsItems? selectedProduct;
  Color randomBorderColor = Colors.transparent;
  String selectedCategory = 'Frutas';
  String selectedCategoryImage = '';

  void onProductSelected(ProductsItems product) {
    setState(() {
      selectedProduct = product;
      randomBorderColor = getRandomColor();
      print('Selected Product: $selectedProduct');

      // Actualizar la categoría seleccionada cuando se selecciona un producto
      selectedCategory = product.category;

      // Actualizar la imagen de la categoría seleccionada
      selectedCategoryImage = categories
          .firstWhere((category) => category.texto == selectedCategory)
          .imagen;
    });
  }

  Color getRandomColor() {
    final Random random = Random();
    final color = Color.fromRGBO(
      random.nextInt(128),
      random.nextInt(128),
      random.nextInt(128),
      1,
    );
    print('Random Color: $color');
    return color;
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper(); // Inicialización de la instancia
    print('initState called');
    loadData();
  }

  Future<void> loadData() async {
    try {
      List<Categories> loadedCategories = await DBHelper.getAllCategories();
      print('Categories loaded: $loadedCategories');
      setState(() {
        categories = loadedCategories;
      });
      print('Categories updated: $categories');
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Color hexToColor(String colorCode) {
    try {
      if (colorCode.startsWith("#") && colorCode.length == 7) {
        return Color(
            int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000);
      } else {
        return _getColorFromName(colorCode);
      }
    } catch (e) {
      print('Error converting color: $e');
      return Colors.transparent;
    }
  }

  Color _getColorFromName(String colorName) {
    Map<String, int> colorMap = {
      'Black': 0xFF000000,
      'Blue': 0xFF0000FF,
      'Red': 0xFFFF0000,
    };

    final colorValue = colorMap[colorName];
    if (colorValue != null) {
      return Color(colorValue);
    } else {
      print('Unknown color name: $colorName');
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce food'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
//Hamburguer -Start
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 225, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'E-commerce food Conce',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Inicio',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Agregar Productos',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProducts()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Agregar Categorias',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddCategoriesScreen()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Carrito',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
          ],
        ),
      ),
//Hamburguer -End

      body: SingleChildScrollView(
        // Añade SingleChildScrollView aquí
        child: Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5.0),
              const Text(
                'Hola Conce!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "What's today's taste? 😋",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0), // Ajusta según tus preferencias

              FutureBuilder<List<Categories>>(
                future: DBHelper.getAllCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No data available');
                  } else {
                    List<Categories> categories = snapshot.data!;
                    print('Categories: $categories');

                    return Container(
                      height: 100.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          Categories category = categories[index];
                          return GestureDetector(
                            onTap: () {
                              // Actualizar la categoría seleccionada cuando se toca una categoría
                              setState(() {
                                selectedCategory = category.texto;

                                // Actualizar la imagen de la categoría seleccionada
                                selectedCategoryImage = category.imagen;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: hexToColor(category
                                          .colorCategory), // Color original
                                      border: Border.all(
                                        color: selectedCategory ==
                                                category.texto
                                            ? Color.fromARGB(255, 160, 132,
                                                10) // Color vino cuando está seleccionado
                                            : Colors
                                                .transparent, // Borde transparente cuando no está seleccionado
                                        width: 3.0,
                                      ),
                                    ),
                                    child: ClipRect(
                                      child: Image.file(
                                        File(category.imagen),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print('Error loading image: $error');
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    category.texto,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 350.0,
                        height: 350.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getRandomColor(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (selectedProduct != null &&
                                  selectedProduct!.image.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsScreen(
                                                  product: selectedProduct),
                                        ),
                                      );
                                    },
                                    child: ClipRect(
                                      child: Container(
                                        width: 120.0,
                                        height: 120.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors
                                                .black, // Puedes ajustar el color del borde según tus preferencias
                                            width:
                                                6.0, // Puedes ajustar el ancho del borde según tus preferencias
                                          ),
                                        ),
                                        child: Image.file(
                                          File(selectedProduct!.image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                  width: 15.0), // Adjust spacing as needed
                              if (selectedProduct != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 80.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedProduct!.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        '\$${selectedProduct!.price}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      RatingBar.builder(
                                        initialRating:
                                            selectedProduct!.ranking.toDouble(),
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          // Lógica de actualización de la calificación
                                        },
                                      ),
                                      const SizedBox(height: 50.0),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // Lógica para agregar al carrito
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                        ),
                                        icon: const Icon(Icons.shopping_cart,
                                            color: Colors.black),
                                        label: const Text(
                                          'Add to Cart',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0.5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 100.0,
                      child: FutureBuilder<List<ProductsItems>>(
                        future: dbHelper.getFoodItems(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              List<ProductsItems>? products = snapshot.data;

                              // Filtrar los productos según la categoría seleccionada
                              List<ProductsItems>? filteredProducts = products
                                  ?.where((product) =>
                                      product.category == selectedCategory)
                                  .toList();

                              return filteredProducts != null &&
                                      filteredProducts.isNotEmpty
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: filteredProducts.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            onProductSelected(
                                                filteredProducts![index]);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                    color: selectedProduct ==
                                                            null
                                                        ? Colors.grey
                                                        : selectedProduct!.id ==
                                                                filteredProducts[
                                                                        index]
                                                                    .id
                                                            ? Colors.green
                                                            : Colors.grey,
                                                    width: 3.0,
                                                  ),
                                                  image: DecorationImage(
                                                    image: FileImage(
                                                      File(filteredProducts[
                                                                  index]
                                                              .image
                                                              .isNotEmpty
                                                          ? filteredProducts[
                                                                  index]
                                                              .image
                                                          : 'default_image_path'),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox(); // Si no hay productos disponibles para la categoría seleccionada, muestra un contenedor vacío
                            } else {
                              return const Text(
                                  'No hay productos disponibles.');
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
