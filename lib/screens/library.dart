import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:music/components/create_playlist.dart';
import 'package:music/components/custom_button.dart';
import 'package:music/components/custom_card.dart';
import 'package:music/components/library_bottom_sheet.dart';
import 'package:music/providers/all_songs.dart';
import 'package:music/providers/playList_database.dart';
import 'package:music/providers/song_controller.dart';
import 'package:music/screens/playList.dart';
import 'package:provider/provider.dart';
import '../components/library_song_control.dart';
import '../util/config.dart';

class Library extends StatefulWidget {
  static const String pageId = '/library';
  const Library({super.key});
  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with WidgetsBindingObserver {
  late SongController _controller;
  void openPlaylist({String? title}) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlayList(playListName: title)));
  }

  IconData getPlaylistIcon(index) {
    switch (index) {
      case 0:
        return Icons.add;
        break;
      case 1:
        return Icons.favorite_border;
        break;

      default:
        return Icons.star_border;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void showNotification() {
    _controller = Provider.of<SongController>(context, listen: false);
    if (_controller.nowPlaying.path != null) {
      print("Here add the notification code");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller = Provider.of<SongController>(context, listen: false);
    _controller.state = state;
    // if app comes to the foregroung hide notification
    if (state == AppLifecycleState.resumed) {
      // MediaNotification.hideNotification();
    }
    //if app goes to background show notification
    if (state == AppLifecycleState.paused &&
        _controller.nowPlaying?.path != null) {
      print("Here add controller code");
      // MediaNotification.setListener('play', () => _controller.play());
      // MediaNotification.setListener('pause', () => _controller.pause());
      // MediaNotification.setListener('next', () async {
      //   await _controller.skip(next: true);
      //   showNotification();
      // });
      // MediaNotification.setListener('prev', () async {
      //   await _controller.skip(prev: true);
      //   showNotification();
      // });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(bottom: 80),
                child: ListView(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 30,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Library',
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 5),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            Spacer(),
                            CustomButton(
                              diameter: 12,
                              onPressed: () {
                                // Navigator.pushNamed(context, Identify.pageId);
                              },
                              child: Icons.keyboard_voice_rounded,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            CustomButton(
                                diameter: 12,
                                onPressed: () {
                                  //Navigator.pushNamed(
                                  //context, Settings.pageId);
                                },
                                child: Icons.settings),
                          ],
                        )),
                    Divider(
                      height: 0.0,
                      thickness: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    SizedBox(
                      height: Config.yMargin(context, 3),
                    ),
                    Consumer<ProviderClass>(
                        builder: (context, provider, child) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                              onTap: () {
                                //openPlaylist(title: 'All songs');
                              },
                              child: CustomCard(
                                width: double.infinity,
                                height: 30,
                                label: 'All Songs',
                                numOfSongs: provider.allSongs.length ?? 0,
                                child: Icons.all_inclusive,
                              )));
                    }),
                    SizedBox(
                      height: Config.yMargin(context, 3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Playlist',
                        style: TextStyle(
                          fontSize: Config.textSize(context, 5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Consumer<PlayListDB>(
                      builder: (_, playListDB, child) {
                        return Container(
                          height: Config.yMargin(context, 30),
                          color: Colors.transparent,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: playListDB.playList.length,
                              itemBuilder: (_, index) {
                                int songCount = index > 0
                                    ? playListDB
                                            .playList[index]['songs']?.length ??
                                        0
                                    : 0;
                                return GestureDetector(
                                    onTap: () {
                                      if (playListDB.playList[index]['name'] ==
                                          'Create playlist') {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CreatePlayList(
                                                createNewPlaylist: true,
                                                //songs: [],
                                              );
                                            });
                                      } else {
                                        openPlaylist(
                                            title: playListDB.playList[index]
                                                ['name']);
                                      }
                                    },
                                    onLongPress: () {
                                      if (index > 1) {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              LibraryBottomSheet(playListDB
                                                  .playList[index]['name']),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CustomCard(
                                        height: 30,
                                        width: 30,
                                        label: playListDB.playList[index]
                                            ['name'],
                                        child: getPlaylistIcon(index),
                                        numOfSongs: songCount,
                                      ),
                                    ));
                              }),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: Config.textSize(context, 5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Consumer<PlayListDB>(
                      builder: (context, playlistDB, child) {
                        return Container(
                          height: Config.yMargin(context, 30),
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  openPlaylist(
                                      title: index == 0
                                          ? 'Recently added'
                                          : 'Recently played');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CustomCard(
                                    height: 30,
                                    width: 30,
                                    label: index == 0
                                        ? 'Recently added'
                                        : 'Recently played',
                                    //numOfSongs: ,
                                    child: index == 0
                                        ? Icons.playlist_add
                                        : Icons.playlist_play,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              LibrarySongControl(),
            ],
          ),
        ),
      ),
    );
  }
}
