import 'dart:typed_data';

class Photo {
  String library;
  String directory;
  String path;
  double height;
  double width;

  Photo(this.library, this.directory, this.path, this.height, this.width);

  Photo.fromMap(Map<dynamic, dynamic> map) {
    library = map['library'];
    directory = map['directory'];
    path = map['path'];
    height = map['height'];
    width = map['width'];
  }
}
