import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

part 'songsdata.g.dart';

@HiveType(typeId: 0)
class MediaItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String artUri;

  @HiveField(2)
  String title;

  @HiveField(3)
  String artist;

  @HiveField(4)
  int duration;

  @HiveField(5)
  String displayDescription;

  @HiveField(6)
  String genre;

  MediaItemModel({
    required this.id,
    required this.displayDescription,
    required this.title,
    required this.artist,
    required this.genre,
    required this.duration,
    required this.artUri,
  });

  MediaItem toMediaItem() {
    return MediaItem(
        id: id,
        artUri: Uri.parse(artUri),
        title: title,
        artist: artist,
        duration: Duration(milliseconds: duration),
        displayDescription: displayDescription.toString(),
        genre: genre);
  }

  factory MediaItemModel.fromMediaItem(MediaItem item) {
    return MediaItemModel(
      id: item.id,
      displayDescription: item.displayDescription ?? '',
      title: item.title,
      artist: item.artist ?? '',
      genre: item.genre ?? '',
      duration: item.duration?.inMilliseconds ?? 0,
      artUri: item.artUri.toString(),
    );
  }
}
