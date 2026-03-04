import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

// This is seen by the compiler on all platforms to prevent "Method not found"
dynamic getWebSettings(BuildContext context) {
  // We only return settings if we are actually on Web
  return WebUiSettings(
    context: context,
    size: const CropperSize(width: 512, height: 512),
  );
}