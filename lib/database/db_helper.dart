import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '/models/categories.dart';
import 'dart:async';

class DBHelper {
  static Future<Database> _openDB() async {
    print('Opening database');
    return openDatabase(join(await getDatabasesPath(), 'categorias.db'),
        onCreate: (db, version) {
      return db.execute('''
           CREATE TABLE categorias (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             imagen TEXT,
             texto TEXT,
             colorCategory TEXT
           )
         ''');
    },
    version: 3,
    onDowngrade: onDatabaseDowngradeDelete); // Evitar problemas de versión
  }
 static StreamController<List<Categories>> _categoriesController =
      StreamController<List<Categories>>.broadcast();

  static Stream<List<Categories>> get categoriesStream =>
      _categoriesController.stream;

static Future<void> initializeDatabase() async {
  await _openDB();
  await reloadAllCategories();  
  // Puedes realizar cualquier inicialización adicional aquí.
}
static Future<int> insert(Categories categories) async {
  Database database = await _openDB();
  try {
    int result = await database.insert("categorias", categories.toMap());
    print('Inserted category with ID: $result');
    return result;
  } catch (e) {
    print('Error inserting category: $e');
    return -1; // Retorna un valor negativo en caso de error
  } finally {
    await database.close(); // Cierra la base de datos en cualquier caso
  }
}
  static Future<List<Categories>> getAllCategories() async {
    Database database = await _openDB();
    try {
      List<Map<String, dynamic>> categoryMaps =
          await database.query("categorias");
      return categoryMaps
          .map((categoryMap) => Categories.fromMap(categoryMap))
          .toList();
    } finally {
      await database.close();
    }
  }

  static Future<void> deleteAllCategories() async {
  Database database = await _openDB();
  try {
    await database.delete('categorias'); // Elimina todos los registros de la tabla
  } finally {
    await database.close();
  }
}

  static Future<void> deleteCategory(int id) async {
    Database database = await _openDB();
    try {
      await database.delete('categorias', where: 'id = ?', whereArgs: [id]);
    } finally {
      await database.close();
    }
  }

static Future<List<Categories>> reloadAllCategories() async {
  try {
    print('Reloading data...');
    List<Categories> loadedCategories = await getAllCategories();
    print('Categories reloaded: $loadedCategories');
    _categoriesController.add(loadedCategories);  // Añade esta línea para emitir eventos
    return loadedCategories;
  } catch (e) {
    print('Error reloading data: $e');
    throw e;
  }
}


}
