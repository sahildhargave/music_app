import 'dart:io';

class Song {
  late String path;
  late String title;
  late String artist;
  late String genre;
  late String album;
  late String year;
  late DateTime dateAdded;

  Song({
    required String path,
    required String title,
    required String artist,
    String? genre,
    String? album,
    String? year,
    DateTime? dateAdded,
  }) {
    this.path = path;
    this.title =
        title.isNotEmpty ? title : path.split('/').last.split('.mp3').first;
    this.artist = artist.isNotEmpty ? artist : 'Unknown artist';
    this.genre = genre ?? '';
    this.album = album ?? '';
    this.year = year ?? '';
    this.dateAdded = dateAdded ?? DateTime(2000);
  }

  Song.fromMap(Map<dynamic, dynamic> fileInfo, {required String filePath}) {
    var date;
    try {
      date = File(filePath).lastAccessedSync();
    } catch (e) {
      date = DateTime(2000);
      print(e);
    }
    path = filePath;
    title = fileInfo['title']?.toString() ??
        filePath.split('/').last.split('.mp3').first;
    artist = fileInfo['artist']?.toString() ?? 'Unknown artist';
    genre = fileInfo['genre']?.toString() ?? '';
    album = fileInfo['album']?.toString() ?? '';
    year = fileInfo['year']?.toString() ?? '';
    dateAdded = date;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'path': path,
      'title': title,
      'artist': artist,
      'genre': genre,
      'album': album,
      'year': year,
    };
  }
}
