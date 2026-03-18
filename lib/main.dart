import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MotivationApp());

class MotivationApp extends StatelessWidget {
  const MotivationApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
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

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appRoot = appDocDir.parent.path;
    final String targetPath = '$appRoot/files/motivation.jpg';
    final File savedImage = File(targetPath);

    if (!await savedImage.parent.exists()) {
      await savedImage.parent.create(recursive: true);
    }

    await File(pickedFile.path).copy(savedImage.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('image_path', savedImage.path);

    await FileImage(savedImage).evict();
    setState(() {
      _image = savedImage;
      _imageVersion++;
    });

    try {
      await platform.invokeMethod('updateWidget');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home Screen Widget Updated!')),
        );
      }
    } catch (e) {
      debugPrint("Native error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Modern Deep Navy
      appBar: AppBar(
        title: Text(
          'AuraFrame',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Add a simple dialog about how to add the widget
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatusHeader(),
            const SizedBox(height: 40),
            _buildImagePreview(),
            const SizedBox(height: 20),
            // const Spacer(),
            _buildInstructionCard(),
            // const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Update Wall Image', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.tealAccent.shade400, size: 20),
          const SizedBox(width: 12),
          const Text(
            "Your Motivation Wall is active",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          height: 380,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.tealAccent.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _image != null
                ? Image.file(
                    _image!,
                    key: ValueKey(_imageVersion),
                    fit: BoxFit.cover,
                  )
                : Container(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.05),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text("No Image Selected", 
                          style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "WIDGET PREVIEW",
          style: GoogleFonts.poppins(
            fontSize: 12, 
            letterSpacing: 2, 
            color: Colors.tealAccent.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Tip: Long-press your home screen to add the 'AuraFrame' widget.",
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}