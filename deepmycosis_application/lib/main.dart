import 'package:deepmycosis_application/camera_screen.dart';
import 'package:deepmycosis_application/home_screen.dart';
import 'package:deepmycosis_application/modeling.dart';
import 'package:deepmycosis_application/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  const myApp = MyApp();

  runApp(myApp);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Deepmyosis Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: GoRouter(routes: [
        GoRoute(
          path: '/',
          name: HomeScreen.routeName,
          builder: (context, State) => HomeScreen(),
        ),
        GoRoute(
          path: '/camera',
          name: Camera_Screen.routeName,
          builder: (context, State) => Camera_Screen(),
        ),
        GoRoute(
          path: '/result',
          name: ResultScreen.routeName,
          builder: (context, State) => ResultScreen(
            result: State.queryParams['result']!,
            image: State.queryParams['image']!,
            prob: State.queryParams['prob']!,
          ),
        ),
        GoRoute(
          path: '/modeling',
          name: modeling.routeName,
          builder: (context, State) => modeling(
            image: State.queryParams['image']!,
          ),
        ),
      ]),
    );
  }
}
