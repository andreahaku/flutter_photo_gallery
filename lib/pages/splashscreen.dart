import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_gallery/models/main_model.dart';
import 'package:photo_gallery/utils/sqlite.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:photo_gallery/models/photo_model.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<Timer> _loadData() async {
    // loads all values persisted in 'shared_preferences'
    await ScopedModel.of<MainModel>(context).loadAllUserValues();

    await _loadAllImages();
    //moves to the home page automatically
    return Timer(const Duration(seconds: 60), _onDoneLoading);
  }

  void _onDoneLoading() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _loadAllImages() async {
    // asks for permissions and returns a boolean
    final bool result = await PhotoManager.requestPermission();

    if (result) {
      // success - user gave us authorisation

      // we fetch the list of all the asset paths
      final List<AssetPathEntity> assetPathList =
          await PhotoManager.getAssetPathList(isCache: false, hasVideo: false);

      // for each asset path we fetch the list of all the images and we add to the global list
      for (int i = 0; i < assetPathList.length; i++) {
        List<AssetEntity> newImageList = <AssetEntity>[];
        final String name = assetPathList[i].name.toLowerCase();
        print(name);
        // we skip the whole process if the "recent" path
        if (name != 'recent') {
          // gets the list of all the images for the asset path
          final DateTime now = DateTime.now();
          newImageList = await assetPathList[i].assetList;
          // adds every image to the global list
          if (newImageList.isNotEmpty && name != 'recent') {
            await _storeAllImages(name, newImageList);
          }
          print(
              '$name: ${newImageList.length.toString()} photos loaded in ${(DateTime.now().difference(now)).toString()}');
        }
      }
    }
  }

// stores all the images in the local db
  Future<void> _storeAllImages(
    String directory,
    List<AssetEntity> imageList,
  ) async {
    List<Photo> photoList = [];

    for (int i = 0; i < imageList.length; i++) {
      final AssetEntity photo = imageList[i];

      final File file = await photo.file;
      final String path = file.toString().split(' ')[1].replaceAll("'", '');
      final Size size = await photo.size;
      final double width = size.width;
      final double height = size.height;

      photoList.add(Photo(
        directory,
        directory,
        path,
        height,
        width,
      ));
    }
    await DbHelper().batchCreatePhoto(photoList);
    print('DONE IMPORTING imaages on: ${directory}');

    List<Photo> list = await DbHelper().readAllPhotos();
    for (int i = 0; i < list.length; i++) {
      Photo photo = list[i];
      print(photo.path);
    }
  }

  void createData(Photo photo) {
    final DbHelper dbHelper = DbHelper();
    dbHelper.createPhoto(photo);
  }

  void batchCreateData(Photo photo) {
    final DbHelper dbHelper = DbHelper();
    dbHelper.createPhoto(photo);
  }

  void updateData(Photo photo) {
    final DbHelper dbHelper = DbHelper();
    dbHelper.updatePhoto(photo);
  }

  void deleteData(String path) {
    final DbHelper dbHelper = DbHelper();
    dbHelper.deletePhoto(path);
  }

  Future<Photo> readData(String path) async {
    final DbHelper dbHelper = DbHelper();
    return await dbHelper.readPhoto(path);
  }

  Future<List<Photo>> readAllData() async {
    final DbHelper dbHelper = DbHelper();
    return await dbHelper.readAllPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'), fit: BoxFit.cover),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Shimmer.fromColors(
          baseColor: Colors.white30,
          highlightColor: Colors.white,
          period: const Duration(milliseconds: 2400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Photo Gallery',
                style: TextStyle(
                    fontSize: 42.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
                textScaleFactor: 1.0,
              ),
              Text(
                'version 1.0.0',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w100,
                    color: Colors.white),
                textScaleFactor: 1.0,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
