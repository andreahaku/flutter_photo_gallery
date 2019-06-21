import 'dart:async';

import 'package:path/path.dart';
import 'package:photo_gallery/models/photo_model.dart';
import 'package:sqflite/sqflite.dart';

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
        'CREATE TABLE photos (id INTEGER PRIMARY KEY, library TEXT, directory TEXT, path TEXT, height DOUBLE, width DOUBLE)');
  }

  // returns the db. if it doesn't exists it initialises one
  Future<Database> get db async {
    return _db ?? await initDb();
  }

  // adds a photo to the table
  Future<int> createPhoto(Photo photo) async {
    final Database dbReady = await db;

    return await dbReady.rawInsert(
      "INSERT INTO photos(library, directory, path, height, width, thumbnail) VALUES ('${photo.library}','${photo.directory}','${photo.path}','${photo.height}','${photo.width}'')",
    );
  }

  // adds a photo to the table
  Future<void> batchCreatePhoto(List<Photo> photos) async {
    final Database dbReady = await db;
    Batch batch = dbReady.batch();

    for (int i = 0; i < photos.length; i++) {
      Photo photo = photos[i];

      batch.insert('photos', {
        'library': photo.library,
        'directory': photo.directory,
        'path': photo.path,
        'height': photo.height,
        'width': photo.width,
      });
    }

    await batch.commit(noResult: true, continueOnError: true);
  }

  // updates a photo in the table based on the path of it
  Future<int> updatePhoto(Photo photo) async {
    final Database dbReady = await db;

    return await dbReady.rawInsert(
      "UPDATE photos SET library = '${photo.library}', directory = '${photo.directory}', path = '${photo.path}', height = '${photo.height}', width= '${photo.width}' WHERE path = '${photo.path}'",
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
        photo['library'],
        photo['directory'],
        photo['path'],
        photo['height'],
        photo['width'],
      ));
    }

    return allPhotos;
  }
}
