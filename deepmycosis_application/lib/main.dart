import 'package:DeepMycosis/camera_screen.dart';
import 'package:DeepMycosis/about_screen.dart';
import 'package:DeepMycosis/history_screen.dart';
import 'package:DeepMycosis/home_screen.dart';
import 'package:DeepMycosis/modeling.dart';
import 'package:DeepMycosis/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialization(null);
  const myApp = MyApp();

  runApp(myApp);
}

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 3));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
            cam: State.queryParams['cam']!,
          ),
        ),
        GoRoute(
          path: '/modeling',
          name: modeling.routeName,
          builder: (context, State) => modeling(
            image: State.queryParams['image']!,
            cam: State.queryParams['cam']!
          ),
        ),
        GoRoute(
          path: '/history',
          name: history.routeName,
          builder: (context, State) => history(),
        ),
        GoRoute(
          path: '/about',
          name: about.routeName,
          builder: (context, State) => about(),
        ),
      ]),
    );
  }
}
