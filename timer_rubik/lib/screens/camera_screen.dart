import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium, // Cambiado a medium para mejor rendimiento
    );
    await _cameraController?.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final XFile file = await _cameraController!.takePicture();
    setState(() {
      _imagePath = file.path;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cámara'),
      ),
      body: SingleChildScrollView( // Añadido para evitar overflow
        child: Column(
          children: [
            if (_cameraController != null && _cameraController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _takePicture,
                child: const Text('Tomar Foto'),
              ),
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(
                  File(_imagePath!),
                  height: 200, // Altura fija para la imagen
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}