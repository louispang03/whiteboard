// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';  // Import screenshot package
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Image Editor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScreenshotController screenshotController = ScreenshotController();  // Screenshot controller
  bool _isButtonVisible = true;  // Control button visibility

  // Capture the screen
  Future<void> captureScreen() async {
    setState(() {
      _isButtonVisible = false;  // Hide the button when capture starts
    });

    // Capture screenshot and get the image in Uint8List format
    final image = await screenshotController.capture();
    if (image != null && mounted) {
      // If the capture is successful, navigate to the editor screen with the captured image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(image: image),  // Pass the captured image
        ),
      ).then((_) {
        // Once the user returns from the ImageEditorScreen, show the button again
        setState(() {
          _isButtonVisible = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Screenshot(  // Wrap the widget tree with Screenshot widget
        controller: screenshotController,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Press the button to capture the screen and edit the image.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button positioned at bottom-right
      floatingActionButton: _isButtonVisible
          ? FloatingActionButton(
              onPressed: captureScreen,  // Trigger screenshot capture and edit
              child: const Icon(Icons.brush),
            )
          : null,  // Button will disappear after being clicked
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,  // Position the button at the bottom-right
    );
  }
}

class ImageEditorScreen extends StatelessWidget {
  final Uint8List image;  // The captured screen image

  const ImageEditorScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Captured Image'),
      ),
      body: ProImageEditor.memory(
        image,  // Pass the captured image to ProImageEditor
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            // Save the edited image to the gallery
            await saveImageToGallery(bytes, context);
            Navigator.pop(context);  // Return to the previous screen
          },
        ),
      ),
    );
  }

  // Function to save the image to the gallery
  Future<void> saveImageToGallery(Uint8List imageBytes, BuildContext context) async {
    final result = await ImageGallerySaver.saveImage(imageBytes, quality: 60, name: "edited_image");
    if (result != null && result["isSuccess"]) {
      // If the image was saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image saved to gallery!")),
      );
    } else {
      // If there was an error saving the image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save image!")),
      );
    }
  }
}
