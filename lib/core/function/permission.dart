// permission.dart - Update with better handling

import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestInitialPermissions() async {
  try {
    final List<Permission> permissions = [];

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // 1. Storage/Audio logic
      if (sdkInt >= 33) {
        // Android 13+ uses granular permissions
        permissions.add(Permission.audio);
        permissions.add(Permission.notification); // Required for API 33+
      } else {
        // Android 12 and below use standard storage
        permissions.add(Permission.storage);
      }
    }

    // 2. Always request microphone for the visualizer
    permissions.add(Permission.microphone);

    // Request everything in the list
    final Map<Permission, PermissionStatus> statuses = await permissions
        .request();

    // 3. Validation Logic
    bool isAudioOk = false;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        isAudioOk = statuses[Permission.audio]?.isGranted ?? false;
      } else {
        isAudioOk = statuses[Permission.storage]?.isGranted ?? false;
      }
    }

    log('Permissions granted: $isAudioOk');
    return isAudioOk;
  } catch (e) {
    log('Error in requestInitialPermissions: $e');
    return false;
  }
}

// Helper function to check if permissions are permanently denied
Future<bool> arePermissionsPermanentlyDenied() async {
  final permissions = [
    Permission.audio,
    Permission.mediaLibrary,
    Permission.storage,
  ];

  for (var permission in permissions) {
    final status = await permission.status;
    if (status.isPermanentlyDenied) {
      return true;
    }
  }
  return false;
}
