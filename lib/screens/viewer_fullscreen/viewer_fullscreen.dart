import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

class ViewerFullScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ViewerFullScreen({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<ViewerFullScreen> createState() => _ViewerFullScreenState();
}

class _ViewerFullScreenState extends State<ViewerFullScreen> {
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Viewer con zoom + swipe
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imagePaths.length,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            builder: (context, index) {
              final path = widget.imagePaths[index];

              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(path)),
                heroAttributes: PhotoViewHeroAttributes(tag: path),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
          ),

          // Botón para cerrar
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.amber, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
