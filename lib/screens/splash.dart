import 'package:flutter/material.dart';

import '../providers/all_songs.dart';
import '../providers/playList_database.dart';
import '../providers/song_controller.dart';
import '../util/config.dart';
import 'package:provider/provider.dart';
import 'package:music/screens/library.dart';

class SplashScreen extends StatefulWidget {
  final ThemeData theme;
  const SplashScreen({required this.theme, super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Animation _colorAnimation;
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: 1), upperBound: 1.0)
      ..addListener(() {
        if (_controller.isCompleted) {
          Provider.of<ProviderClass>(context, listen: false).init();
          Provider.of<SongController>(context, listen: false).init(
          
          );
          Provider.of<PlayListDB>(context, listen: false).init();

          Future.delayed(Duration(seconds: 2)).then((value) {
            Navigator.pushReplacementNamed(context, Library.pageId);
          });
        }
      });
    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: widget.theme!.scaffoldBackgroundColor,
    ).animate(_controller);
    _controller.forward();
    super.initState();
  }

  @override
  void deactivate() {
    _controller.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double height = isPotrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _colorAnimation.value,
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(
            vertical: isPotrait
                ? _curvedAnimation.value * (height / 3.1)
                : _curvedAnimation.value * (height / 10.5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(
              opacity: _curvedAnimation.value,
              child: SizedBox(
                width: Config.xMargin(context, _curvedAnimation.value * 55),
                height: Config.yMargin(context, _curvedAnimation.value * 25),
                child: Image(
                  image: AssetImage('images/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Opacity(
              opacity: _curvedAnimation.value,
              child: Text(
                'SD Player',
                textAlign: TextAlign.center,
                style: TextStyle(
                  //color: Colors.black,
                  fontSize:
                      Config.textSize(context, _curvedAnimation.value * 8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
