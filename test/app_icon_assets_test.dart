import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('official Picnic source icon is copied to the iOS marketing icon', () {
    final sourceBytes = File(
      'assets/branding/picnic-logo-1024.png',
    ).readAsBytesSync();
    final iosMarketingBytes = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    ).readAsBytesSync();

    expect(_readPngDimensions(sourceBytes), (width: 1024, height: 1024));
    expect(iosMarketingBytes, sourceBytes);
  });

  test('generated launcher icons keep the expected platform dimensions', () {
    const expectedDimensions = <String, ({int width, int height})>{
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': (
        width: 20,
        height: 20,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': (
        width: 40,
        height: 40,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': (
        width: 60,
        height: 60,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': (
        width: 29,
        height: 29,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': (
        width: 58,
        height: 58,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': (
        width: 87,
        height: 87,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': (
        width: 40,
        height: 40,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': (
        width: 80,
        height: 80,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': (
        width: 120,
        height: 120,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': (
        width: 120,
        height: 120,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': (
        width: 180,
        height: 180,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': (
        width: 76,
        height: 76,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': (
        width: 152,
        height: 152,
      ),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png':
          (width: 167, height: 167),
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png':
          (width: 1024, height: 1024),
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': (
        width: 48,
        height: 48,
      ),
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': (
        width: 72,
        height: 72,
      ),
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': (
        width: 96,
        height: 96,
      ),
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': (
        width: 144,
        height: 144,
      ),
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': (
        width: 192,
        height: 192,
      ),
    };

    for (final entry in expectedDimensions.entries) {
      final iconFile = File(entry.key);

      expect(
        iconFile.existsSync(),
        isTrue,
        reason: '${entry.key} should exist',
      );
      expect(_readPngDimensions(iconFile.readAsBytesSync()), entry.value);
    }
  });
}

({int width, int height}) _readPngDimensions(List<int> bytes) {
  final data = Uint8List.fromList(bytes);
  final signature = data.sublist(0, 8);

  expect(signature, <int>[
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
  ], reason: 'Expected a PNG file header');

  final dimensions = ByteData.sublistView(data, 16, 24);
  return (width: dimensions.getUint32(0), height: dimensions.getUint32(4));
}
