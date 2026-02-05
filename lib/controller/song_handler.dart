import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/function/find_current_index.dart';

import 'package:musiclotm/main.dart';

class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // Get controllers lazily
  AnimationControllerX get animationController =>
      Get.find<AnimationControllerX>();
  Songscontroller get songscontroller => Get.find<Songscontroller>();
  Playlistcontroller get playlistcontroller => Get.find<Playlistcontroller>();
  Navigatorcontroller get navigatorcontroller =>
      Get.find<Navigatorcontroller>();
  Searchcontroller get searchController => Get.find<Searchcontroller>();
  VisualizerController get visualizerController =>
      Get.find<VisualizerController>();

  // Use main.dart audioPlayer

  RxBool isloop = false.obs;
  RxBool isShuffel = false.obs;
  late List<UriAudioSource> songSources;
  late List<MediaItem> _currentQueue;

  // Stream subscriptions
  StreamSubscription<PlaybackEvent>? _playbackSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  Stream<int?> get sessionIdStream => audioPlayer.androidAudioSessionIdStream;
  int? get sessionId => audioPlayer.androidAudioSessionId;

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

      // Update the current song index in controllers
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await CurrentSongIndexFinder.findAndUpdateCurrentIndex(currentMediaItem.id);
          
          // Update visualizer session
          if (sessionId != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              visualizerController.updateSessionId(sessionId!);
            });
          }
        } catch (e) {
          log('Error updating current song index: $e');
        }
      });
    }
  });
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

  Future<void> initSongs({required List<MediaItem> songs}) async {
    log('Initializing ${songs.length} songs');

    if (songs.isEmpty) {
      log('No songs to initialize');
      return;
    }

    await _cancelSubscriptions();

    _currentQueue = List.from(songs);
    songSources = songs.map(_createAudioSource).toList();

    

    try {
      await audioPlayer.setAudioSources(songSources);
      log('Audio source set successfully');
    } catch (error) {
      log('Error setting audio source: $error');
      return;
    }

    queue.value = _currentQueue;

    _playbackSubscription = audioPlayer.playbackEventStream.listen(
      _broadcastState,
    );
    _listenForCurrentSongIndexChanges();

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

  Future<void> _applyCurrentRepeatAndShuffleModes() async {
    LoopMode loopMode = isloop.isTrue ? LoopMode.one : LoopMode.all;
    await audioPlayer.setLoopMode(loopMode);
    await audioPlayer.setShuffleModeEnabled(isShuffel.value);
  }

  @override
  Future<void> play() async {
    try {
      playlistcontroller.update();

      await audioPlayer.play();
    } catch (e) {
      log('Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      playlistcontroller.update();
      await audioPlayer.pause();
    } catch (e) {
      log('Error pausing: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _currentQueue.length) {
      log('Invalid index: $index');
      return;
    }

    try {
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
  }

  Future<void> toggleLoop() async {
    isloop.value = !isloop.value;
    await _applyCurrentRepeatAndShuffleModes();

    String message = isloop.value ? "Loop ON" : "Loop OFF";
    Get.snackbar("Loop Mode", message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> toggleShuffle() async {
    isShuffel.value = !isShuffel.value;
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

    if (audioPlayer.hasNext) {
      await audioPlayer.seekToNext();
    } else if (isloop.value) {
      // Loop back to beginning
      await skipToQueueItem(0);
    } else {
      // No next song and loop is off - stop or pause
      await audioPlayer.pause();
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.completed,
        playing: false,
      ));
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

    // If less than 3 seconds into the song, go to previous song
    // Otherwise, restart current song
    if (audioPlayer.position.inSeconds > 3) {
      await audioPlayer.seek(Duration.zero);
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
      await audioPlayer.seekToNext();
    } catch (e) {
      log('Error skipping to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
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

  _playbackSubscription = null;
  _currentIndexSubscription = null;
  _processingStateSubscription = null;
  _durationSubscription = null;
}

  @override
  Future<void> stop() async {
    await _cancelSubscriptions();
    await audioPlayer.stop();
    return super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await _cancelSubscriptions();
    await audioPlayer.stop();
    return super.onTaskRemoved();
  }

  Future<void> updatequeue(List<MediaItem> newSongs) async {
    if (newSongs.isEmpty) return;

    _currentQueue = List.from(newSongs);
    final newSources = newSongs.map(_createAudioSource).toList();

    final currentPosition = audioPlayer.position;
    final wasPlaying = audioPlayer.playing;
    final currentIndex = audioPlayer.currentIndex;

    try {
      
      await audioPlayer.setAudioSources(newSources);

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
}
