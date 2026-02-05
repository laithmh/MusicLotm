// permission.dart - Update with better handling

import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

Future<bool> requestInitialPermissions() async {
  try {
    // For Android 13+ we need READ_MEDIA_AUDIO instead of storage
    // For older versions, we need storage permission
    final List<Permission> permissions = [];
    
    // Always request audio permission
    permissions.add(Permission.audio);
    
    // For Android 13+ (SDK 33+)
    if (await Permission.mediaLibrary.isGranted == false) {
      permissions.add(Permission.mediaLibrary);
    }
    
    // For Android 12 and below
    if (await Permission.storage.isGranted == false) {
      permissions.add(Permission.storage);
    }
    
    // Optional permissions
    permissions.add(Permission.notification);
    permissions.add(Permission.microphone);
    
    final Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    // Check if we have the essential permissions
    bool hasAudioPermission = statuses[Permission.audio]?.isGranted ?? false;
    bool hasMediaLibraryPermission = statuses[Permission.mediaLibrary]?.isGranted ?? false;
    bool hasStoragePermission = statuses[Permission.storage]?.isGranted ?? false;
    
    // We need either media library (Android 13+) or storage (older)
    bool hasEssentialPermission = hasAudioPermission && 
                                  (hasMediaLibraryPermission || hasStoragePermission);
    
    log('Permission status: Audio: $hasAudioPermission, '
        'MediaLibrary: $hasMediaLibraryPermission, '
        'Storage: $hasStoragePermission');
    
    return hasEssentialPermission;
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