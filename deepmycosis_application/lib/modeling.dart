import 'dart:io';

import 'package:DeepMycosis/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class modeling extends StatelessWidget {
  final String image, cam;
  const modeling({super.key, required this.image, required this.cam});
  static const routeName = 'modeling';

  @override
  Widget build(BuildContext context) {
    var count = 0;
    if (count == 0) {
      main(context);
      count++;
    }

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> main(BuildContext context) async {
    var classificationModel = await loadModel();
    var probResult = await imageClassification(image, classificationModel!);
    print(probResult[0]);
    context.goNamed(ResultScreen.routeName, queryParams: {
      'image': image,
      'result': probResult[0],
      'prob': probResult[1],
      'cam': cam
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

  Future<List> imageClassification(
      String image, ClassificationModel classificationModel) async {
    var imagePrediction = await classificationModel
        .getImagePredictionList(await File(image).readAsBytes());
    print("prob 0 : ${imagePrediction[0]}");

    var cutoff = 0.318;
    var _prob = imagePrediction[0]; ////เก็บค่าตัวสองของ list

    var probStr = (_prob * 100).toStringAsFixed(2) as String;
    while (probStr.length < 6) {
      probStr = "0" + probStr;
    }
    print(probStr);
    var _results = "";
    if (imagePrediction[0] > cutoff) {
      return ["pythium", probStr];
    } else {
      return ["Non-pythium", probStr];
    }
  }
}
