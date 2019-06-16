import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gallery Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Gallery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // global list with all the images
  List<AssetEntity> imageList = <AssetEntity>[];
  final int numberOfImagesPerRow = 3;

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
          await PhotoManager.getAssetPathList(isCache: false);

      print('assetPathList');
      print(assetPathList);

      // this is an alternative way to look for assets paths
      // final List<AssetPathEntity> imageAsset =
      //     await PhotoManager.getImageAsset();
      // print('imageAsset');
      // print(imageAsset);

      // for each asset path we fetch the list of all the images and we add to the global list
      for (int i = 0; i < assetPathList.length; i++) {
        // gets the list of all the images for the asset path
        final List<AssetEntity> newImageList = await assetPathList[i].assetList;

        print(newImageList);

        // adds every image to the global list
        for (int ii = 0; ii < newImageList.length; ii++) {
          imageList.add(newImageList[ii]);
        }
      }
      // updates the state to update the screen
      print('TOTAL: ${imageList.length}');
      setState(() {});
    } else {
      // fail - user didn'g gave us authorisation
      // we open settings to give it manually
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: GridView.builder(
          // gridview
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numberOfImagesPerRow,
            childAspectRatio: 1.0,
          ),
          itemBuilder: _buildItem,
          itemCount: imageList.length,
        ));
  }

  // creates the single tile with the image
  Widget _buildItem(BuildContext context, int index) {
    final AssetEntity entity = imageList[index]; // image entity

    final int size = MediaQuery.of(context).size.width ~/
        numberOfImagesPerRow; // gets the width of the display and divides it by the number of images per row

    return FutureBuilder<dynamic>(
      future: entity.thumbDataWithSize(size, size), // gets the image
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return InkWell(
            onTap: () => print(entity),
            child: Image.memory(
              snapshot.data,
              fit: BoxFit.cover,
              width: size.toDouble(),
              height: size.toDouble(),
            ),
          );
        }
        return Center(
          child: const Text('loading...'),
        );
      },
    );
  }
}
