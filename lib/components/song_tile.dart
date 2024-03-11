import 'package:flutter/material.dart';
import 'package:music/components/popup_button.dart';
import 'package:music/models/song.dart';
import 'package:music/util/config.dart';
import 'package:music/providers/mark_songs.dart';
import 'package:music/providers/song_controller.dart';
//import 'package:music/screens/now_playing.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class SongTile extends StatelessWidget {
  SongTile({
    required this.songList,
    required this.allSongs,
    required this.playListName,
    required this.canDelete,
    required this.index,
    required this.resetSearch,
    required this.buildShowDialog,
  });

  final List<Song> songList;
  final List<Song> allSongs;
  final String playListName;
  final bool canDelete;
  final int index;
  final Function resetSearch;
  final Function buildShowDialog;
  @override
  Widget build(BuildContext context) {
    double padding = 10.0;
    return Consumer<SongController>(
      builder: (context, controller, child) {
        return AnimatedPadding(
          duration: Duration(milliseconds: 250),
          padding: controller.nowPlaying?.path == songList[index].path &&
                  controller.isPlaying
              ? EdgeInsets.symmetric(vertical: padding)
              : EdgeInsets.all(0),
          child: Consumer<MarkSongs>(
            builder: (context, marker, child) {
              return ListTile(
                selected: controller.nowPlaying?.path == songList[index].path,
                onTap: () async {
                  if (marker.isReadyToMark) {
                    marker.isMarked(songList[index])
                        ? marker.remove(songList[index])
                        : marker.add(songList[index]);
                  } else {
                    controller.allSongs = allSongs.cast<String>();
                    controller.playlistName = playListName;
                    //await Navigator.push(
                    //  context,
                    //  MaterialPageRoute(
                    //    builder: (context) =>
                    //        NowPlaying(currentSong: songList[index]),
                    //  ),
                    //);
                    resetSearch();
                    controller.isPlaying ? padding = 10.0 : padding = 0.0;
                  }
                },
                onLongPress: () {
                  marker.isReadyToMark = true;
                  marker.add(songList[index]);
                },
                contentPadding: EdgeInsets.only(right: 20),
                leading: marker.isReadyToMark
                    ? Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: marker.isMarked(songList[index]),
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            newValue
                                ? marker.add(songList[index])
                                : marker.remove(songList[index]);
                          }
                        },
                      )
                    : PopUpButton(
                        song: songList[index],
                        canDelete: canDelete,
                        dialogFunction: buildShowDialog,
                      ),
                title: Text(
                  songList[index].title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Config.textSize(context, 3.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  songList[index].artist,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Config.textSize(context, 3),
                  ),
                ),
                trailing: CustomButton(
                  child: controller.nowPlaying?.path == songList[index].path &&
                          controller.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  diameter: 12,
                  isToggled:
                      controller.nowPlaying?.path == songList[index].path,
                  onPressed: () async {
                    controller.allSongs = allSongs.cast<String>();
                    controller.playlistName = playListName;
                    await controller.playlistControlOptions(songList[index]);
                    controller.isPlaying ? padding = 10.0 : padding = 0.0;
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
