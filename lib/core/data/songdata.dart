
import 'package:hive_flutter/hive_flutter.dart';

part 'songdata.g.dart';
@HiveType(typeId: 1)
class Songdata {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? album;

  @HiveField(3)
  final String? artist;

  @HiveField(4)
  final String? genre;

  @HiveField(5)
  final int? duration;

  @HiveField(6)
  final String? artUri;

 
  @HiveField(8)
  final bool? playable;

  @HiveField(9)
  final String? displayTitle;

  @HiveField(10)
  final String? displaySubtitle;

  @HiveField(11)
  final String? displayDescription;

 

  

  const Songdata({
    required this.id,
    required this.title,
    this.album,
    this.artist,
    this.genre,
    this.duration,
    this.artUri,
    
    this.playable = true,
    this.displayTitle,
    this.displaySubtitle,
    this.displayDescription,
    
  });
}
