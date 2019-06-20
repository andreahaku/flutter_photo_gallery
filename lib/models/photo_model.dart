import 'dart:typed_data';

class Photo {
  String library;
  String directory;
  String path;
  double height;
  double width;
  Uint8List thumbnail;

  Photo(this.library, this.directory, this.path, this.height, this.width,
      this.thumbnail);

  Photo.fromMap(Map<dynamic, dynamic> map) {
    library = map['library'];
    directory = map['directory'];
    path = map['path'];
    height = map['height'];
    width = map['width'];
    thumbnail = map['thumbnail'];
  }
}
