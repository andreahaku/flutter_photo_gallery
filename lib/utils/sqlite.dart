import 'dart:async';

import 'package:path/path.dart';
import 'package:photo_gallery/models/photo_model.dart';
import 'package:sqflite/sqflite.dart';

// Future<Database> openDB() async {
//   // Get a location using getDatabasesPath
//   final String databasesPath = await getDatabasesPath();
//   final String path = join(databasesPath, 'demo.db');

//   // Delete the database
//   await deleteDatabase(path);

//   // open the database
//   return await openDatabase(path, version: 1,
//       onCreate: (Database db, int version) async {
//     // When creating the db, create the table
//     await db.execute(
//         'CREATE TABLE photos (id INTEGER PRIMARY KEY, directory TEXT, list BLOB)');
//   });
// }

// Future<void> insertList(String directory, dynamic list) async {
//   // Get a reference to the database.
//   final Database db = await openDB();

//   final Map<String, dynamic> data = <String, dynamic>{
//     'directory': directory,
//     'list': list,
//   };

//   await db.insert(
//     'photos',
//     data,
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }

// Future<dynamic> readList(String diretory) async {
//   // Get a reference to the database.
//   final Database db = await openDB();

//   dynamic allPhoto = await db.rawQuery(
//       'SELECT * FROM photos WHERE directory = ?', <dynamic>[diretory]);

//   return allPhoto[0]['list'].split(',');
// }

class DbHelper {
  Database _db;

  // initialises the db
  Future<Database> initDb() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'database.db');

    final Database db =
        await openDatabase(path, version: 1, onCreate: onCreate);

    return db;
  }

  // creates the table
  void onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE photos (id INTEGER PRIMARY KEY, directory TEXT, path TEXT, height DOUBLE, width DOUBLE, thumbnail BLOB)');
  }

  // returns the db. if it doesn't exists it initialises one
  Future<Database> get db async {
    return _db ?? await initDb();
  }

  // adds a photo to the table
  Future<int> createPhoto(Photo photo) async {
    final Database dbReady = await db;

    return await dbReady.rawInsert(
      "INSERT INTO photos(directory, path, height, width, thumbnail) VALUES ('${photo.directory}','${photo.height}','${photo.width}','${photo.thumbnail}')",
    );
  }

  // updates a photo in the table based on the path of it
  Future<int> updatePhoto(Photo photo) async {
    final Database dbReady = await db;

    return await dbReady.rawInsert(
      "UPDATE photos SET directory = '${photo.directory}', path = '${photo.path}', height = '${photo.height}', width= '${photo.width}', thumbnail = '${photo.thumbnail}' WHERE path = '${photo.path}'",
    );
  }

  // deletes a photo in the table based on the path of it
  Future<int> deletePhoto(String path) async {
    final Database dbReady = await db;

    return await dbReady.rawInsert(
      "DELETE photos WHERE path = '$path'",
    );
  }

  // reads a single Photo using the path of it
  Future<Photo> readPhoto(String path) async {
    final Database dbReady = await db;

    final List<Map<String, dynamic>> photo =
        await dbReady.rawQuery('SELECT * FROM photos WHERE path = $path');

    return Photo.fromMap(photo[0]);
  }

  // reads all Photos using the path of it
  Future<List<Photo>> readAllPhotos() async {
    final Database dbReady = await db;

    final List<Map<String, dynamic>> list =
        await dbReady.rawQuery('SELECT * FROM photos');

    final List<Photo> allPhotos = List();

    for (int i = 0; i < list.length; i++) {
      final Map<String, dynamic> photo = list[i];

      allPhotos.add(Photo(
        photo['directory'],
        photo['path'],
        photo['height'],
        photo['width'],
        photo['thumbnail'],
      ));
    }

    return allPhotos;
  }
}
