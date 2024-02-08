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
    String day = tsdate.day.toString();
    String month = tsdate.month.toString();
    String hour = tsdate.hour.toString();
    String minute = tsdate.minute.toString();
    String second = tsdate.second.toString();
    if (day.length <= 1) minute = "0" + day;
    if (month.length <= 1) second = "0" + month;
    if (hour.length <= 1) minute = "0" + hour;
    if (minute.length <= 1) minute = "0" + minute;
    if (second.length <= 1) second = "0" + second;
    String? datetime = day +
        "-" +
        month +
        "-" +
        tsdate.year.toString() +
        "_" +
        hour +
        "-" +
        minute +
        "-" +
        second;
    // File picture = File("/sdcard/Pictures/sample.jpg");

    String name = "${result}_${datetime}_${prob!}.jpg";
    File picture = File(image!);
    if (!result!.contains("Non")) {
      name = "Pythium_${datetime}_${prob!}.jpg";
    }
    print('Original path: ${picture.path}');
    String dir = path.dirname(picture.path);
    String newPath = path.join(dir, name);
    print('NewPath: ${newPath}');
    picture.renameSync(newPath);

    GallerySaver.saveImage(newPath, albumName: result!);

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
                  "(with $prob% probability)",
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
