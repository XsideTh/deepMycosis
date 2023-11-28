import 'dart:io';

import 'package:deepmycosis_application/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class Camera_Screen extends StatefulWidget {
  const Camera_Screen({super.key});
  static const routeName = 'camera-screen';

  @override
  State<Camera_Screen> createState() => _Camera_ScreenState();
}

class _Camera_ScreenState extends State<Camera_Screen> {
  late CameraController controller;

  late File _image;
  String? _results;
  double? _prob;
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
      classificationModel = await PytorchLite.loadClassificationModel(
          "assets/model/model.pt", 224, 224, 2,
          labelPath: "assets/model/labels.txt");
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
        title: Text('Camera'),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: initialzationCamera(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AspectRatio(
                      aspectRatio: 52 / 99, child: CameraPreview(controller)),
                  AspectRatio(
                      aspectRatio: 52 / 99,
                      child: Image.asset(
                        'assets/images/camera-overlay-conceptcoder.png',
                        fit: BoxFit.cover,
                      )),
                  InkWell(
                    onTap: () => onTakePicture(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: CircleAvatar(
                        radius: 35.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future<void> initialzationCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(
        cameras[EnumCameraDescription.front.index], ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420);
    await controller.initialize();
  }

  Future getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/sample.png'; // 3
    print(filePath);
    return filePath;
  }

  void saveFile(var contents) async {
    File file = File(await getFilePath()); // 1
    file.writeAsBytes(contents); // 2
  }

  onTakePicture() async {
    await controller.takePicture().then((XFile xfile) async {
      if (mounted) {
        // ignore: unnecessary_null_comparison
        if (xfile != null) {
          var crop_image = await Future.value(
              FlutterNativeImage.cropImage(xfile.path, 224, 154, 175, 175));

          //saveFile(Image.file(File(xfile.path)).image);
          // using your method of getting an image
          final File image = File(crop_image.path);

          // copy the file to a new path
          await image.copy('/sdcard/Pictures/sample.jpg');
          await imageClassification(File(crop_image.path));

          // context.goNamed(ResultScreen.routeName, queryParams: {
          //   'image': image.path,
          //   'result': _results,
          //   'prob': _prob.toString()
          // });

          resultShow();
        }
      }
    });
  }

  void resultShow() {
    if (_results != null) {
      var prob = _prob;
      var probResult;
      if (prob! < 0.318) {
        prob = 1 - prob;
      }
      if (prob! > 0.87) {
        probResult = "High probability";
      } else if (prob! > 0.5 && prob! < 0.87) {
        probResult = "Medium probability";
      } else {
        probResult = "Low probability";
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text('Result'),
              content: Text(
                  "There is " + probResult + " That this is\n" + _results!)));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text('Result'), content: Text("error result is null")));
    }
  }
}

enum EnumCameraDescription { front, back }
