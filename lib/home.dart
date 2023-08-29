import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  bool modelRunning = false;
  bool isloading = false;
  bool isSignedIn = false;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile'
    ],
  );

  signin() async {
    isloading = true;
    setState(() {});
    await googleSignIn.signIn();
    isloading = false;
    setState(() {});
  }

  checkIfSignedIn() async{
    isloading = true;
    setState(() {});
    isSignedIn = await googleSignIn.isSignedIn();
    isloading = false;
    setState(() {});
  }

  signOut() async{
    isloading = true;
    setState(() {});
    await googleSignIn.signOut();
    isloading = false;
    setState(() {});
  }

  loadCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.low);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        cameraController!.startImageStream((imageStream) {
          cameraImage = imageStream;
          setState(() {});
          if(!modelRunning){
            runModel();
          }
        });
      }
    });
  }

  runModel() async {
    if (cameraImage != null) {
      print('md ran');
      modelRunning = true;
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      for (var element in predictions!) {
        setState(() {
          output = element['label'].toString().split(' ').last;
        });
        print(element['label']);
      }
      modelRunning = false;
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    checkIfSignedIn();
    loadModel();
    loadCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle:true,
        elevation: 0.4,
        backgroundColor: Colors.white,
        title: Text("Emosense", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(onPressed: () async{
            await signOut();
            checkIfSignedIn();
          }, icon: Icon(Icons.logout, color: Colors.black,))
        ],
      ),
      body: isSignedIn  ? Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: !cameraController!.value.isInitialized
                  ? Container()
                  : AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    ),
            ),
          ),
          Text(output, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
        ],
      ) : Container (
        child:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You are not signed in"),
              ElevatedButton(onPressed: () async{
                await signin();
                checkIfSignedIn();
              }, child: const Text("Sign in"))
            ],
          ),
        ),
      ),
    );
  }
}
