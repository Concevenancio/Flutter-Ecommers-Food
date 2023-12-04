// database/cart_database_helper.dart

import 'package:ecommerce/models/products.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CartDatabaseHelper {
  static final CartDatabaseHelper _instance = CartDatabaseHelper.internal();

  factory CartDatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  CartDatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'cart.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE CartProducts (
        productId INTEGER PRIMARY KEY,
        title TEXT,
        price REAL,
        image TEXT,
        quantity INTEGER
      )
    ''');
  }

  Future<int> insertCartProduct(CartProduct cartProduct) async {
    var dbClient = await db;
    try {
      return await dbClient?.insert('CartProducts', {
        'productId': cartProduct.productId,
        'title': cartProduct.title,
        'price': cartProduct.price,
        'image': cartProduct.image,
        'quantity': cartProduct.quantity,
      }) ?? 0;
    } catch (e) {
      print("Error al insertar en la base de datos del carrito: $e");
      return 0;
    }
  }

  Future<List<CartProduct>> getCartProducts() async {
    var dbClient = await db;
    try {
      List<Map<String, dynamic>> list =
          await dbClient?.query('CartProducts') ?? [];
      return list
          .map((item) => CartProduct(
                productId: item['productId'],
                title: item['title'],
                price: item['price'],
                image: item['image'],
                quantity: item['quantity'],
              ))
          .toList();
    } catch (e) {
      print("Error al obtener datos de la base de datos del carrito: $e");
      return [];
    }
  }

  Future<int> updateCartProductQuantity(int productId, int newQuantity) async {
    var dbClient = await db;
    try {
      return await dbClient?.update('CartProducts', {'quantity': newQuantity},
              where: 'productId = ?', whereArgs: [productId]) ??
          0;
    } catch (e) {
      print("Error al actualizar la cantidad en la base de datos del carrito: $e");
      return 0;
    }
  }

  Future<int> deleteCartProduct(int productId) async {
    var dbClient = await db;
    try {
      return await dbClient?.delete('CartProducts',
              where: 'productId = ?', whereArgs: [productId]) ??
          0;
    } catch (e) {
      print("Error al eliminar de la base de datos del carrito: $e");
      return 0;
    }
  }
  
}
