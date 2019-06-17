import 'dart:math' show pi;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:photo_gallery/models/photo_model.dart';
import 'package:photo_gallery/utils/sqlite.dart';

class LocalPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocalPhotos();
  }
}

class _LocalPhotos extends State<LocalPhotos> {
  final int numberOfImagesPerRow = 3;

  int tabControllerLength;
  List<Widget> tabBarLabels = [];
  List<Widget> tabBarContents = [];

  void createData(Photo photo) {
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
  void initState() {
    super.initState();

    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
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
        // we skip the whole process if the "recent" path
        if (name != 'recent') {
          // gets the list of all the images for the asset path
          final DateTime now = DateTime.now();
          newImageList = await assetPathList[i].assetList;

          print(
              '$name: ${newImageList.length.toString()} photos loaded in ${(DateTime.now().difference(now)).toString()}');

          // adds every image to the global list
          if (newImageList.isNotEmpty && name != 'recent') {
            // adds the list to the sqlite database
            // await insertList(name, newImageList.toString());
            // dynamic sqliteList = await readList(name);

            tabBarLabels.add(Tab(text: assetPathList[i].name));
            tabBarContents.add(GridView.builder(
              // gridview
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: numberOfImagesPerRow,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(context, index, newImageList);
              },
              itemCount: newImageList.length,
            ));
          }
        }
      }
      // updates the state to update the screen
      //print('TOTAL: ${imageList.length}');

      tabControllerLength = tabBarLabels.length;

      // print('tabControllerLength: $tabControllerLength');
      // print('tabBarLabels: ${tabBarLabels.length}');
      // print('tabBarContents: ${tabBarContents.length}');

      setState(() {});
    } else {
      // fail - user didn'g gave us authorisation
      // we open settings to give it manually
      PhotoManager.openSetting();
    }
  }

  // creates the single tile with the image
  Widget _buildItem(
      BuildContext context, int index, List<AssetEntity> currentImageList) {
    final AssetEntity entity = currentImageList[index]; // image entity

    final int size = MediaQuery.of(context).size.width ~/
        numberOfImagesPerRow; // gets the width of the display and divides it by the number of images per row

    return FutureBuilder<dynamic>(
      future: entity.thumbDataWithSize(size, size), // gets the image
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return InkWell(
            onTap: () => print(entity),
            child: Stack(
              alignment: const Alignment(1.0, -1.0),
              overflow: Overflow.clip,
              children: <Widget>[
                Image.memory(
                  snapshot.data,
                  fit: BoxFit.cover,
                  width: size.toDouble(),
                  height: size.toDouble(),
                ),
                Positioned(
                  top: -50.0,
                  right: -50.0,
                  child: Transform.rotate(
                    angle: pi / 4.0,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      width: 100,
                      height: 100,
                      padding: EdgeInsets.only(bottom: 5.0),
                      color: Colors.red,
                      child: Text(
                        'Low\nquality',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return Center(
          child: const Text('loading...'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return tabControllerLength == null
        ? Container()
        : DefaultTabController(
            length: tabControllerLength,
            initialIndex: 0,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Theme.of(context).accentColor,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: tabBarLabels,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: tabBarContents,
                  ),
                ),
              ],
            ),
          );

    // return GridView.builder(
    //       // gridview
    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: numberOfImagesPerRow,
    //         childAspectRatio: 1.0,
    //       ),
    //       itemBuilder: _buildItem,
    //       itemCount: imageList.length,
    //     );
  }
}
