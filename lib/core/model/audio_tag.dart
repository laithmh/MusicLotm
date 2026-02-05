import 'dart:typed_data';

class AudioTag {
  final String filePath;
  String title;
  String artist;
  String album;
  String genre;
  String year;
  String trackNumber;
  String albumArtist;
  String composer;
  String comment;
  Uint8List? albumArt;
  String? albumArtPath;
  String? lyrics;
  
  AudioTag({
    required this.filePath,
    this.title = '',
    this.artist = '',
    this.album = '',
    this.genre = '',
    this.year = '',
    this.trackNumber = '',
    this.albumArtist = '',
    this.composer = '',
    this.comment = '',
    this.albumArt,
    this.albumArtPath,
    this.lyrics,
  });
  
  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'title': title,
    'artist': artist,
    'album': album,
    'genre': genre,
    'year': year,
    'trackNumber': trackNumber,
    'albumArtist': albumArtist,
    'composer': composer,
    'comment': comment,
    'albumArtPath': albumArtPath,
    'lyrics': lyrics,
  };
  
  factory AudioTag.fromJson(Map<String, dynamic> json) => AudioTag(
    filePath: json['filePath'],
    title: json['title'] ?? '',
    artist: json['artist'] ?? '',
    album: json['album'] ?? '',
    genre: json['genre'] ?? '',
    year: json['year'] ?? '',
    trackNumber: json['trackNumber'] ?? '',
    albumArtist: json['albumArtist'] ?? '',
    composer: json['composer'] ?? '',
    comment: json['comment'] ?? '',
    albumArtPath: json['albumArtPath'],
    lyrics: json['lyrics'],
  );
}