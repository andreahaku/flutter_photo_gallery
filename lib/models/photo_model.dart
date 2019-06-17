import 'dart:typed_data';

class Photo {
  Photo(this.directory, this.path, this.height, this.width, this.thumbnail);

  Photo.fromMap(Map<dynamic, dynamic> map) {
    directory = map['directory'];
    path = map['path'];
    height = map['height'];
    width = map['width'];
    thumbnail = map['thumbnail'];
  }

  String directory;
  String path;
  double height;
  double width;
  Uint8List thumbnail;
}
