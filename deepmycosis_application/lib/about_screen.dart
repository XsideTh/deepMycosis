import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class about extends StatefulWidget {
  const about({super.key});

  @override
  State<about> createState() => _aboutState();
  static const routeName = 'about';
}

class _aboutState extends State<about> {
  @override
  static const List<(Color?, Color? background, ShapeBorder?)> customizations =
      <(Color?, Color?, ShapeBorder?)>[
    (null, null, null), // The FAB uses its default for null parameters.
    (null, Colors.green, null),
    (Colors.white, Colors.green, null),
    (Colors.white, Colors.green, CircleBorder()),
  ];
  int FAindex = 0;

  Widget build(BuildContext context) {
    final image = File("assets/images/about.png");
    return Scaffold(
            appBar: AppBar(
              title: const Text('About'),
            ),
            backgroundColor: Color.fromRGBO(118, 134, 125, 1),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                  FittedBox(
                      child: Image.asset(
                        'assets/images/about.png',
                        fit: BoxFit.fill,
                      ))]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.go("/");
              },
              foregroundColor: customizations[FAindex].$1,
              backgroundColor: customizations[FAindex].$2,
              shape: customizations[FAindex].$3,
              child: const Icon(Icons.arrow_back),
            ));
  }
}
