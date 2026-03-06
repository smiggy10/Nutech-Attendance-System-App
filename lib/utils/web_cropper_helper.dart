import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

// Basic web settings optimized for Chrome compatibility
WebUiSettings getWebSettings(BuildContext context) {
  return WebUiSettings(
    context: context,
    size: const CropperSize(width: 512, height: 512),
    // Basic settings for Chrome compatibility - using compatible enum
    dragMode: WebDragMode.move,
    // Set background to transparent for better Chrome compatibility
    background: true,
    // Enable guides for better cropping experience
    guides: true,
    center: true,
    highlight: true,
    cropBoxMovable: true,
    cropBoxResizable: true,
    // Additional settings for better web experience
    movable: true,
    rotatable: true,
    scalable: true,
    zoomable: true,
  );
}

// Debug helper for web cropping issues
void debugWebCropper() {
  if (kIsWeb) {
    debugPrint('Web cropper initialized with Chrome-optimized settings');
    debugPrint('DragMode: move, Background: true, Guides: true');
  }
}
