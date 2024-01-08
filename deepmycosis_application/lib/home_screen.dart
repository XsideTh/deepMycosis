import 'dart:io';

import 'package:camera/camera.dart';
import 'package:deepmycosis_application/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;

  late File _image;
  late String _results;
  late double _prob;
  bool imageSelect = false;
  bool isLoading = false;

  late ClassificationModel classificationModel;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    try {
      //โหลด model โดยการใช้
      classificationModel = await PytorchLite.loadClassificationModel(
          //path model ความกว้าง ความสูง ของรูป
          "assets/model/model.pt",
          224,
          224,
          2,
          labelPath: "assets/model/labels.txt"); //และ path label
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    //Tflite.close();
  }

  Future imageClassification(File image) async {
    List<String> imagePrediction = await classificationModel
        .getImagePrediction(await File(image.path).readAsBytes());
    print("prediction is : ${imagePrediction[0]}");
    print("with prob is : ${imagePrediction[1]}");
    setState(() {
      _results = imagePrediction[0];
      _prob = double.parse(imagePrediction[1]);
      _image = image;
      imageSelect = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Deep Mycosis'),
        ),
        body: ButtonBar(
          children: <Widget>[
            ElevatedButton(
                onPressed: () => context.go("/camera"), child: Text("Camera")),
            ElevatedButton(
                //เป็นปุ่มที่เมื่อกดแล้วจะทำการเลือกรูปภาพจาก gallery
                onPressed: () => pickImage(ImageSource.gallery),
                child: Text("Gallery"))
          ],
          alignment: MainAxisAlignment.center,
          buttonHeight: 50,
          buttonMinWidth: 200,
          buttonPadding: EdgeInsets.all(40),
          overflowButtonSpacing: 10,
          overflowDirection: VerticalDirection.down,
          mainAxisSize: MainAxisSize.max,
        ));
  }

  Future pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );

    setState(() {
      isLoading = true;
      imageSelect = false;
    });
    File image = File(pickedFile!.path);
    await imageClassification(image);

    resultShow(pickedFile!.path);
  }

  void resultShow(String image) {
    if (_results != null) {
      var prob = _prob;
      var probResult;
      if (prob! < 0.318) {
        prob = 1 - prob;
      }
      if (prob! > 0.87) {
        probResult = "There is High probability That this is " + _results!;
      } else if (prob! > 0.5 && prob! < 0.87) {
        probResult = "There is Medium probability That this is " + _results!;
      } else {
        probResult = "There is Low probability That this is " + _results!;
      }

      context.goNamed(ResultScreen.routeName, queryParams: {
        'image': image,
        'result': probResult,
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text('Result'), content: Text("error result is null")));
    }
  }
}
