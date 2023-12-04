import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/models/products.dart';

class DatabaseHelper {

  
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db; // Note the change to allow null

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<void> closeDb() async {
    var dbClient = await db;
    await dbClient?.close();
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'food.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ProductsItems (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        category TEXT,
        image TEXT,
        price REAL,
        ranking INTEGER,
        calories INTEGER,
        additives INTEGER,
        vitamins INTEGER
      )
    ''');
  }

  Future<int> insertFoodItem(ProductsItems foodItem) async {
    var dbClient = await db;
    try {
      print("Si se insertaron bien");
      return await dbClient?.insert(
              'ProductsItems', foodItem.toMap(excludeId: true)) ??
          0;
    } catch (e) {
      print("Error al insertar en la base de datos: $e");
      return 0;
    }
  }

  Future<List<ProductsItems>> getFoodItems() async {
    var dbClient = await db;
    try {
      List<Map<String, dynamic>> list =
          await dbClient?.query('ProductsItems') ?? [];
      return list
          .map((item) => ProductsItems(
                id: item['id'],
                title: item['title'],
                description: item['description'],
                category: item['category'],
                image: item['image'],
                price: item['price'],
                ranking: item['ranking'],
                calories: item['calories'],
                additives: item['additives'],
                vitamins: item['vitamins'],
              ))
          .toList();
    } catch (e) {
      print("Error al obtener datos de la base de datos: $e");
      return [];
    }
  }

  Future<int> deleteFoodItem(int productId) async {
    var dbClient = await db;
    try {
      return await dbClient?.delete('ProductsItems',
              where: 'id = ?', whereArgs: [productId]) ??
          0;
    } catch (e) {
      print("Error al eliminar de la base de datos: $e");
      return 0;
    }
  }
  Future<Map<String, dynamic>> getProductDetails(int productId) async {
    var dbClient = await db;
    try {
      List<Map<String, dynamic>> result = await dbClient?.query('ProductsItems', where: 'id = ?', whereArgs: [productId]) ?? [];
      if (result.isNotEmpty) {
        return result.first;
      } else {
        return {}; // Retorna un mapa vacío si no se encuentra el producto
      }
    } catch (e) {
      print("Error al obtener detalles del producto: $e");
      throw Exception("Failed to get product details");
    }
  }
    Future<int> updateFoodItem(ProductsItems foodItem) async {
  var dbClient = await db;
  try {
    return await dbClient?.update('ProductsItems', foodItem.toMap(),
        where: 'id = ?', whereArgs: [foodItem.id]) ?? 0;
  } catch (e) {
    print("Error al actualizar en la base de datos: $e");
    return 0;
  }
}

// 555

}
