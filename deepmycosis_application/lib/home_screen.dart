import 'dart:io';

import 'package:deepmycosis_application/history_screen.dart';
import 'package:deepmycosis_application/modeling.dart';
import 'package:deepmycosis_application/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late File _image;
  late String _results;
  late double _prob;
  bool imageSelect = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }
/*
  @override
  void dispose() {
    //super.dispose();
    //Tflite.close();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Deep Mycosis'),
        ),
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => context.go("/camera"), child: Text("Camera")),
            ElevatedButton(
                //เป็นปุ่มที่เมื่อกดแล้วจะทำการเลือกรูปภาพจาก gallery
                onPressed: () => pickImage(ImageSource.gallery),
                child: Text("Gallery")),
            ElevatedButton(
                onPressed: () => context.go("/history"),
                child: Text("History")),
          ],
        )));
  }

  Future pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );

    // using your method of getting an image
    //final File image = File(pickedFile!.path);

    // //ตรวจสอบว่ามีไฟล์อยู่หรือไม่
    // if (await File('/Pictures/sample.jpg').exists()) {
    //   await File('/Pictures/sample.jpg').delete();
    //   await image.copy('/Pictures/sample.jpg');
    // } else {
    //   // copy the file to a new path
    //   await image.copy('/Pictures/sample.jpg');
    // }

    context.goNamed(modeling.routeName, queryParams: {
      'image': pickedFile!.path,
      'cam':"n"
    });

    /*
    setState(() {
      isLoading = true;
      imageSelect = false;
    });

    File image = File(pickedFile!.path);
    await imageClassification(image);

    resultShow(pickedFile!.path);*/
  }
}
