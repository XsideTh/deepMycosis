import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
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
  String? _results;
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
          "assets/model/dmnet.pt", 224, 224, 1000,
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
    String imagePrediction = await classificationModel
        .getImagePrediction(await File(image.path).readAsBytes());
    /*final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.1,
      imageStd: 1,
    );*/
    print("Models evaluated : $imagePrediction");
    setState(() {
      _results = imagePrediction!;
      _image = image;
      imageSelect = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: FutureBuilder(
          future: initialzationCamera(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AspectRatio(
                      aspectRatio: 2 / 3, child: CameraPreview(controller)),
                  AspectRatio(
                      aspectRatio: 2 / 3,
                      child: Image.asset(
                        'assets/images/camera-overlay-conceptcoder.png',
                        fit: BoxFit.cover,
                      )),
                  InkWell(
                    onTap: () => onTakePicture(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
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
    imageClassification(image);
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

  Future<String> _resizePhoto(String filePath) async {
    File croppedFile =
        await FlutterNativeImage.cropImage(filePath, 170, 70, 265, 350);

    return Future.value(croppedFile.path);
  }

/*
  Future<CroppedFile?> _cropImage(String imagePath) async {
    var croppedFile = await ImageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
    );
    return croppedFile;
  }*/

  void saveFile(var contents) async {
    File file = File(await getFilePath()); // 1
    file.writeAsBytes(contents); // 2
  }

  onTakePicture() async {
    await controller.takePicture().then((XFile xfile) async {
      if (mounted) {
        // ignore: unnecessary_null_comparison
        if (xfile != null) {
          String crop_image = await _resizePhoto(xfile.path);

          //saveFile(Image.file(File(xfile.path)).image);
          // using your method of getting an image
          final File image = File(crop_image);

          // copy the file to a new path
          await image.copy('/sdcard/Pictures/sample.jpg');
          //await imageClassification(File(crop_image));
          await pickImage(ImageSource.gallery);
          var answer = _results;
          if (answer != null) {
            showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(title: Text('test'), content: Text(answer)));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text('test'), content: Text(answer.toString())));
          }
        }
      }
    });
  }
}

enum EnumCameraDescription { front, back }
