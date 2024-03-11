import 'package:flutter/material.dart';
import 'package:music/providers/song_controller.dart';
import 'package:music/util/config.dart';
import 'package:provider/provider.dart';

class CircleDisc extends StatefulWidget {
  final double iconSize;

  CircleDisc({required this.iconSize});

  @override
  _CircleDiscState createState() => _CircleDiscState();
}

class _CircleDiscState extends State<CircleDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  stopRotation() {
    _animationController.stop();
  }

  startRotation() {
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongController>(builder: (context, controller, child) {
      controller.isPlaying ? startRotation() : stopRotation();
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 6.3,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context).splashColor,
                  size: Config.yMargin(context, widget.iconSize),
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).splashColor,
                    offset: Offset(5, 5),
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Theme.of(context).backgroundColor,
                    offset: Offset(-5, -5),
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
