import 'dart:io';

import 'package:deepmycosis_application/result_screen.dart';
import 'package:deepmycosis_application/modeling.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
  }

static const List<(Color?, Color? background, ShapeBorder?)> customizations =
      <(Color?, Color?, ShapeBorder?)>[
    (null, null, null), // The FAB uses its default for null parameters.
    (null, Colors.green, null),
    (Colors.white, Colors.green, null),
    (Colors.white, Colors.green, CircleBorder()),
  ];
  int FAindex = 0;

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
          }),floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.go("/");
            },
            foregroundColor: customizations[FAindex].$1,
            backgroundColor: customizations[FAindex].$2,
            shape: customizations[FAindex].$3,
            child: const Icon(Icons.arrow_back),
          ),
    );
  }

  Future<void> initialzationCamera() async {
    var cameras =
        await availableCameras(); //คำสั่งที่ใช้ในการทำให้กล้องพร้อมที่จะใช้งานกล้อง
    controller = CameraController(
        // controller ทำการเรียกใช้งานกล้องโดยใช้กล้องหลัง และมีความระเอียดปานกลาง
        cameras[EnumCameraDescription.front.index],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420);
    //controller.setFlashMode(FlashMode.off);
    await controller.initialize();
  }

  onTakePicture() async {
    //controller ทำการถ่ายรูปเก็บไว้ในตัวแปล xfile แล้วทำงานภายในต่อ
    await controller.takePicture().then((XFile xfile) async {
      if (mounted) {
        // ignore: unnecessary_null_comparison
        if (xfile != null) {
          File fullimage = File(xfile.path);
          var decodedImage =
              await decodeImageFromList(fullimage.readAsBytesSync());

          int multiply =
              ((320 - (decodedImage.height / 2).round()) / 2).round();
          if (multiply <= 0) multiply = 1;
          int middleX = (decodedImage.width / 2).round();
          int middleY = (decodedImage.height / 2).round();
          print("middle X is" + middleX.toString());
          print("middle y is" + middleY.toString());
          int size = 224;

          var crop_image;
          if (middleY <= 340) {
            crop_image = await Future.value(
                //Future.value คือการนำค่าจาก function มาใช้ฏ
                //ตัดรูปภาพขนาด 224224 ที่ตำแหน่ง x:224 Y:154
                FlutterNativeImage.cropImage(
                    xfile.path,
                    (middleX + 10) - ((size / 2).round()),
                    (middleY - 30) - ((size / 2).round()),
                    size,
                    size));
          } else {
            crop_image = await Future.value(
                //Future.value คือการนำค่าจาก function มาใช้
                //ตัดรูปภาพขนาด 224224 ที่ตำแหน่ง x:224 Y:154
                FlutterNativeImage.cropImage(
                    xfile.path,
                    (middleY - 30) - ((size / 2).round()),
                    (middleX - 5) - ((size / 2).round()),
                    size,
                    size));
          }

          // using your method of getting an image
          final File image = File(crop_image.path);

          //ตรวจสอบว่ามีไฟล์อยู่หรือไม่
          // if (await File('/sdcard/Pictures/sample.jpg').exists()) {
          //   await File('/sdcard/Pictures/sample.jpg').delete();
          //   await image.copy('/sdcard/Pictures/sample.jpg');
          // } else {
          //   // copy the file to a new path
          //   await image.copy('/sdcard/Pictures/sample.jpg');
          // }

          gotoModel(crop_image.path);

/*
          await imageClassification(File(crop_image
              .path)); //นำรูปภาพที่ตัดไว้แล้วมาทำการตรวจสอบว่าเป็น pythium หรือไม่

          resultShow(crop_image.path);*/
        }
      }
    });
  }

  void gotoModel(String image) {
    context.goNamed(modeling.routeName, queryParams: {
      'image': image,
      'cam':"y"
    });
  }

  // Future getFilePath() async {
  //   Directory appDocumentsDirectory =
  //       await getApplicationDocumentsDirectory(); // 1
  //   String appDocumentsPath = appDocumentsDirectory.path; // 2
  //   String filePath = '$appDocumentsPath/sample.png'; // 3
  //   print(filePath);
  //   return filePath;
  // }

  // void saveFile(var contents) async {
  //   File file = File(await getFilePath()); // 1
  //   file.writeAsBytes(contents); // 2
  // }
}

enum EnumCameraDescription { front, back }
