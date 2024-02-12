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
  late String type, time, path, prob;
}

class _historyState extends State<history> {
//Declare Globaly
  List<ListPythium> images = [];

  // Make New Function
  void _listofFiles() async {
    
    /*final directory = await getApplicationDocumentsDirectory(). +
        "/sdcard/Pictures";*/

      /*final Dirtest = Directory("sdcard/Pictures").listSync();
      Dirtest.forEach((element) {print(element);});*/
    
      final nonDir = Directory("sdcard/Pictures/NonPythium").listSync();
      nonDir.forEach((img) {
        String time = img
            .toString()
            .substring(
                img.toString().lastIndexOf('/') + 1, img.toString().length)
            .substring(11, 30);
        String prob = img
            .toString()
            .substring(
                img.toString().lastIndexOf('/') + 1, img.toString().length)
            .substring(31, 37);
        print("nonpythium time : " + time + " with prob : " + prob);
        ListPythium list = new ListPythium();
        list.type = "NonPythium";
        list.time = time;
        list.path = img.path;
        list.prob = prob;
        images.add(list);
      });
    
      final pythiumDir = Directory("sdcard/Pictures/Pythium_").listSync();
      pythiumDir.forEach((img) {
        String time = img
            .toString()
            .substring(
                img.toString().lastIndexOf('/') + 1, img.toString().length)
            .substring(8, 27);
        String prob = img
            .toString()
            .substring(
                img.toString().lastIndexOf('/') + 1, img.toString().length)
            .substring(28, 34);
        print("pyhium time : " + time + " with prob : " + prob);
        ListPythium list = new ListPythium();
        list.type = "Pythium";
        list.time = time;
        list.path = img.path;
        list.prob = prob;
        images.add(list);
      });
      //print(images.length);
      images.sort((a, b) => b.time.compareTo(a.time));
      images.forEach((element) {
        print(element.time);
      });
  }

  @override
  Widget build(BuildContext context) {
    _listofFiles();
    return MaterialApp(
      title: 'List of Files',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Deep Mycosis"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              // your Content if there
              Expanded(
                child: ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      TextStyle styleText = TextStyle(fontSize: 20.0);
                      return Column(children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.file(
                                File(images[index].path),
                                scale: 1.75,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("  type : ${images[index].type}",
                                      style: styleText),
                                  Text("  date : ${images[index].time}",
                                      style: styleText),
                                  Text("  probability : ${images[index].prob}%",
                                      style: styleText)
                                ],
                              ),
                            ])
                      ]);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
