//😀😉😙😐🤐😜🤑😢

import "dart:convert";

import "package:flutter/material.dart";
import "package:music/models/exception.dart";
import "package:music/services/lyrics.dart";
import "package:music/services/secrets.dart";

import "../components/identified_songinfo.dart";
import "../models/song.dart";
import "playList_database.dart";
import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentifyController extends ChangeNotifier {
  late AnimationController controller;
  late BuildContext context;
  bool isSearching = false;
  bool isSearchingLyrics = false;
  List<String> lyrics = [];
  List<String> identifiedHistory = [];
  AcrCloudSdk arc = AcrCloudSdk();
  final playlistDB = PlayListDB();

  void init() async {
    arc
      ..init(
          host: kHost,
          accessKey: kAccessKey,
          accessSecret: kAccessSecret,
          setLog: true)
      ..songModelStream.listen(searchSong);
  }

  Future<void> startSearch() async {
    lyrics = [];
    isSearching = true;
    notifyListeners();
    controller.repeat(period: const Duration(seconds: 1));
    await arc.start();
  }

  Future<void> stopSearch() async {
    isSearching = false;
    notifyListeners();
    controller.stop();
    await arc.stop();
  }

  void searchSong(SongModel song) async {
    var data = song.metadata;
    if (data != null && data.music!.isNotEmpty) {
      await stopSearch();
      final firstItem = data.music![0];
      final identifiedSong = Song(
        title: firstItem.title ?? 'Unknown Title',
        artist: firstItem.artists!.first.name ?? 'Unknown Artist',
        album: firstItem.album?.name ?? 'Unknown Album',
        year: firstItem.releaseDate ?? 'Unknown Year',
        path: '',
      );

      await _saveIdentifiedSong(identifiedSong);
      await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => IdentifiedSong(identifiedSong as String),
      );
    } else {
      playlistDB.showToast('Song not found', context, isSuccess: false);
    }
    stopSearch();
  }

  Future<void> _saveIdentifiedSong(Song song) async {
    await SharedPreferences.getInstance().then((pref) {
      final history = pref.getStringList('history') ?? [];
      history.add(json.encode(song.toMap()));
      pref.setStringList('history', history);
    });
  }

  Future<void> loadIdentifiedSong() async {
    await SharedPreferences.getInstance().then((pref) {
      final history = pref.getStringList('history') ?? [];
      identifiedHistory = history
          .map((e) => Song.fromMap(json.decode(e), filePath: ''))
          .cast<String>()
          .toList();
      notifyListeners();
    });
  }

  Future<void> removeHistoryItem(int index) async {
    await SharedPreferences.getInstance().then((pref) {
      final history = pref.getStringList('history') ?? [];
      history.removeAt(index);
      pref.setStringList('history', history);
    });
    await loadIdentifiedSong();
  }

  Future<void> clearHistory() async {
    await SharedPreferences.getInstance().then((pref) {
      pref.setStringList('history', []);
    });
    await loadIdentifiedSong();
  }

  Future<void> searchLyrics(String artist, String title) async {
    try {
      isSearchingLyrics = true;
      notifyListeners();
      lyrics = await Lyrics.getLyrics(artist, title).timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            throw CustomException('Taking too long ,try again later'),
      );
    } on CustomException catch (error) {
      playlistDB.showToast(error.message, context, isSuccess: false);
    } catch (error) {
      print(error);
    } finally {
      isSearchingLyrics = false;
      notifyListeners();
    }
  }

  void reset() {
    lyrics = [];
  }
}
