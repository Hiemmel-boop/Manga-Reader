import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/manga.dart';
import '../models/reading_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'manga_reader.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mangas (
        mangadexId TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        coverUrl TEXT,
        author TEXT,
        artist TEXT,
        status TEXT,
        contentRating TEXT,
        tags TEXT,
        year INTEGER,
        isInLibrary INTEGER DEFAULT 0,
        addedToLibraryAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_history (
        mangaId TEXT,
        chapterId TEXT PRIMARY KEY,
        mangaTitle TEXT,
        mangaCoverUrl TEXT,
        chapterTitle TEXT,
        chapterNumber TEXT,
        lastPage INTEGER,
        readAt TEXT,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  // ─── MANGAS ───────────────────────────────────────────────

  Future<void> insertManga(Manga manga) async {
    final db = await database;
    await db.insert('mangas', manga.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Manga>> getFavoriteMangas() async {
    final db = await database;
    final maps = await db.query('mangas', where: 'isInLibrary = ?', whereArgs: [1], orderBy: 'addedToLibraryAt DESC');
    return maps.map((map) => Manga.fromJson(map)).toList();
  }

  Future<Manga?> getMangaByMangadexId(String mangadexId) async {
    final db = await database;
    final maps = await db.query('mangas', where: 'mangadexId = ?', whereArgs: [mangadexId]);
    if (maps.isNotEmpty) return Manga.fromJson(maps.first);
    return null;
  }

  Future<void> updateManga(Manga manga) async {
    final db = await database;
    await db.update('mangas', manga.toJson(), where: 'mangadexId = ?', whereArgs: [manga.mangadexId]);
  }

  // ─── HISTORY ──────────────────────────────────────────────

  Future<void> insertHistory(ReadingHistory history) async {
    final db = await database;
    await db.insert('reading_history', history.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ReadingHistory>> getRecentHistory({int limit = 50}) async {
    final db = await database;
    final maps = await db.query('reading_history', orderBy: 'readAt DESC', limit: limit);
    return maps.map((map) => ReadingHistory.fromJson(map)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('reading_history');
  }

  // ─── NETTOYAGE (NOUVEAU) ──────────────────────────────────

  Future<void> clearAllData() async {
    final db = await database;
    // On vide la table des mangas et de l'historique
    await db.delete('mangas');
    await db.delete('reading_history');
  }
}