import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestInitialPermissions() async {
  try {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.audio,
      Permission.storage,
      Permission.notification,
      Permission.microphone,
    ].request();

    if (statuses[Permission.audio]!.isDenied ||
        statuses[Permission.notification]!.isDenied ||
        statuses[Permission.microphone]!.isDenied) {
      log('Permissions were denied by the user.');
    }
  } catch (e) {
    log('Error in requestInitialPermissions: $e');
  }
}
