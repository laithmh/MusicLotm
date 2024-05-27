import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/function/generaterandomnumber.dart';

class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  AnimationControllerX animationController = Get.put(AnimationControllerX());

  Songscontroller songscontroller = Get.put(Songscontroller());
  Playlistcontroller playlistcontroller = Get.put(Playlistcontroller());
  Navigatorcontroller navigatorcontroller = Get.put(Navigatorcontroller());

  GenerateRandomNumbers generateRandomNumbers =
      Get.put(GenerateRandomNumbers());
  Searchcontroller searchController = Get.put(Searchcontroller());
  final AudioPlayer audioPlayer = AudioPlayer();
  RxBool isloop = false.obs;
  late List<UriAudioSource> song;
  UriAudioSource _createAudioSource(MediaItem item) {
    return ProgressiveAudioSource(Uri.parse(item.id));
  }

  void _listenForCurrentSongIndexChanges() {
    audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(playlist[index]);
    });
  }

  void _broadcastState(PlaybackEvent event) {
   playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[audioPlayer.processingState]!,
      playing: audioPlayer.playing,
      updatePosition: audioPlayer.position,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
      queueIndex: event.currentIndex,
    ));
  }

  Future<void> initSongs({
    required RxList<MediaItem> songs,
  }) async {
    audioPlayer.playbackEventStream.listen(_broadcastState);

    List<UriAudioSource> audioSource = songs.map(_createAudioSource).toList();
    song = audioSource;
    await audioPlayer
        .setAudioSource(ConcatenatingAudioSource(children: audioSource));

    queue.value.clear();
    queue.value.addAll(songs);
    queue.add(queue.value);

    _listenForCurrentSongIndexChanges();
    looping();
    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
    animationController.stop();
  }

  @override
  Future<void> play() {
    playlistcontroller.update();

    animationController.start();

    return audioPlayer.play();
  }

  @override
  Future<void> pause() {
    animationController.stop();

    playlistcontroller.update();
    return audioPlayer.pause();
  }

  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  @override
  Future<void> skipToQueueItem(
    int index,
  ) async {
    await audioPlayer.seek(Duration.zero, index: index);
    playlistcontroller.update();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    super.setRepeatMode(repeatMode);
    switch (repeatMode) {
      case AudioServiceRepeatMode.all:
        audioPlayer.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.none:
        audioPlayer.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
        audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  Future<void> looping() async {
    if (isloop.isTrue) {
      setRepeatMode(AudioServiceRepeatMode.one);
    } else {
      setRepeatMode(AudioServiceRepeatMode.all);
    }
  }

  handlePlayBackNext() {
    if (isloop.isTrue) {
      bool playing = playbackState.value.playing;
      animationController.reset();
      if (!playing) {
        animationController.stop();
      } else {
        animationController.start();
      }
      int index = (audioPlayer.currentIndex! + 1) % song.length;
      skipToQueueItem(index);
    } else {
      skipToNext();
    }
  }

  handlePlayBackPrevious() {
    if (isloop.isTrue) {
      bool playing = playbackState.value.playing;
      animationController.reset();
      if (!playing) {
        animationController.stop();
      } else {
        animationController.start();
      }
      if (audioPlayer.currentIndex == 0) {
        skipToQueueItem(song.length - 1);
      } else {
        skipToQueueItem(audioPlayer.currentIndex! - 1);
      }
    } else {
      skipToPrevious();
    }
  }

  @override
  Future<void> skipToNext() {
    bool playing = playbackState.value.playing;
    animationController.reset();
    if (!playing) {
      animationController.stop();
    } else {
      animationController.start();
    }
    return audioPlayer.seekToNext();
  }

  @override
  Future<void> skipToPrevious() {
    bool playing = playbackState.value.playing;
    animationController.reset();

    if (!playing) {
      animationController.stop();
    } else {
      animationController.start();
    }
    return audioPlayer.seekToPrevious();
  }
}
