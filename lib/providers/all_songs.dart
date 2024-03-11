import 'dart:io';
import 'package:path/path.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:music/models/song.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:path_provider/path_provider.dart';
import 'package:music/providers/playList_database.dart';

class ProviderClass extends ChangeNotifier {
  ProviderClass({ this.themeData}) {
    allSongs = [];
    recentlyAdded = [];
    init();
  }

  ThemeData ? themeData;
  late List<Song> allSongs;
  List<Song> recentlyAdded;

  ThemeData get theme => themeData;

  setTheme(ThemeData data) {
    themeData = data;
    notifyListeners();
  }

  void init() async {
    await getAllSongs();
    sortList();
  }

  Future<void> editSongInfo(BuildContext context, Song newSong,
      {required String imagePath}) async {
    final tagger = Audiotagger();
    final playlistDB = PlayListDB();
    final path = newSong.path;
    final tag = Tag(
      title: newSong.title,
      artist: newSong.artist,
      album: newSong.album,
      genre: newSong.genre,
      year: newSong.year,
      artwork: imagePath,
    );

    bool? successful = await tagger.writeTags(
      path: path,
      tag: tag,
    );
    Song editedSong = await songInfo(path);
    int index = allSongs.indexWhere((song) => song.path == newSong.path);
    allSongs.replaceRange(index, index + 1, [editedSong]);
    index = recentlyAdded.indexWhere((song) => song.path == newSong.path);
    recentlyAdded.replaceRange(index, index + 1, [editedSong]);
    await playlistDB.replaceSong(newSong);
    successful
        ? playlistDB.showToast('Edited successfully', context)
        : playlistDB.showToast('Something went wrong', context,
            isSuccess: false);

    notifyListeners();
  }

  void sortList() {
    List<Song> newList = List.from(allSongs);
    newList.sort((b, a) {
      if (a.dateAdded == null || b.dateAdded == null) return -1;
      return a.dateAdded!.compareTo(b.dateAdded!);
    });

    recentlyAdded.addAll(newList);
    allSongs
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    notifyListeners();
  }

  void removeSong(Song song) {
    allSongs.removeWhere((element) => element.path == song.path);
    recentlyAdded.removeWhere((element) => element.path == song.path);
    notifyListeners();
  }

  Future<void> getAllSongs() async {
    PermissionStatus permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted && Platform.isAndroid) {
      List<Directory>? deviceStorages = await getExternalStorageDirectories();
      List<Directory> pathToStorage = [];

      for (var dir in deviceStorages!) {
        pathToStorage.add(Directory(dir.path.split("Android")[0]));
      }
      List<FileSystemEntity> allFolders = await getAllFolders(pathToStorage);

      await searchFolders(allFolders);
    } else {
      permissionStatus = await Permission.storage.request();
    }
    notifyListeners();
  }

  Future<List<FileSystemEntity>> getAllFolders(List paths) async {
    List<FileSystemEntity> allFolders = [];
    for (var dir in paths) {
      allFolders.addAll([...dir.listSync()]);
    }
    return allFolders;
  }

  Future<void> searchFolders(List folders) async {
    for (FileSystemEntity eachFile in folders) {
      if (FileSystemEntity.isFileSync(eachFile.path) &&
          basename(eachFile.path).endsWith('.mp3')) {
        allSongs.add(await songInfo(eachFile.path));
        notifyListeners();
      } else if (FileSystemEntity.isDirectorySync(eachFile.path)) {
        await getAllFiles(eachFile.path);
      }
    }
  }

  Future<void> getAllFiles(String path) async {
    for (FileSystemEntity file in Directory(path).listSync()) {
      if (FileSystemEntity.isFileSync(file.path) &&
          basename(file.path).endsWith('.mp3')) {
        allSongs.add(await songInfo(file.path));
        notifyListeners();
      } else if (FileSystemEntity.isDirectorySync(file.path) &&
          !basename(file.path).startsWith('.') &&
          !file.path.contains('/Android')) {
        await getAllFiles(file.path);
      } else {
        print('No mp3 found');
      }
    }
  }

  Future<Song> songInfo(String file) async {
    var audioTagger = Audiotagger();
    var info;
    try {
      info = await audioTagger.readTagsAsMap(
        path: file,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return Song.fromMap(info, filePath: file);
  }
}
