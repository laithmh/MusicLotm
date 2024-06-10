// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:musiclotm/controller/animationcontroller.dart';
// import 'package:musiclotm/controller/playlistcontroller.dart';
// import 'package:musiclotm/controller/songscontroller.dart';
// import 'package:musiclotm/core/services/song_to_media_item.dart';
// import 'package:musiclotm/main.dart';
// import 'package:on_audio_query/on_audio_query.dart';

// class Audiobackground {
//   AnimationControllerX animationController = Get.find();

//   Songscontroller songscontroller = Get.find();
//   Playlistcontroller playlistcontroller = Get.find();

//   RxBool isloop = false.obs;
//   late List<UriAudioSource> song;
//   Rx<SequenceState?> sequenceStateplyer = Rx<SequenceState?>(null);
 


//   void setSequenceState(SequenceState? state) {
//     sequenceStateplyer.value = state;
//   }

//   Future<void> initializeAudio(List<SongModel> songsmodel) async {
//     List<AudioSource> audioSources = await Future.wait(songsmodel.map((song) {
//       return songToMedia(song);
//     }).toList());

//     await audioPlayer.setAudioSource(
//         ConcatenatingAudioSource(children: audioSources),
//         initialIndex: songscontroller.currentSongPlayingIndex.value,
//         initialPosition: songscontroller.position.seconds);
//     audioPlayer.setLoopMode(LoopMode.all);
//     audioPlayer.pause();
//   }

//   UriAudioSource createAudioSource(SongModel item) {
//     return ProgressiveAudioSource(Uri.parse(item.uri!));
//   }

//   Future<void> initSongs({
//     required List<SongModel> songs,
//   }) async {
//     List<UriAudioSource> audioSource = songs.map(createAudioSource).toList();

//     await audioPlayer
//         .setAudioSource(ConcatenatingAudioSource(children: audioSource));
//   }

//   Future<void> play() {
//     playlistcontroller.update();

//     animationController.start();

//     return audioPlayer.play();
//   }

//   Future<void> pause() {
//     animationController.stop();

//     playlistcontroller.update();
//     return audioPlayer.pause();
//   }

//   Future<void> seekto(Duration position) => audioPlayer.seek(position);

//   Future<void> skipToQueueItem(
//     int index,
//   ) async {
//     await audioPlayer.seek(Duration.zero, index: index);
//     playlistcontroller.update();
//   }

//   // Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
//   //   switch (repeatMode) {
//   //     case AudioServiceRepeatMode.all:
//   //       audioPlayer.setLoopMode(LoopMode.all);
//   //       break;
//   //     case AudioServiceRepeatMode.none:
//   //       audioPlayer.setLoopMode(LoopMode.off);
//   //       break;
//   //     case AudioServiceRepeatMode.one:
//   //       audioPlayer.setLoopMode(LoopMode.one);
//   //       break;
//   //     case AudioServiceRepeatMode.group:
//   //       audioPlayer.setLoopMode(LoopMode.all);
//   //       break;
//   //   }
//   // }

//   Future<void> looping() async {
//     return audioPlayer.setLoopMode(LoopMode.all);
//   }

//   handlePlayBackNext() {
//     if (isloop.isTrue) {
//       bool playing = audioPlayer.playing;
//       animationController.reset();
//       if (!playing) {
//         animationController.stop();
//       } else {
//         animationController.start();
//       }
//       int index = (audioPlayer.currentIndex! + 1) % song.length;
//       skipToQueueItem(index);
//     } else {
//       seekToNext();
//     }
//   }

//   handlePlayBackPrevious() {
//     if (isloop.isTrue) {
//       bool playing = audioPlayer.playing;
//       animationController.reset();
//       if (!playing) {
//         animationController.stop();
//       } else {
//         animationController.start();
//       }
//       if (audioPlayer.currentIndex == 0) {
//         skipToQueueItem(song.length - 1);
//       } else {
//         skipToQueueItem(audioPlayer.currentIndex! - 1);
//       }
//     } else {
//       seekToPrevious();
//     }
//   }

//   Future<void> seekToNext() {
//     bool playing = audioPlayer.playing;
//     playlistcontroller.update();
//     animationController.reset();
//     if (!playing) {
//       animationController.stop();
//     } else {
//       animationController.start();
//     }
//     return audioPlayer.seekToNext();
//   }

//   Future<void> seekToPrevious() {
//     bool playing = audioPlayer.playing;
//     animationController.reset();
//     playlistcontroller.update();
//     if (!playing) {
//       animationController.stop();
//     } else {
//       animationController.start();
//     }
//     return audioPlayer.seekToPrevious();
//   }
// }
