import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _tableName = 'posts';
  static const String _dbName = 'offline_posts.db';

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    final db = await openDatabase(
      path,
      version: 2, // bumped — forces onUpgrade on devices with stale schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
    return db;
  }

  /// Always verify columns are correct whenever the DB is opened
  Future<void> _onOpen(Database db) async {
    await _recreateIfSchemaMismatch(db);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTable(db);
  }

  /// Drop and recreate on version bump — wipes any stale schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $_tableName');
    await _createTable(db);
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL,
        timestamp   TEXT
      )
    ''');
  }

  /// Extra safety: inspect actual columns via PRAGMA and recreate if wrong
  Future<void> _recreateIfSchemaMismatch(Database db) async {
    try {
      final tableInfo = await db.rawQuery('PRAGMA table_info($_tableName)');
      final columns = tableInfo.map((row) => row['name'] as String).toSet();
      const required = {'id', 'title', 'description', 'timestamp'};
      if (!columns.containsAll(required)) {
        await db.execute('DROP TABLE IF EXISTS $_tableName');
        await _createTable(db);
      }
    } catch (_) {
      // Table doesn't exist at all — just create it
      await _createTable(db);
    }
  }

  /// Insert: never pass id — let SQLite AUTOINCREMENT handle it
  Future<int> insertPost(Post post) async {
    final db = await database;
    final map = <String, dynamic>{
      'title': post.title,
      'description': post.description,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await db.insert(
      _tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'id DESC');
    return maps.map((map) => Post.fromMap(map)).toList();
  }

  Future<Post?> getPostById(int id) async {
    final db = await database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Post.fromMap(maps.first);
  }

  Future<int> updatePost(Post post) async {
    final db = await database;
    final map = <String, dynamic>{
      'title': post.title,
      'description': post.description,
      'timestamp':
          post.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    return await db.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDb() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
