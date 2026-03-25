import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseService {
  static const String tableName = 'posts';
  static const String dbName = 'postsmanager.db';
  static Database? _database;

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final String path = join(await getDatabasesPath(), dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  // Create a post
  Future<int> createPost(Post post) async {
    try {
      final db = await database;
      final id = await db.insert(
        tableName,
        {
          ...post.toMap(),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  // Read all posts
  Future<List<Post>> getAllPosts() async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        orderBy: 'updatedAt DESC',
      );
      return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  // Read a single post by id
  Future<Post?> getPostById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Post.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }

  // Update a post
  Future<int> updatePost(Post post) async {
    try {
      final db = await database;
      return await db.update(
        tableName,
        {
          ...post.toMap(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }

  // Delete a post
  Future<int> deletePost(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  // Delete all posts
  Future<int> deleteAllPosts() async {
    try {
      final db = await database;
      return await db.delete(tableName);
    } catch (e) {
      throw Exception('Error deleting all posts: $e');
    }
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
