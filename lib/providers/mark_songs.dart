import "package:flutter/material.dart";

import "../models/song.dart";

class MarkSongs extends ChangeNotifier {
  List<Song> markedSongs = [];
  bool isReadyToMark = false;

  void marking() {
    markedSongs.length > 0 ? isReadyToMark = true : isReadyToMark = false;
    notifyListeners();
  }

  void add(Song song) {
    markedSongs.add(song);
    notifyListeners();
  }

  void remove(Song song) {
    markedSongs.removeWhere((element) => element.path == song.path);
    notifyListeners();
  }

  void reset({bool notify = false}) {
    isReadyToMark = false;
    markedSongs.clear();
    if (notify) {
      notifyListeners();
    }
  }

  bool isMarked(Song song) {
    return markedSongs.any((element) => element.path == song.path);
  }
}
