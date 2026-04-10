import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/function/find_current_index.dart';

class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // Get controllers lazily
  Songscontroller get songscontroller => Get.find<Songscontroller>();
  Playlistcontroller get playlistcontroller => Get.find<Playlistcontroller>();
  VisualizerController get visualizerController =>
      Get.find<VisualizerController>();
  AudioPlayer get audioPlayer => Get.find<AudioPlayer>();

  final Box _box = Hive.box("music");
  RxBool isloop = false.obs;
  RxBool isShuffel = false.obs;
  late List<UriAudioSource> songSources;
  late List<MediaItem> _currentQueue;

  // Stream subscriptions
  StreamSubscription<PlaybackEvent>? _playbackSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  Stream<int?> get sessionIdStream => audioPlayer.androidAudioSessionIdStream;
  int? get sessionId => audioPlayer.androidAudioSessionId;

  // Timer for saving position periodically
  Timer? _positionSaveTimer;

  UriAudioSource _createAudioSource(MediaItem item) {
    return AudioSource.uri(Uri.parse(item.id), tag: item);
  }

  void _listenForCurrentSongIndexChanges() {
    _currentIndexSubscription?.cancel();
    _currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      if (index == null || _currentQueue.isEmpty) return;

      if (index >= 0 && index < _currentQueue.length) {
        final currentMediaItem = _currentQueue[index];
        mediaItem.add(currentMediaItem);
        songscontroller.currentMediaItem.value = currentMediaItem;
        // Save current song state
        _saveCurrentSongState(index, audioPlayer.position);

        // Update the current song index in controllers
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await CurrentSongIndexFinder.findAndUpdateCurrentIndex(
              currentMediaItem.id,
            );

            // Update visualizer session
            if (sessionId != null) {
              visualizerController.updateSessionId(
                sessionId!,
              ); // ✅ IMMEDIATE connection
            }
          } catch (e) {
            log('Error updating current song index: $e');
          }
        });
      }
    });
  }

  /// Save current song position periodically
  void _startPositionSaving() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      final currentIndex = audioPlayer.currentIndex;
      if (currentIndex != null && _currentQueue.isNotEmpty) {
        _saveCurrentPosition(audioPlayer.position);
      }
    });
  }

  /// Save current song state (index and position)
  void _saveCurrentSongState(int index, Duration position) {
    _box.put("lastSongId", _currentQueue[index].id);
    _box.put("lastIndex", index);
    _box.put("lastPosition", position.inMilliseconds);
    _box.put("lastSaveTime", DateTime.now().millisecondsSinceEpoch);

    // Also save queue information if needed
    _box.put("lastQueueLength", _currentQueue.length);
  }

  /// Save just the position
  void _saveCurrentPosition(Duration position) {
    _box.put("lastPosition", position.inMilliseconds);
    _box.put("lastSaveTime", DateTime.now().millisecondsSinceEpoch);
  }

  /// Load saved player state
  Map<String, dynamic> _loadSavedState() {
    return {
      'lastIndex': _box.get("lastIndex", defaultValue: 0),
      'lastPosition': _box.get("lastPosition", defaultValue: 0),
      'lastSongId': _box.get("lastSongId", defaultValue: ''),
      'isLooping': _box.get("isLooping", defaultValue: false),
      'isShuffling': _box.get("isShuffling", defaultValue: false),
    };
  }

  /// Find the correct index for saved song in current queue
  int _findSavedSongIndex(List<MediaItem> songs, String savedSongId) {
    if (savedSongId.isEmpty) return 0;

    for (int i = 0; i < songs.length; i++) {
      if (songs[i].id == savedSongId) {
        return i;
      }
    }
    return 0; // Fallback to first song if not found
  }

  void _broadcastState(PlaybackEvent event) {
    final controls = [
      MediaControl.skipToPrevious,
      if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];

    final systemActions = {
      MediaAction.seek,
      MediaAction.seekForward,
      MediaAction.seekBackward,
    };

    final processingState = const {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[audioPlayer.processingState];

    if (processingState != null) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: controls,
          systemActions: systemActions,
          processingState: processingState,
          playing: audioPlayer.playing,
          updatePosition: audioPlayer.position,
          bufferedPosition: audioPlayer.bufferedPosition,
          speed: audioPlayer.speed,
          queueIndex: event.currentIndex,
        ),
      );
    }
  }

  Future<void> initSongs({
    required List<MediaItem> songs,
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
    bool restoreState = true,
  }) async {
    log('Initializing ${songs.length} songs');

    if (songs.isEmpty) {
      log('No songs to initialize');
      return;
    }

    await _cancelSubscriptions();
    _positionSaveTimer?.cancel();

    _currentQueue = List.from(songs);

    // Load saved state if restoring
    final savedState = _loadSavedState();
    isloop.value = savedState['isLooping'];
    isShuffel.value = savedState['isShuffling'];

    // Determine initial index and position
    int actualInitialIndex = initialIndex;
    Duration actualInitialPosition = initialPosition;

    if (restoreState) {
      final savedSongId = savedState['lastSongId'];
      if (savedSongId.isNotEmpty) {
        actualInitialIndex = _findSavedSongIndex(songs, savedSongId);

        // Only restore position if we're resuming the same song
        if (actualInitialIndex < songs.length &&
            songs[actualInitialIndex].id == savedSongId) {
          final savedPosMs = savedState['lastPosition'];
          actualInitialPosition = Duration(milliseconds: savedPosMs);

          // If position is too far (e.g., near end), start from beginning
          final songDuration = await _getEstimatedDuration(
            songs[actualInitialIndex],
          );
          if (songDuration != null &&
              actualInitialPosition.inSeconds > songDuration.inSeconds - 10) {
            actualInitialPosition = Duration.zero;
          }
        } else {
          actualInitialPosition = Duration.zero;
        }
      }
    }

    songSources = songs.map(_createAudioSource).toList();

    try {
      await audioPlayer.setAudioSources(
        songSources,
        initialIndex: actualInitialIndex,
        initialPosition: actualInitialPosition,
      );
      final initialMediaItem = _currentQueue[actualInitialIndex];
      songscontroller.currentMediaItem.value = initialMediaItem;
      log(
        'Audio source set successfully at index: $actualInitialIndex, position: $actualInitialPosition',
      );
    } catch (error) {
      log('Error setting audio source: $error');
      return;
    }

    queue.value = _currentQueue;

    _playbackSubscription = audioPlayer.playbackEventStream.listen(
      _broadcastState,
    );
    _listenForCurrentSongIndexChanges();

    // Start position saving timer
    _startPositionSaving();

    _processingStateSubscription = audioPlayer.processingStateStream.listen((
      state,
    ) {
      log('Processing state: $state');
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });

    await _applyCurrentRepeatAndShuffleModes();
  }

  /// Estimate duration for a media item (you might need to adjust this)
  Future<Duration?> _getEstimatedDuration(MediaItem item) async {
    try {
      // You might need to implement actual duration fetching
      // For now, return null and handle in initSongs
      return null;
    } catch (e) {
      log('Error estimating duration: $e');
      return null;
    }
  }

  Future<void> _applyCurrentRepeatAndShuffleModes() async {
    LoopMode loopMode = isloop.isTrue ? LoopMode.one : LoopMode.all;
    await audioPlayer.setLoopMode(loopMode);
    await audioPlayer.setShuffleModeEnabled(isShuffel.value);

    // Save current modes
    _box.put("isLooping", isloop.value);
    _box.put("isShuffling", isShuffel.value);
  }

  @override
  Future<void> play() async {
    try {
      playlistcontroller.update();
      await audioPlayer.play();
      _saveCurrentPosition(audioPlayer.position);
    } catch (e) {
      log('Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      playlistcontroller.update();
      await audioPlayer.pause();
      _saveCurrentPosition(audioPlayer.position);
    } catch (e) {
      log('Error pausing: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
    _saveCurrentPosition(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _currentQueue.length) {
      log('Invalid index: $index');
      return;
    }

    try {
      // Save current position before changing
      _saveCurrentPosition(audioPlayer.position);

      await audioPlayer.seek(Duration.zero, index: index);
      playlistcontroller.update();
    } catch (e) {
      log('Error skipping to queue item: $e');
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await super.setRepeatMode(repeatMode);
    LoopMode loopMode = LoopMode.all;
    switch (repeatMode) {
      case AudioServiceRepeatMode.all:
        loopMode = LoopMode.all;
        break;
      case AudioServiceRepeatMode.none:
        loopMode = LoopMode.off;
        break;
      case AudioServiceRepeatMode.one:
        loopMode = LoopMode.one;
        break;
      case AudioServiceRepeatMode.group:
        loopMode = LoopMode.all;
        break;
    }
    await audioPlayer.setLoopMode(loopMode);

    // Update and save loop state
    isloop.value = loopMode == LoopMode.one;
    _box.put("isLooping", isloop.value);
  }

  Future<void> toggleLoop() async {
    isloop.value = !isloop.value;
    _box.put("isLooping", isloop.value); // PERSIST
    await _applyCurrentRepeatAndShuffleModes();

    String message = isloop.value ? "Loop ON" : "Loop OFF";
    Get.snackbar("Loop Mode", message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> toggleShuffle() async {
    isShuffel.value = !isShuffel.value;
    _box.put("isShuffling", isShuffel.value); // PERSIST
    await audioPlayer.setShuffleModeEnabled(isShuffel.value);

    if (isShuffel.value) {
      await audioPlayer.shuffle();
      Get.snackbar(
        "Shuffle",
        "Shuffle ON",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Shuffle",
        "Shuffle OFF",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> handlePlayBackNext() async {
    try {
      // Check if player is ready
      if (audioPlayer.processingState != ProcessingState.ready) {
        return;
      }

      // Save current position
      _saveCurrentPosition(audioPlayer.position);

      if (isloop.isFalse) {
        await audioPlayer.seekToNext();
      } else if (isloop.isTrue && _currentQueue.isNotEmpty) {
        int currentIndex = audioPlayer.currentIndex ?? 0;
        int nextIndex = currentIndex > 0
            ? currentIndex + 1
            : _currentQueue.length + 1;
        await skipToQueueItem(nextIndex);
      } else {
        log("No next song and loop is off - stop or pause ${isloop.value}");
        await audioPlayer.pause();
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.completed,
            playing: false,
          ),
        );
      }
    } catch (e) {
      log('Error in handlePlayBackNext: $e');
    }
  }

  Future<void> handlePlayBackPrevious() async {
    try {
      if (audioPlayer.processingState != ProcessingState.ready) {
        return;
      }

      // Save current position
      _saveCurrentPosition(audioPlayer.position);

      // If less than 3 seconds into the song, go to previous song
      // Otherwise, restart current song
      if (audioPlayer.position.inSeconds > 3) {
        await audioPlayer.seek(Duration.zero);
        _saveCurrentPosition(Duration.zero);
      } else {
        if (isloop.value && _currentQueue.isNotEmpty) {
          int currentIndex = audioPlayer.currentIndex ?? 0;
          int previousIndex = currentIndex > 0
              ? currentIndex - 1
              : _currentQueue.length - 1;
          await skipToQueueItem(previousIndex);
        } else {
          await skipToPrevious();
        }
      }
    } catch (e) {
      log('Error in handlePlayBackPrevious: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      _saveCurrentPosition(audioPlayer.position);
      await audioPlayer.seekToNext();
    } catch (e) {
      log('Error skipping to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      _saveCurrentPosition(audioPlayer.position);
      await audioPlayer.seekToPrevious();
    } catch (e) {
      log('Error skipping to previous: $e');
    }
  }

  Future<void> _cancelSubscriptions() async {
    _playbackSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _positionSaveTimer?.cancel();

    _playbackSubscription = null;
    _currentIndexSubscription = null;
    _processingStateSubscription = null;
    _durationSubscription = null;
    _positionSubscription = null;
    _positionSaveTimer = null;
  }

  @override
  Future<void> stop() async {
    // Save final position before stopping
    _saveCurrentPosition(audioPlayer.position);
    await _cancelSubscriptions();
    await audioPlayer.stop();
    return super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    // Save final position before task is removed
    _saveCurrentPosition(audioPlayer.position);
    await _cancelSubscriptions();
    await audioPlayer.stop();
    return super.onTaskRemoved();
  }

  Future<void> updatequeue(List<MediaItem> newSongs) async {
    if (newSongs.isEmpty) return;

    // Save current state before updating
    final currentPosition = audioPlayer.position;
    final currentIndex = audioPlayer.currentIndex;

    _saveCurrentSongState(currentIndex ?? 0, currentPosition);

    _currentQueue = List.from(newSongs);
    final newSources = newSongs.map(_createAudioSource).toList();

    final wasPlaying = audioPlayer.playing;

    try {
      await audioPlayer.setAudioSources(newSources);

      // Try to restore to same position if possible
      if (currentIndex != null && currentIndex < newSongs.length) {
        await audioPlayer.seek(currentPosition, index: currentIndex);
      }

      if (wasPlaying) {
        await audioPlayer.play();
      }

      queue.value = _currentQueue;
    } catch (e) {
      log('Error updating queue: $e');
    }
  }

  /// Clear all saved player state
  Future<void> clearSavedState() async {
    _box.delete("lastSongId");
    _box.delete("lastIndex");
    _box.delete("lastPosition");
    _box.delete("lastSaveTime");
    _box.delete("lastQueueLength");
  }

  /// Get current player state for debugging
  Map<String, dynamic> getCurrentState() {
    return {
      'currentIndex': audioPlayer.currentIndex,
      'currentPosition': audioPlayer.position.inMilliseconds,
      'isPlaying': audioPlayer.playing,
      'isLooping': isloop.value,
      'isShuffling': isShuffel.value,
      'queueLength': _currentQueue.length,
      'savedState': _loadSavedState(),
    };
  }
}
