import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' as path;

class ResultScreen extends StatelessWidget {
  String? result, image, prob;

  ResultScreen({
    super.key,
    required this.result,
    required this.image,
    required this.prob,
  });
  static const routeName = 'result-screen';

  @override
  //State<ResultScreen> createState() => _ResultScreenState(result!, image!);

  @override
  Widget build(BuildContext context) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String? datetime = tsdate.day.toString() +
        "-" +
        tsdate.month.toString() +
        "-" +
        tsdate.year.toString() +
        "_" +
        tsdate.hour.toString() +
        "-" +
        tsdate.minute.toString();
    // File picture = File("/sdcard/Pictures/sample.jpg");

    String name = "${result}_${datetime}_${prob!}.jpg";
    if (!result!.contains("Non")) {
      name = "Pythium_${datetime}_${prob!}.jpg";
    }

    File picture = File(image!);
    print('Original path: ${picture.path}');
    String dir = path.dirname(picture.path);
    String newPath = path.join(dir, name);
    print('NewPath: ${newPath}');
    picture.renameSync(newPath);

    GallerySaver.saveImage(newPath, albumName: "pythium");

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(File(newPath)),
            Center(
              child: Visibility(
                visible: result != null,
                child: Text(
                  "$result",
                  maxLines: 3,
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: result != null,
                child: Text(
                  "($prob)",
                  maxLines: 3,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
class _ResultScreenState extends State<ResultScreen> {
  String result, image;

  _ResultScreenState(String this.result, String this.image);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(image!),
            Center(
              child: Visibility(
                visible: result != null,
                child: Text(
                  "${result}",
                  maxLines: 3,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
