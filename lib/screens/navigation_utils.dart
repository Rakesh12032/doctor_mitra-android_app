import 'package:flutter/material.dart';

void push(BuildContext context, Widget screen) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (_, animation, __) => screen,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.04, 0.02), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
      );
    },
  ));
}

void pushReplacement(BuildContext context, Widget screen) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => screen));
}

void openActivePanel(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}
