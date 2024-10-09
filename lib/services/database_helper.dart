import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/book.dart';

class DatabaseHelper {
  static const String _databaseName = "MyLibrary.db";
  static const int _databaseVersion = 3;

  static const String table = 'books';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnAuthors = 'authors';
  static const String columnDescription = 'description';
  static const String columnThumbnailUrl = 'thumbnailUrl';
  static const String columnPageCount = 'pageCount';
  static const String columnPublisher = 'publisher';
  static const String columnPublishedDate = 'publishedDate';
  static const String columnCategories = 'categories';
  static const String columnLanguage = 'language';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnAuthors TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnThumbnailUrl TEXT NOT NULL,
        $columnPageCount INTEGER,
        $columnPublisher TEXT,
        $columnPublishedDate TEXT,
        $columnCategories TEXT,
        $columnLanguage TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      var tableInfo = await db.rawQuery('PRAGMA table_info($table)');
      var columnNames = tableInfo.map((col) => col['name'] as String).toList();

      if (!columnNames.contains(columnPageCount)) {
        await db
            .execute('ALTER TABLE $table ADD COLUMN $columnPageCount INTEGER');
      }
      if (!columnNames.contains(columnPublisher)) {
        await db.execute('ALTER TABLE $table ADD COLUMN $columnPublisher TEXT');
      }
      if (!columnNames.contains(columnPublishedDate)) {
        await db
            .execute('ALTER TABLE $table ADD COLUMN $columnPublishedDate TEXT');
      }
      if (!columnNames.contains(columnCategories)) {
        await db
            .execute('ALTER TABLE $table ADD COLUMN $columnCategories TEXT');
      }
      if (!columnNames.contains(columnLanguage)) {
        await db.execute('ALTER TABLE $table ADD COLUMN $columnLanguage TEXT');
      }
    }
  }

  Future<int> insert(Book book) async {
    Database db = await database;
    return await db.insert(table, {
      columnId: book.id,
      columnTitle: book.title,
      columnAuthors: jsonEncode(book.authors),
      columnDescription: book.description,
      columnThumbnailUrl: book.thumbnailUrl,
      columnPageCount: book.pageCount,
      columnPublisher: book.publisher,
      columnPublishedDate: book.publishedDate?.toIso8601String(),
      columnCategories: jsonEncode(book.categories),
      columnLanguage: book.language,
    });
  }

  Future<List<Book>> getAllBooks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i][columnId],
        title: maps[i][columnTitle],
        authors: List<String>.from(jsonDecode(maps[i][columnAuthors])),
        description: maps[i][columnDescription],
        thumbnailUrl: maps[i][columnThumbnailUrl],
        pageCount: maps[i][columnPageCount],
        publisher: maps[i][columnPublisher],
        publishedDate: maps[i][columnPublishedDate] != null
            ? DateTime.tryParse(maps[i][columnPublishedDate])
            : null,
        categories:
            List<String>.from(jsonDecode(maps[i][columnCategories] ?? '[]')),
        language: maps[i][columnLanguage],
      );
    });
  }

  Future<int> delete(String id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<bool> bookExists(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(table,
        columns: [columnId], where: '$columnId = ?', whereArgs: [id], limit: 1);
    return maps.isNotEmpty;
  }
}
