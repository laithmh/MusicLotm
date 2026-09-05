import 'package:flutter_test/flutter_test.dart';
import 'package:musiclotm/core/model/playlist_model.dart';

void main() {
  group('AppPlaylist Model Tests', () {
    test('Create new playlist with default properties', () {
      final playlist = AppPlaylist(
        name: 'My Favorites',
        description: 'Top tracks',
      );

      expect(playlist.name, 'My Favorites');
      expect(playlist.description, 'Top tracks');
      expect(playlist.songIds, isEmpty);
      expect(playlist.songCount, 0);
      expect(playlist.id, isNotEmpty);
    });

    test('Add songs and prevent duplicate IDs', () {
      final playlist = AppPlaylist(name: 'Workout Mix');

      playlist.addSong('song_1');
      playlist.addSong('song_2');
      playlist.addSong('song_1'); // Duplicate

      expect(playlist.songCount, 2);
      expect(playlist.containsSong('song_1'), isTrue);
      expect(playlist.containsSong('song_2'), isTrue);
      expect(playlist.containsSong('song_3'), isFalse);
    });

    test('Remove song from playlist', () {
      final playlist = AppPlaylist(
        name: 'Chill Vibes',
        songIds: ['song_1', 'song_2', 'song_3'],
      );

      playlist.removeSong('song_2');
      expect(playlist.songCount, 2);
      expect(playlist.containsSong('song_2'), isFalse);
    });

    test('JSON serialization includes all properties', () {
      final playlist = AppPlaylist(
        name: 'Road Trip',
        description: 'Highway jams',
        songIds: ['song_100', 'song_200'],
      );

      final json = playlist.toJson();

      expect(json['name'], 'Road Trip');
      expect(json['description'], 'Highway jams');
      expect(json['songIds'], ['song_100', 'song_200']);
      expect(json['songCount'], 2);
      expect(json['id'], isNotNull);
      expect(json['createdDate'], isNotNull);
    });
  });
}
