import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2 Kamera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Kamera App - 2'),
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

  XFile? _imageFile;
  dynamic _pickImageError;
  File? _savedImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImagePath = File('${directory.path}/ultima_imagen.jpg');

    if (await savedImagePath.exists()) {
      setState(() {
        _savedImage = savedImagePath;
      });
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final savedImage = File('${directory.path}/$fileName');

        // Guardar la imagen en carpeta interna
        await File(pickedFile.path).copy(savedImage.path);

        // También guardamos una copia con nombre fijo para recargar más fácil
        await File(pickedFile.path).copy('${directory.path}/ultima_imagen.jpg');

        setState(() {
          _imageFile = pickedFile;
          _savedImage = savedImage;
        });
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Widget _visualizarImagen() {
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path));
    } else if (_savedImage != null) {
      return Image.file(_savedImage!);
    } else if (_pickImageError != null) {
      return Center(
        child: Text('Error al recuperar imagen: $_pickImageError'),
      );
    } else {
      return const Center(
        child: Text('No hay imagen'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _visualizarImagen(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () => _onImageButtonPressed(ImageSource.gallery),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () => _onImageButtonPressed(ImageSource.camera),
            child: const Icon(Icons.photo_camera),
          ),
        ],
      ),
    );
  }
}
