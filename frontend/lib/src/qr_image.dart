import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'widget.dart';

/// Descriptor of a [QrImage]
///
/// ### JSON Attributes
///  - *data*: Data of the QR code - REQUIRED
///  - *version*: QR Code version
///  - *size*: Size of the qr-code
///  - *padding*: Padding surrounding the QR code data. Default: 0
///  - *embeddedImageUrl*: URL of the embeded image
///  - *embeddedImageSize*: Size of the embeded image
class SDUIQrImage extends SDUIWidget {
  String? data;
  int? version;
  double? size;
  double? padding;
  String? embeddedImageUrl;
  double? embeddedImageSize;

  @override
  Widget toWidget(BuildContext context) => const Text('It should show an widget from qr');

  @override
  SDUIWidget fromJson(Map<String, dynamic>? json) {
    data = json?["data"];
    version = json?["version"];
    size = json?["size"];
    padding = json?["padding"];
    embeddedImageUrl = json?["embeddedImageUrl"];
    embeddedImageSize = json?["embeddedImageSize"];
    return super.fromJson(json);
  }
}
