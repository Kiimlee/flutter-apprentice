import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';
import '../models/models.dart';

class DatabaseHelper {
  // 1
  static const _databaseName = 'MyRecipes.db';
  static const _databaseVersion = 1;

// 2
  static const recipeTable = 'Recipe';
  static const ingredientTable = 'Ingredient';
  static const recipeId = 'recipeId';
  static const ingredientId = 'ingredientId';

// 3
  static late BriteDatabase _streamDatabase;

// make this a singleton class
// 4
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
// 5
  static var lock = Lock();

// only have a single app-wide reference to the database
// 6
  static Database? _database;

// SQL code to create the database table
// 1
  Future _onCreate(Database db, int version) async {
    // 2
    await db.execute('''
        CREATE TABLE $recipeTable (
          $recipeId INTEGER PRIMARY KEY,
          label TEXT,
          image TEXT,
          url TEXT,
          calories REAL,
          totalWeight REAL,
          totalTime REAL
        )
        ''');
    // 3
    await db.execute('''
        CREATE TABLE $ingredientTable (
          $ingredientId INTEGER PRIMARY KEY,
          $recipeId INTEGER,
          name TEXT,
          weight REAL
        )
        ''');
  }

// this opens the database (and creates it if it doesn't exist)
// 1
  Future<Database> _initDatabase() async {
    // 2
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // 3
    final path = join(documentsDirectory.path, _databaseName);

    // 4
    // TODO: Remember to turn off debugging before deploying app to store(s).
    Sqflite.setDebugModeOn(true);

    // 5
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

// 1
  Future<Database> get database async {
    // 2
    if (_database != null) return _database!;
    // Use this object to prevent concurrent access to data
    // 3
    await lock.synchronized(() async {
      // lazily instantiate the db the first time it is accessed
      // 4
      if (_database == null) {
        // 5
        _database = await _initDatabase();
        // 6
        _streamDatabase = BriteDatabase(_database!);
      }
    });
    return _database!;
  }

// 1
  Future<BriteDatabase> get streamDatabase async {
    // 2
    await database;
    return _streamDatabase;
  }

// TODO: Add parseRecipes here

}
