import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 0)
class AppPlaylist {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdDate;

  @HiveField(3)
  final List<String> songIds;

  @HiveField(4)
  String? description;

  @HiveField(5)
  String? coverImagePath;

  AppPlaylist({
    String? id,
    required this.name,
    List<String>? songIds,
    this.description,
    this.coverImagePath,
  })  : id = id ?? const Uuid().v4(),
        createdDate = DateTime.now(),
        songIds = songIds ?? [];

  int get songCount => songIds.length;

  void addSong(String songId) {
    if (!songIds.contains(songId)) {
      songIds.add(songId);
    }
  }

  /// Add multiple songs, skipping duplicates
  void addAllSongs(Iterable<String> newSongIds) {
    for (final id in newSongIds) {
      if (!songIds.contains(id)) {
        songIds.add(id);
      }
    }
  }

  void removeSong(String songId) => songIds.remove(songId);
  void updateName(String newName) => name = newName;
  void clearSongs() => songIds.clear();
  bool containsSong(String songId) => songIds.contains(songId);

  void reorderSongs(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= songIds.length ||
        newIndex < 0 ||
        newIndex >= songIds.length) {
      throw RangeError.index(oldIndex, songIds, 'oldIndex', null, newIndex);
    }
    final songId = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, songId);
  }

  /// ✅ Complete JSON serialisation – includes all fields needed for export/import
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdDate': createdDate.toIso8601String(),
        'songIds': songIds,          // 🟢 FIXED: was missing!
        'description': description,
        'coverImagePath': coverImagePath, // 🟢 FIXED: was missing!
        'songCount': songCount,
      };
}