import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/state_manager.dart';
import 'package:just_audio/just_audio.dart';

class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
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
  }

  @override
  Future<void> play() => audioPlayer.play();

  @override
  Future<void> pause() => audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  @override
  Future<void> skipToQueueItem(
    int index,
  ) async {
    await audioPlayer.seek(Duration.zero, index: index);
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
      int index = (audioPlayer.currentIndex! + 1) % song.length;
      skipToQueueItem(index);
    } else {
      skipToNext();
    }
  }

  handlePlayBackPrevious() {
    if (isloop.isTrue) {
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
  Future<void> skipToNext() => audioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() => audioPlayer.seekToPrevious();
}
