import 'dart:io';

import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String? result, image;

  const ResultScreen({
    super.key,
    required this.result,
    required this.image,
  });
  static const routeName = 'result-screen';

  @override
  //State<ResultScreen> createState() => _ResultScreenState(result!, image!);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(File(image!)),
            Center(
              child: Visibility(
                visible: result != null,
                child: Text(
                  "${result}",
                  maxLines: 3,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
class _ResultScreenState extends State<ResultScreen> {
  String result, image;

  _ResultScreenState(String this.result, String this.image);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(image!),
            Center(
              child: Visibility(
                visible: result != null,
                child: Text(
                  "${result}",
                  maxLines: 3,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
