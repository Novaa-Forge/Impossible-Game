import 'package:flutter/material.dart';
import 'package:impossible_game/src/controller/audio_controller.dart';
import 'package:impossible_game/src/controller/game_controller.dart';
import 'package:impossible_game/src/view/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        ChangeNotifierProvider(create: (_) => AudioController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impossible Game',
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
