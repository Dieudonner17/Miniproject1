import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    loadModel(); // Load the model before using it
    return MaterialApp(
      title: 'Garden of Eden',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Times New Roman',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String diseaseLabel = '';
  String remedy = '';
  File? image;
  @override
  void dispose() {
    disposeModel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
        diseaseLabel = '';
        remedy = '';
      });
    }
  }

  Future<void> _detectDisease() async {
    var recognition = await classifyImage(image!);
    setState(() {
      diseaseLabel = recognition['label'];
      remedy = getRemedyForDiseaseFromDatabase(diseaseLabel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease Checker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Capture/Select Image'),
            ),
            SizedBox(height: 20),
            if (image != null) Image.file(image!) else SizedBox(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: image != null ? _detectDisease : null,
              child: Text('Detect Disease'),
            ),
            SizedBox(height: 20),
            Text('Detected Disease: $diseaseLabel'),
            Text('Remedy: $remedy'),
          ],
        ),
      ),
    );
  }
}

loadModel() async {
  await Tflite.loadModel(
    model: 'assets/model.tflite',
    labels: 'assets/labels.txt',
  );
}

Future<Map<String, dynamic>> classifyImage(File image) async {
  var recognitions = await Tflite.runModelOnImage(
    path: image.path,
    numResults: 5,
    threshold: 0.1,
    imageMean: 127.5,
    imageStd: 127.5,
  );
  return recognitions![0];
}

String getRemedyForDiseaseFromDatabase(String diseaseLabel) {
  // Perform database query to retrieve symptoms and treatment information
  // based on the disease label.
  // Replace the following return statements with your database logic.
  switch (diseaseLabel) {
    case 'Tomato Diseases':
      return 'Water the plants and apply fungicide.';
    case 'Cocoa Diseases':
      return 'Prune infected branches and apply insecticide.';
    default:
      return 'Remedy not found.';
  }
}

disposeModel() {
  Tflite.close();
}
