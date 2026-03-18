import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MotivationApp());

class MotivationApp extends StatelessWidget {
  const MotivationApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const MotivationHome(),
    );
  }
}

class MotivationHome extends StatefulWidget {
  const MotivationHome({super.key});
  @override
  State<MotivationHome> createState() => _MotivationHomeState();
}

class _MotivationHomeState extends State<MotivationHome> {
  File? _image;
  static const platform = MethodChannel('motivation_widget/update');
  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('image_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _image = File(path));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (pickedFile == null) return;

    // BETTER WAY: Use the library's built-in path provider correctly
    // On Android, 'getApplicationDocumentsDirectory' is /app_flutter
    // We want the sibling 'files' directory for the widget
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appRoot = appDocDir.parent.path;
    final String targetPath = '$appRoot/files/motivation.jpg';
    final File savedImage = File(targetPath);

    // Create 'files' directory if it doesn't exist
    if (!await savedImage.parent.exists()) {
      await savedImage.parent.create(recursive: true);
    }

    // Copy and overwrite
    await File(pickedFile.path).copy(savedImage.path);

    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('image_path', savedImage.path);

    // Force UI Update
    await FileImage(savedImage).evict();
    setState(() {
      _image = savedImage;
      _imageVersion++;
    });

    try {
      await platform.invokeMethod('updateWidget');
    } catch (e) {
      debugPrint("Native error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motivation Wall')),
      body: Center(
        child:
            _image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    key: ValueKey(_imageVersion),
                    height: 350,
                    width: 350,
                    fit: BoxFit.cover,
                  ),
                )
                : const Text("Select an image for your home screen"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        label: const Text("Set Widget Image"),
        icon: const Icon(Icons.photo_library),
      ),
    );
  }
}
