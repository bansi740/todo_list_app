import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_list_model.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._init();
  static Database? _database;

  TodoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        reminderAt TEXT,
        isDeleted INTEGER DEFAULT 0,
        isPinned INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  Future onUpgrade(Database db, int oldVersion, int newVersion) async {
    final columns = await db.rawQuery("PRAGMA table_info(todos)");
    final columnNames = columns.map((c) => c['name'] as String).toList();

    if (oldVersion < 3 && !columnNames.contains('createdAt')) {
      await db.execute("ALTER TABLE todos ADD COLUMN createdAt TEXT");
      await db.execute(
        "UPDATE todos SET createdAt = datetime('now') WHERE createdAt IS NULL OR createdAt = ''",
      );
    }

    if (oldVersion < 4 && !columnNames.contains('reminderAt')) {
      await db.execute("ALTER TABLE todos ADD COLUMN reminderAt TEXT");
    }

    if (oldVersion < 5 && !columnNames.contains('isPinned')) {
      await db.execute(
        "ALTER TABLE todos ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0",
      );
    }

    if (oldVersion < 6 && !columnNames.contains('isSynced')) {
      await db.execute(
        "ALTER TABLE todos ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0",
      );
    }
  }

  Future<int> createTodo(Todo todo) async {
    final db = await instance.database;
    return await db.insert('todos', todo.toJson());
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return result.map((json) => Todo.fromJson(json)).toList();
  }

  Future<Todo?> getTodoById(String id) async {
    final db = await instance.database;
    final result = await db.query('todos', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Todo.fromJson(result.first);
    return null;
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await instance.database;
    return await db.update(
      'todos',
      todo.toJson(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(String id) async {
    final db = await instance.database;
    return await db.update(
      'todos',
      {'isDeleted': 1, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreTodo(String id) async {
    final db = await instance.database;
    return await db.update(
      'todos',
      {'isDeleted': 0, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> togglePin(String id, bool pin) async {
    final db = await instance.database;
    return await db.update(
      'todos',
      {'isPinned': pin ? 1 : 0, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> permanentDelete(String id) async {
    final db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Todo>> getDeletedTodos() async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'isDeleted = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    return result.map((json) => Todo.fromJson(json)).toList();
  }
}
