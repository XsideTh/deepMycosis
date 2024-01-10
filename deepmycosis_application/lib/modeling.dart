import 'dart:io';

import 'package:deepmycosis_application/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class modeling extends StatelessWidget {
  final String image;
  const modeling({super.key, required this.image});
  static const routeName = 'modeling';

  @override
  Widget build(BuildContext context) {
    main(context);

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> main(BuildContext context) async {
    var classificationModel = await loadModel();
    var probResult = await imageClassification(image, classificationModel!);
    context.goNamed(ResultScreen.routeName, queryParams: {
      'image': image,
      'result': probResult,
    });
  }

  Future<ClassificationModel?> loadModel() async {
    try {
      //โหลด model โดยการใช้
      var classificationModel = await PytorchLite.loadClassificationModel(
          //path model ความกว้าง ความสูง ของรูป
          "assets/model/model.pt",
          224,
          224,
          2,
          //และ path label
          labelPath: "assets/model/labels.txt");
      return classificationModel;
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
      return null;
    }
  }

  Future<String> imageClassification(
      String image, ClassificationModel classificationModel) async {
    List<String> imagePrediction =
        await classificationModel //ค่าที่รับมาเป็น list
            .getImagePrediction(await File(image).readAsBytes());
    print(
        "prediction is : ${imagePrediction[0]}"); //ค่าตัวแรกของ list จะบอกว่าเป็น pythium หรือไม่
    print(
        "with prob is : ${imagePrediction[1]}"); //ค่าตัวที่สองของ list จะบอกว่ามีโอกาสเป็น Pythium เท่าไหร่
    var _results = imagePrediction[0]; //เก็บค่าตัวแรกของ list
    var _prob = double.parse(imagePrediction[1]); ////เก็บค่าตัวสองของ list
    var probResult;

    if (_results != null) {
      var prob = _prob;
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
    }
    return probResult;
  }
}