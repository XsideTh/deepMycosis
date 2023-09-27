import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;

  late File _image;
  List? _results;
  bool imageSelect = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model/dm_0.0001_16.tflite",
        labels: "assets/model/labels.txt"))!;
    print("Models loading status: $res");
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.1,
      imageStd: 1,
    );
    print("Models evaluated : ${recognitions.toString()}");
    setState(() {
      _results = recognitions!;
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

  Future<String> getFilePath() async {
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
          var crop_image = new SizedBox(
            child: AspectRatio(
              aspectRatio: 487 / 300,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      // fitWidth ให้รูปเป็นแนวนอน
                      alignment: FractionalOffset.center,
                      image: (Image.file(File(xfile.path)).image)),
                ),
              ),
            ),
          );
          //saveFile(Image.file(File(xfile.path)).image);
          // using your method of getting an image
          final File image = File(xfile.path);

// getting a directory path for saving
          final String path = await getFilePath();

// copy the file to a new path
          final File newImage = await image.copy('/sdcard/Pictures/sample.jpg');
          await imageClassification(File(xfile.path));
          var answer;
          _results?.map((result) {
            answer = Text(
              "${result['label']}",
            );
          });
          if (answer != null) {
            showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(title: Text('test'), content: Text(answer)));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text('test'), content: Text("Not Pythium")));
          }
        }
      }
    });
  }
}

enum EnumCameraDescription { front, back }
