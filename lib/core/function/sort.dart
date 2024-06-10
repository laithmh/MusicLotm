import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

List<MediaItem> sort(
    {required List<MediaItem> song, String sortType = "titelAS"}) {
  List<MediaItem> songs = [];
  switch (sortType) {
    case 'titelAS':
      song.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      songs.addAll(song);
      break;
    case 'titelDS':
      song.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
      songs.addAll(song);
      break;
    case 'dateAS':
      song.sort(
        (a, b) {
          DateTime dateA = DateTime.parse(a.genre!);
          DateTime dateB = DateTime.parse(b.genre!);
          return dateA.compareTo(dateB);
        },
      );
      songs.addAll(song);
      break;
    case 'dateDS':
      song.sort(
        (a, b) {
          DateTime dateA = DateTime.parse(a.genre!);
          DateTime dateB = DateTime.parse(b.genre!);
          return dateB.compareTo(dateA);
        },
      );
      songs.addAll(song);
      break;
    default:
      song;
  }

  return songs;
}

List<SongModel> sortSongModel(
    {required List<SongModel> song, String sortType = "titelAS"}) {
  List<SongModel> songs = [];
  switch (sortType) {
    case 'titelAS':
      song.sort(
        (a, b) => a.displayNameWOExt
            .toLowerCase()
            .compareTo(b.displayNameWOExt.toLowerCase()),
      );
      songs.addAll(song);
      break;
    case 'titelDS':
      song.sort(
        (a, b) => b.displayNameWOExt
            .toLowerCase()
            .compareTo(a.displayNameWOExt.toLowerCase()),
      );
      songs.addAll(song);
      break;
    case 'dateAS':
      song.sort(
        (a, b) {
          return a.dateAdded!.compareTo(b.dateAdded as num);
        },
      );
      songs.addAll(song);
      break;
    case 'dateDS':
      song.sort(
        (a, b) {
          return b.dateAdded!.compareTo(a.dateAdded as num);
        },
      );
      songs.addAll(song);
      break;
    default:
      song;
  }

  return songs;
}

SongSortType audioQuerySongSortType(String sorttype) {
  switch (sorttype) {
    case "titelDS" || "titelAS":
      return SongSortType.TITLE;

    case "dateAS" || "dateDS":
      return SongSortType.DATE_ADDED;

    default:
      return SongSortType.TITLE;
  }
}

OrderType audioQueryOrderType(String sorttype) {
  switch (sorttype) {
    case "dateAS" || "titelAS":
      return OrderType.ASC_OR_SMALLER;

    case "titelDS" || "dateDS":
      return OrderType.DESC_OR_GREATER;

    default:
      return OrderType.DESC_OR_GREATER;
  }
}
