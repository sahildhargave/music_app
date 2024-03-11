import 'package:flutter/material.dart';
import 'package:music/util/config.dart';

class CustomButton extends StatefulWidget {
  CustomButton(
      {required this.diameter,
      required this.onPressed,
      required this.child,
      this.isToggled = false});
  final double diameter;
  final IconData child;
  final Function onPressed;
  final bool isToggled;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            widget.onPressed;
          },
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          child: Transform.scale(
            scale: 1 - _controller.value,
            child: Container(
              child: Center(
                child: Icon(
                  widget.child,
                  size: Config.textSize(context, 5),
                  color: widget.isToggled
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color!.withOpacity(0.8),
                ),
              ),
              height: Config.xMargin(context, widget.diameter),
              width: Config.xMargin(context, widget.diameter),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
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
          ),
        );
      },
    );
  }
}
