import 'dart:async';
import 'package:quran/Data/bookmark_data.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookmarkDatabase {
  static Database? _db;

  Future<Database?> get database async {
    if (_db == null) {
      _db = await init();
      return _db;
    }
    return _db;
  }

  init() async {
    String path = await getDatabasesPath();
    String file = join(path, 'quran_app.db');
    Database db = await openDatabase(file, onCreate: _onCreate, version: 1);

    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE bookmark(id INTEGER NOT NULL PRIMARY KEY, soraId INTEGER)',
    );

    if (kDebugMode) {
      print('CREATE DATABASE ✔');
    }
  }

  Future<void> insertData(BookmarkData bookmark) async {
    Database? db = await database;
    await db!.insert(
      'bookmark',
      {
        'id': bookmark.id,
        'soraId': bookmark.soraId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteData(BookmarkData bookmark) async {
    Database? db = await database;
    await db?.rawDelete(
      'DELETE FROM bookmark WHERE soraId = ?',
      [bookmark.soraId],
    );
  }

  Future<List<BookmarkData>> readData() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('bookmark');

    return List.generate(maps.length, (i) {
      return BookmarkData(
        id: maps[i]['id'],
        soraId: maps[i]['soraId'],
      );
    });
  }
}
