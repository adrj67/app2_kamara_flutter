import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:gallery_saver_plus/gallery_saver.dart';

import 'screens/viewer_fullscreen/viewer_fullscreen.dart';

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

  List<String> imagenesGuardadas = [];

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
        imagenesGuardadas.add(lastImageFile.path); // la agregamos a la lista
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
      // Guardado en GALERÍA (solo si la imagen proviene de la CÁMARA)
      // -------------------------------------------------------

       if (source == ImageSource.camera) {
          final bool? result = await GallerySaver.saveImage(pickedFile.path);

          if (result == true) {
            _showMessage("Imagen guardada en la galería");
          } else {
            _showMessage("No se pudo guardar en la galería");
          }
        }

      setState(() {
        imagenesGuardadas.add(internalCopy.path);
      });
    } catch (e) {
      setState(() {
        _showMessage("Error: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: imagenesGuardadas.isEmpty
          ? const Center(child: Text("No hay imágenes"))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: imagenesGuardadas.length,
              itemBuilder: (context, index) {
                final imagePath = imagenesGuardadas[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewerFullScreen(
                          imagePaths: imagenesGuardadas,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: imagePath,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
      
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            heroTag: "galeriaBtn",
            onPressed: () => _onImageButtonPressed(ImageSource.gallery),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.green,
            heroTag: "camaraBtn",
            onPressed: () => _onImageButtonPressed(ImageSource.camera),
            child: const Icon(Icons.photo_camera),
          ),
        ],
      ),
    );
  }
}
