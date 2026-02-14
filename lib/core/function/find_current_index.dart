import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';

class CurrentSongIndexFinder {
  static Future<void> findAndUpdateCurrentIndex(String songId) async {
    try {
      if (songId.isEmpty) {
        log('No song ID provided');
        return;
      }

      final Songscontroller controller = Get.find();
      final Playlistcontroller playlistController = Get.find();

      int? foundIndex;
      String context = 'unknown';

      // Determine which list to search
      if (controller.isallmusic.isTrue) {
        foundIndex = _findIndexInList(songId, controller.songs);
        context = 'all music';
      } else if (controller.isplaylist.isTrue) {
        // For app playlists
        if (playlistController.currentPlaylistId.value.isNotEmpty) {
          foundIndex = _findIndexInList(
            songId,
            playlistController.currentPlaylistSongs,
          );
          context = 'playlist';
        }
      } else if (controller.isfavorite.isTrue) {
        foundIndex = _findIndexInList(songId, playlistController.favorites);
        context = 'favorites';
      }

      if (foundIndex != null) {
        controller.currentSongPlayingIndex.value = foundIndex;
        log('✅ Found song "$songId" at index $foundIndex in $context');

        // Save to persistent storage
        await _savePlaybackState(
          index: foundIndex,
          songId: songId,
          context: context,
        );

        // Update UI
        playlistController.update();
        controller.update();

        // Also update audio player queue position if needed
        await _syncWithAudioPlayer(foundIndex);
      } else {
        log('⚠️ Song "$songId" not found in current context');
        controller.currentSongPlayingIndex.value = 0;
      }
    } catch (e) {
      log('❌ Error in findCurrentSongPlayingIndex: $e');
      Get.snackbar('Error', 'Failed to find current song position');
    }
  }

  static int? _findIndexInList(String songId, List<dynamic> list) {
    for (int i = 0; i < list.length; i++) {
      try {
        // Handle both MediaItem and Map types
        if (list[i] is MediaItem) {
          if ((list[i] as MediaItem).id == songId) {
            return i;
          }
        } else if (list[i] is Map) {
          if ((list[i] as Map)['id'] == songId) {
            return i;
          }
        } else if (list[i].id == songId) {
          return i;
        }
      } catch (e) {
        continue; // Skip invalid items
      }
    }
    return null;
  }

  static Future<void> _savePlaybackState({
    required int index,
    required String songId,
    required String context,
  }) async {
    AudioPlayer audioPlayer = Get.find<AudioPlayer>();
    var box = Hive.box("music");
    try {
      await box.put("currentIndex", index);
      await box.put("lastPlayedSongId", songId);
      await box.put("lastPlayedContext", context);
      await box.put("lastPosition", audioPlayer.position.inSeconds);

      log(
        '💾 Saved playback state: index=$index, song=$songId, context=$context',
      );
    } catch (e) {
      log('Error saving playback state: $e');
    }
  }

  static Future<void> _syncWithAudioPlayer(int index) async {
    AudioPlayer audioPlayer = Get.find<AudioPlayer>();
    try {
      // Only update if there's a mismatch
      final playerIndex = audioPlayer.currentIndex;
      if (playerIndex != null && playerIndex != index) {
        log('🔄 Syncing: Player index $playerIndex vs Controller index $index');
        // We don't automatically seek because the player might be in a different state
        // This is just for logging
      }
    } catch (e) {
      log('Error syncing with audio player: $e');
    }
  }

  static Future<void> restoreLastPlaybackState() async {
    try {
      var box = Hive.box("music");
      final Songscontroller controller = Get.find();

      // Get saved state
      final lastSongId = box.get("lastPlayedSongId") as String?;
      final lastIndex = box.get("currentIndex") as int? ?? 0;
      final lastContext = box.get("lastPlayedContext") as String?;

      if (lastSongId == null) {
        log('No previous playback state found');
        return;
      }

      log(
        '🔄 Restoring playback state: '
        'song=$lastSongId, index=$lastIndex, context=$lastContext',
      );

      // Set the current index
      controller.currentSongPlayingIndex.value = lastIndex;

      // If we're in the same context, we could potentially resume
      // This would require more complex logic to match the current context
    } catch (e) {
      log('Error restoring playback state: $e');
    }
  }

  static Future<void> findCurrentSongPlayingIndex(String songId) async {
    // Backward compatibility wrapper
    await findAndUpdateCurrentIndex(songId);
  }
}

// For backward compatibility
void findCurrentSongPlayingIndex(String songId) {
  CurrentSongIndexFinder.findCurrentSongPlayingIndex(songId);
}
