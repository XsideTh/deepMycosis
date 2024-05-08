import 'dart:io';

import 'package:DeepMycosis/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:pytorch_lite/pytorch_lite.dart';

class modeling extends StatelessWidget {
  final String image, cam;
  const modeling({super.key, required this.image, required this.cam});
  static const routeName = 'modeling';

  @override
  Widget build(BuildContext context) {
    main(context);
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  List<double> normalize(
      List<double> data, List<double> means, List<double> stds) {
    List<double> normalizedData = [];
    for (int i = 0; i < data.length; i++) {
      int j = 0;
      if(j >= 3){
        j = 0;
      }
      if((data[i] - means[j]) / stds[j] > 1){
        normalizedData.add(1);
      }else{
        normalizedData.add((data[i] - means[j]) / stds[j]);
      }
      j++;
    }
    return normalizedData;
  }

  Future<void> main(BuildContext context) async {
    var classificationModel = await loadModel();
    //resize รูปภาพเพื่อให้อยู่ใน ขนาด 224*224
    final cmd = img.Command()
      ..decodeImageFile(image)
      ..copyResize(width: 224, height: 224)
      ..writeToFile(image);
      //..normalize(min: -255,max: 255);
    await cmd.executeThread();
    var probResult = await imageClassification(image, classificationModel!);
    print(probResult[0]);
    //ไปหน้า result_screen.dart โดยส่ง path ของ image, ผลลัพธ์ที่ได้ว่าเป็น pythium หรือไม่, ค่า prob และ cam ที่จะบอกว่ามากจากกล้องหรือไม่
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
          //path model, ความกว้าง, ความสูง, จำนวน class และ path ของ label
          "assets/model/model.pt",
          224,
          224,
          2,
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
    //ค่า mean std ได้จากการหามาแล้วจากการทำ model
    var means = [0.485, 0.456, 0.406];
    var stds = [0.229, 0.224, 0.225];
    var imagePrediction = await classificationModel
        .getImagePredictionList((await File(image).readAsBytes()), mean: means, std: stds);
    //ตัวที่ 0 เป็นค่า prob ของรูปที่ได้จากการทำนาย
    print("prob 0 : ${imagePrediction[0]}");

    var cutoff = 0.318;
    var _prob = imagePrediction[0];

    var probStr = (_prob * 100).toStringAsFixed(2) as String;
    while (probStr.length < 6) {
      probStr = "0" + probStr;
    }
    print(probStr);
    var _results = "";
    //หากค่า prob มากกว่าค่า cutoff จะเป็น pythium
    if (_prob > cutoff) {
      return ["pythium", probStr];
    } else {
      return ["Non-pythium", probStr];
    }
  }
}
