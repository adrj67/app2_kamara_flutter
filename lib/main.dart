import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

//import 'package:gallery_saver_plus/files.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

/*
LISTA REPRODUCCION
https://www.youtube.com/playlist?list=PLkVpKYNT_U9frI8-qia9vN3k-V7huavBB

37) https://www.youtube.com/watch?v=oCxrnKKWzpI&list=PLkVpKYNT_U9frI8-qia9vN3k-V7huavBB&index=49 - Gridview y gesturedetector
38) https://www.youtube.com/watch?v=whn1w-L5X4M&list=PLkVpKYNT_U9frI8-qia9vN3k-V7huavBB&index=50 - Camara
      - https://pub.dev/packages/image_picker - instalar paquete
39) https://www.youtube.com/watch?v=rBpTU6BLhk0&list=PLkVpKYNT_U9frI8-qia9vN3k-V7huavBB&index=51 - GPS

*/

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
  File? _savedImage;
  String? _pickImageError;

  @override
  void initState() {
    super.initState();
    _loadLastSavedImage();
  }

  /// -----------------------------------------------------------
  /// Carga la última imagen guardada localmente
  /// -----------------------------------------------------------
  Future<void> _loadLastSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final lastImageFile = File('${directory.path}/ultima_imagen.jpg');

    if (await lastImageFile.exists()) {
      setState(() {
        _savedImage = lastImageFile;
      });
    }
  }

  /// -----------------------------------------------------------
  /// Toma una foto desde cámara o galería + guarda internamente
  /// y también en la galería del dispositivo.
  /// -----------------------------------------------------------
  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final internalCopy = File('${directory.path}/$fileName');

      // Guardado interno
      await File(pickedFile.path).copy(internalCopy.path);

      // Guardar como "última imagen"
      await File(pickedFile.path)
          .copy('${directory.path}/ultima_imagen.jpg');

      // -------------------------------------------------------
      // Guardado en GALERÍA
      // -------------------------------------------------------
      final bool? result = await GallerySaver.saveImage(pickedFile.path);
      /* final bool? result = await GallerySaver.saveImage(
        pickedFile.path,
        name: "kamera_${DateTime.now().millisecondsSinceEpoch}",
      );
      */
      if (result == true) {
        _showMessage("Imagen guardada en la galería");
      } else {
        _showMessage("No se pudo guardar en la galería");
      }

      setState(() {
        _imageFile = pickedFile;
        _savedImage = internalCopy;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e.toString();
      });
    }
  }

  /// -----------------------------------------------------------
  /// Mensaje en pantalla
  /// -----------------------------------------------------------
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  /// -----------------------------------------------------------
  /// Widget para ver imagen
  /// -----------------------------------------------------------
  Widget _visualizarImagen() {
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path));
    }

    if (_savedImage != null) {
      return Image.file(_savedImage!);
    }

    if (_pickImageError != null) {
      return Center(child: Text("Error: $_pickImageError"));
    }

    return const Center(child: Text("No hay imagen"));
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
