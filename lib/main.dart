import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// ignore: unused_import
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
          seedColor: Colors.tealAccent,
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

  int? _selectedId;
  List<int> _activeWidgetIds = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _refreshWidgetIds();
    if (_selectedId != null) {
      await _loadSavedImageForId(_selectedId!);
    }
  }

  Future<void> _loadSavedImageForId(int id) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = '${appDocDir.path}/widget_images/motivation_$id.jpg';
    final file = File(path);
    if (await file.exists()) {
      setState(() {
        _image = file;
        _imageVersion++;
      });
    } else {
      setState(() => _image = null);
    }
  }

  Future<void> _refreshWidgetIds() async {
    try {
      final List<dynamic>? ids = await platform.invokeMethod(
        'getActiveWidgetIds',
      );
      if (ids != null && ids.isNotEmpty) {
        setState(() {
          _activeWidgetIds = ids.cast<int>();
          if (_selectedId == null || !_activeWidgetIds.contains(_selectedId)) {
            _selectedId = _activeWidgetIds.first;
          }
        });
        await _loadSavedImageForId(_selectedId!);
      }
    } catch (e) {
      debugPrint("Error fetching IDs: $e");
    }
  }

  Future<void> _pickImage() async {
    if (_selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a widget to your home screen first!'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String targetPath = '${appDocDir.path}/widget_images';
      final Directory savedDir = Directory(targetPath);

      if (!await savedDir.exists()) await savedDir.create(recursive: true);

      await File(
        pickedFile.path,
      ).copy('${savedDir.path}/motivation_$_selectedId.jpg');

      setState(() {
        _image = File(pickedFile.path);
        _imageVersion++;
      });

      await platform.invokeMethod('updateWidget');
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'AuraFrame',
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  title: const Text('About AuraFrame'),
                  content: const Text(
                    'AuraFrame is a Flutter-based app that allows you to set custom images for your home screen widgets. Select a widget ID from the dropdown, pick an image, and see it update in real-time on your home screen!',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Aesthetic Blobs
          Positioned(
            top: -100,
            right: -50,
            // ignore: deprecated_member_use
            child: _buildBlurCircle(Colors.teal.withOpacity(0.15), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            // ignore: deprecated_member_use
            child: _buildBlurCircle(Colors.blueAccent.withOpacity(0.1), 250),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildStatusHeader(),
                  const SizedBox(height: 20),
                  _buildMainConsole(),
                  const SizedBox(height: 20),
                  _buildInstructionCard(),
                  const SizedBox(height: 100), // Padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        backgroundColor: Colors.tealAccent.shade700,
        icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
        label: const Text(
          "UPDATE SELECTED FRAME",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      // ignore: unnecessary_null_comparison
      child: BackdropFilter(
        filter:
            // ignore: unnecessary_null_comparison
            SystemMouseCursors.basic != null
                ? ColorFilter.mode(color, BlendMode.srcIn)
                : ColorFilter.mode(color, BlendMode.srcIn),
      ), // Note: Placeholder for actual Blur
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.amber, size: 28),
          const SizedBox(width: 6),
          Text(
            "SYSTEM ACTIVE",
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainConsole() {
    return Column(
      children: [
        // Dropdown Selector with label
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "SELECT TARGET FRAME",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
          ),
        ),
        _buildDropdownSelector(),
        const SizedBox(height: 24),

        // Image Preview Area
        _buildImagePreview(),
      ],
    );
  }

  Widget _buildDropdownSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ), 
        child: _activeWidgetIds.isNotEmpty ?
         DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedId,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.tealAccent,
            ),
            dropdownColor: const Color(0xFF1E293B),
            items:
                _activeWidgetIds
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(
                          "Widget Frame #$id",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedId = val);
                _loadSavedImageForId(val);
              }
            },
          )
      ) : const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No Widgets Detected", style: TextStyle(color: Colors.white, fontSize: 14, ),),),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.tealAccent.withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child:
            _image != null
                ? Image.file(
                  _image!,
                  key: ValueKey(_imageVersion),
                  fit: BoxFit.cover,
                )
                : Container(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 50,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No image linked to this Frame",
                        // ignore: deprecated_member_use
                        style: TextStyle(color: Colors.white.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.tealAccent.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.tealAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            // ignore: deprecated_member_use
            color: Colors.tealAccent.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Switch IDs above to preview different widgets on your home screen.",
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }
}
