import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';

class history extends StatefulWidget {
  const history({super.key});
  static const routeName = 'history';

  @override
  State<history> createState() => _historyState();
}

class ListPythium {
  String? type, time, path, prob;
}

class _historyState extends State<history> {
//Declare Globaly
  List<ListPythium> images = [];

  // Make New Function
  void _listofFiles() async {
    final dir = await getExternalStorageDirectory();
    /*final directory = await getApplicationDocumentsDirectory(). +
        "/sdcard/Pictures";*/
    /*final pythiumDir = new Directory(directory + "/Pythium_/");*/
    final nonDir = Directory("sdcard/Pictures/NonPythium").listSync();

    nonDir.forEach((img) {
      String time = img
          .toString()
          .substring(img.toString().lastIndexOf('/') + 1, img.toString().length)
          .substring(11, 30);
      String prob = img
          .toString()
          .substring(img.toString().lastIndexOf('/') + 1, img.toString().length)
          .substring(32, 37);
      ListPythium list = new ListPythium();
      list.type = "NonPythium";
      list.time = time;
      list.path = img.path;
      list.prob = prob;
      images.add(list);
    });
    print(images.length);
  }

  @override
  Widget build(BuildContext context) {
    _listofFiles();
    return MaterialApp(
      title: 'List of Files',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Get List of Files with whole Path"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              /*
              // your Content if there
              Expanded(
                child: ListView.builder(
                    itemCount: pythiumfile.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(pythiumfile[index].toString());
                    }),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
