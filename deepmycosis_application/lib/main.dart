import 'package:deepmycosis_application/home_screen.dart';
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
            pageBuilder: (context, State) => const NoTransitionPage(
                  child: HomeScreen(),
                ))
      ]),
    );
  }
}
