import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// flutter_html forces an image to the width given by its width attribute,
// even when that is wider than the screen, so large images are cropped. Image
// itself caps its width to the available space and keeps the aspect ratio.
ImageExtension fittedImageExtension() {
  return ImageExtension(
    handleAssetImages: false,
    handleDataImages: false,
    builder: (extensionContext) {
      final attributes = extensionContext.attributes;
      return Image.network(
        attributes['src']!,
        width: double.tryParse(attributes['width'] ?? ''),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Text(attributes['alt'] ?? ''),
      );
    },
  );
}
