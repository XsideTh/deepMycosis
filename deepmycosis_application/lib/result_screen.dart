import 'dart:io';

import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String? result, image, prob;

  const ResultScreen(
      {super.key,
      required this.result,
      required this.image,
      required this.prob});
  static const routeName = 'result-screen';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
