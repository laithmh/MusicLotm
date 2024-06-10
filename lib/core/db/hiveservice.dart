import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import 'package:musiclotm/core/db/songsdata.dart';
import 'package:musiclotm/core/services/song_to_media_item.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HiveService {
  final Box<MediaItemModel> _mediaItemBox =
      Hive.box<MediaItemModel>('media_items');

  Future<List<MediaItem>> getAllMediaItems() async {
    return _mediaItemBox.values.map((e) => e.toMediaItem()).toList();
  }

  Future<void> addMediaItems(List<MediaItem> items) async {
    List<MediaItemModel> mediaItemModels =
        items.map((item) => MediaItemModel.fromMediaItem(item)).toList();

    for (var mediaItem in mediaItemModels) {
      await _mediaItemBox.put(mediaItem.id, mediaItem);
    }
  }

  Future<void> updateSongs() async {
    OnAudioQuery onAudioQuery = OnAudioQuery();
    List<SongModel> songs = await onAudioQuery.querySongs();

    final mediaItemModels = await Future.wait(songs.map((song) async {
      return songToMediaItemHive(song);
    }).toList());

    for (var mediaItem in mediaItemModels) {
      if (!_mediaItemBox.containsKey(mediaItem.id)) {
        _mediaItemBox.put(mediaItem.id, mediaItem);
      }
    }
    List<String> currentKeys = mediaItemModels.map((item) => item.id).toList();
    _mediaItemBox.keys
        .where((key) => !currentKeys.contains(key))
        .toList()
        .forEach((key) {
      _mediaItemBox.delete(key);
    });
  }

  Future<void> deleteMediaItem(String id) async {
    await _mediaItemBox.delete(id);
  }
}
