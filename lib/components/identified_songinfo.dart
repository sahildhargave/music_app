//🥰🤔😥😌😕😟🤯😵

import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import "../models/song.dart";
import "../providers/identify_controller.dart";
import "../util/config.dart";

class IdentifiedSong extends StatefulWidget {
  final Song ?song;
  IdentifiedSong(String history, { this.song});
  @override
  _IdentifiedSongState createState() => _IdentifiedSongState();
}

class _IdentifiedSongState extends State<IdentifiedSong> {
  bool _isOpen = false;
  late IdentifyController controller;

  @override
  void initState() {
    super.initState();
    super.initState();
    controller = Provider.of<IdentifyController>(context, listen: false);
  }

  @override
  void deactivate() {
    super.deactivate();
    controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    TextStyle grayText = TextStyle(
      fontSize: Config.textSize(context, 3),
      color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.5),
    );
    return Consumer<IdentifyController>(builder: (context, controller, child) {
      return AnimatedContainer(
          duration: const Duration(microseconds: 200),
          height: Config.yMargin(context, _isOpen ? 50 : 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 40,
                  child: Divider(
                    thickness: 6,
                    height: 25,
                  )),
              Text(
                song!.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Config.textSize(context, 5),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'By ${song.artist}',
                textAlign: TextAlign.center,
                style: grayText,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  Text('Album -${song.album}'),
                  Text('Release date- ${song.year}'),
                ],
              ),
              if (_isOpen) ...[
                if (controller.lyrics.isEmpty) const Spacer(),
                controller.lyrics.isEmpty
                    ? Center(
                        child: Center(
                            child: TextButton(
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5)),
                              padding: MaterialStateProperty.all(EdgeInsets.all(
                                20,
                              ))),
                          child: controller.isSearchingLyrics
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                )
                              : Text(
                                  'Get lyrics',
                                  style: TextStyle(
                                    fontSize: Config.textSize(context, 4),
                                  ),
                                ),
                          onPressed: () async {
                            try {
                              await controller.searchLyrics(
                                  song.artist, song.title);
                            } catch (e) {
                              print(e);
                            }
                          },
                        )),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ListView.builder(
                            itemCount: controller.lyrics.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                controller.lyrics[index],
                                textAlign: TextAlign.center,
                                style: grayText,
                              ),
                            ),
                          ),
                        ),
                      ),
                if (controller.lyrics.isEmpty) const Spacer(),
              ],
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isOpen = !_isOpen;
                    });
                  },
                  icon: Icon(_isOpen
                      ? Icons.clear_rounded
                      : Icons.arrow_drop_down_circle_outlined))
            ],
          ));
    });
  }
}
