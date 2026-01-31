import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

List<MediaItem> sort({
  required List<MediaItem> song,
  String sortType = "titleASC", // Changed default to match dropdown
}) {
  // Create a copy of the original list to avoid modifying it
  List<MediaItem> songs = List.from(song);

  switch (sortType) {
    case 'titleASC': // Changed from 'titelAS'
      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      break;
    case 'titleDESC': // Changed from 'titelDS'
      songs.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
      break;
    case 'dateASC': // Changed from 'dateAS'
      // FIX: Use dateAdded from extras instead of genre!
      songs.sort((a, b) {
        final dateA = a.extras?['dateAdded'] as int? ?? 0;
        final dateB = b.extras?['dateAdded'] as int? ?? 0;
        return dateA.compareTo(dateB);
      });
      break;
    case 'dateDESC': // Changed from 'dateDS'
      songs.sort((a, b) {
        final dateA = a.extras?['dateAdded'] as int? ?? 0;
        final dateB = b.extras?['dateAdded'] as int? ?? 0;
        return dateB.compareTo(dateA);
      });
      break;
    default:
      // Return the original copy if sortType not recognized
      break;
  }

  return songs;
}

// Also update the SongModel version to match
List<SongModel> sortSongModel({
  required List<SongModel> song,
  String sortType = "titleASC", // Changed default
}) {
  List<SongModel> songs = List.from(song);

  switch (sortType) {
    case 'titleASC': // Changed
      songs.sort(
        (a, b) => a.displayNameWOExt.toLowerCase().compareTo(
          b.displayNameWOExt.toLowerCase(),
        ),
      );
      break;
    case 'titleDESC': // Changed
      songs.sort(
        (a, b) => b.displayNameWOExt.toLowerCase().compareTo(
          a.displayNameWOExt.toLowerCase(),
        ),
      );
      break;
    case 'dateASC': // Changed
      songs.sort((a, b) {
        return (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0);
      });
      break;
    case 'dateDESC': // Changed
      songs.sort((a, b) {
        return (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0);
      });
      break;
    default:
      break;
  }

  return songs;
}

// Also update these helper functions to match new names
SongSortType audioQuerySongSortType(String sorttype) {
  switch (sorttype) {
    case "titleASC":
    case "titleDESC":
      return SongSortType.TITLE;
    case "dateASC":
    case "dateDESC":
      return SongSortType.DATE_ADDED;
    default:
      return SongSortType.TITLE;
  }
}

OrderType audioQueryOrderType(String sorttype) {
  switch (sorttype) {
    case "dateASC":
    case "titleASC":
      return OrderType.ASC_OR_SMALLER;
    case "titleDESC":
    case "dateDESC":
      return OrderType.DESC_OR_GREATER;
    default:
      return OrderType.DESC_OR_GREATER;
  }
}
