import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:emotion_detector/home.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:  ThemeData(primaryColor: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: const Home()
    );
  }
}


