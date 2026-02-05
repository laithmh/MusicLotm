import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_tagger/flutter_audio_tagger.dart';
import 'package:flutter_audio_tagger/tag.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class TagEditorController extends GetxController {
  /// QUERY
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ImagePicker _imagePicker = ImagePicker();
  final songsController = Get.find<Songscontroller>();

  /// STATE
  final isLoading = false.obs;
  final hasChanges = false.obs;
  final saveProgress = 0.obs; // 0-100 for progress feedback

  final selectedSong = Rxn<SongModel>();
  final currentFilePath = ''.obs; // content:// OR file path
  final albumArtBytes = Rxn<Uint8List>();
  final validationError = ''.obs;

  /// TEXT CONTROLLERS
  final titleController = TextEditingController();
  final artistController = TextEditingController();
  final albumController = TextEditingController();
  final genreController = TextEditingController();

  /// ORIGINAL DATA SNAPSHOT (for undo/comparison)
  final Map<String, dynamic> original = {};

  /// SUPPORTED FORMATS
  final _supportedExtensions = {
    '.mp3',
    '.m4a',
    '.flac',
    '.wav',
    '.aac',
    '.ogg',
  };

  /// INIT
  @override
  void onInit() {
    super.onInit();

    titleController.addListener(_detectChanges);
    artistController.addListener(_detectChanges);
    albumController.addListener(_detectChanges);
    genreController.addListener(_detectChanges);
  }

  /// LOAD SONG
  Future<void> loadSongForEditing(String songId) async {
    try {
      isLoading.value = true;
      validationError.value = '';

      final songs = songsController.songModels;
      final found = songs.firstWhere((s) => s.uri.toString() == songId);
      selectedSong.value = found;
      currentFilePath.value = found.uri ?? '';

      /// Fill controllers
      titleController.text = found.title;
      artistController.text = found.artist ?? '';
      albumController.text = found.album ?? '';
      genreController.text = found.genre ?? '';

      /// Store original snapshot
      original.clear();
      original['title'] = titleController.text;
      original['artist'] = artistController.text;
      original['album'] = albumController.text;
      original['genre'] = genreController.text;
      original['extension'] = p.extension(found.data).toLowerCase();
      original['artwork'] = albumArtBytes.value;

      /// Load artwork
      try {
        final art = await _audioQuery.queryArtwork(
          found.id,
          ArtworkType.AUDIO,
          size: 600,
        );
        if (art != null) {
          albumArtBytes.value = art;
          original['artwork'] = art;
        }
      } catch (_) {}

      hasChanges.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// FORMAT SUPPORT
  String getFileExtension() {
    return (original['extension'] ?? '.mp3').toString();
  }

  bool isFormatSupported() {
    final ext = getFileExtension();
    return ext.isNotEmpty && _supportedExtensions.contains(ext.toLowerCase());
  }

  /// CHANGE DETECTION
  void _detectChanges() {
    final hasTextChanges =
        titleController.text.trim() != (original['title'] ?? '').trim() ||
        artistController.text.trim() != (original['artist'] ?? '').trim() ||
        albumController.text.trim() != (original['album'] ?? '').trim() ||
        genreController.text.trim() != (original['genre'] ?? '').trim();

    // Simple artwork change detection (byte-by-byte comparison is expensive)
    final hasArtworkChange =
        albumArtBytes.value != null && original['artwork'] == null ||
        albumArtBytes.value == null && original['artwork'] != null;

    hasChanges.value = hasTextChanges || hasArtworkChange;
    validationError.value = ''; // Clear validation on change
  }

  /// RESET TO ORIGINAL
  void resetToOriginal() {
    if (original.isEmpty) return;

    titleController.text = original['title'] ?? '';
    artistController.text = original['artist'] ?? '';
    albumController.text = original['album'] ?? '';
    genreController.text = original['genre'] ?? '';
    albumArtBytes.value = original['artwork'];
    hasChanges.value = false;

    Get.snackbar(
      '✅ Changes Reverted',
      'All edits undone',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  /// ARTWORK MANAGEMENT
  void removeAlbumArt() {
    albumArtBytes.value = null;
    hasChanges.value = true;
  }

  Future<void> pickAlbumArt() async {
    try {
      final result = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      if (result == null) return;

      final bytes = await result.readAsBytes();
      albumArtBytes.value = bytes;
      hasChanges.value = true;
    } catch (e) {
      debugPrint('pickAlbumArt error: $e');
      Get.snackbar(
        'Artwork Error',
        'Failed to load image. Try a smaller file.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  /// VALIDATION
  String? _validateBeforeSave() {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      return 'Title cannot be empty';
    }

    if (title.length > 200) {
      return 'Title is too long (max 200 characters)';
    }

    // Check for filesystem-invalid characters
    if (RegExp(r'[<>:"/\\|?*\x00-\x1F]').hasMatch(title)) {
      return 'Title contains invalid characters (< > : " / \\ | ? *)';
    }

    return null;
  }

  /// CONFIRMATION DIALOG
  Future<bool> _showSaveConfirmation() async {
    if (!hasChanges.value) return true;

    final changes = <Widget>[];
    if (titleController.text.trim() != (original['title'] ?? '').trim()) {
      changes.add(
        _buildChangeRow(
          'Title',
          original['title'] ?? '',
          titleController.text.trim(),
        ),
      );
    }
    if (artistController.text.trim() != (original['artist'] ?? '').trim()) {
      changes.add(
        _buildChangeRow(
          'Artist',
          original['artist'] ?? '',
          artistController.text.trim(),
        ),
      );
    }
    if (albumController.text.trim() != (original['album'] ?? '').trim()) {
      changes.add(
        _buildChangeRow(
          'Album',
          original['album'] ?? '',
          albumController.text.trim(),
        ),
      );
    }
    if (genreController.text.trim() != (original['genre'] ?? '').trim()) {
      changes.add(
        _buildChangeRow(
          'Genre',
          original['genre'] ?? '',
          genreController.text.trim(),
        ),
      );
    }
    if (albumArtBytes.value != original['artwork']) {
      changes.add(
        _buildChangeRow(
          'Artwork',
          '✅ Exists',
          albumArtBytes.value == null ? '❌ Removed' : '🖼️ Modified',
        ),
      );
    }

    if (changes.isEmpty) return true; // No actual changes

    return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Theme.of(Get.context!).colorScheme.onPrimary,
            title: const Text('💾 Save Changes?'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The following fields will be updated:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ...changes,
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  Widget _buildChangeRow(String field, String oldVal, String newVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.edit, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        oldVal.isEmpty ? '(empty)' : oldVal,
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Text(
                        newVal.isEmpty ? '(empty)' : newVal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 ENHANCED SAVE FUNCTION WITH UX IMPROVEMENTS
  Future<bool> saveTags() async {
    // 1. Validation
    final validationMsg = _validateBeforeSave();
    if (validationMsg != null) {
      validationError.value = validationMsg;
      Get.snackbar(
        'Validation Error',
        validationMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    // 2. Confirmation
    final confirmed = await _showSaveConfirmation();
    if (!confirmed) return false;

    isLoading.value = true;
    saveProgress.value = 0;
    validationError.value = '';

    File? tempFile;
    try {
      log("Starting tag save operation...");
      final originalUri = currentFilePath.value;
      final ext = getFileExtension();

      // ===== PROGRESS 10%: Prepare temp file =====
      saveProgress.value = 10;
      final cacheDir = await getTemporaryDirectory();

      // CRITICAL FIX: Create temp file with FINAL NAME immediately (for media_store_plus 0.1.3)
      final desiredFilename = sanitizeFilename(
        titleController.text.trim(),
        ext,
      );
      tempFile = File('${cacheDir.path}/$desiredFilename');
      log("Using filename: $desiredFilename");

      // ===== PROGRESS 25%: Read original file =====
      saveProgress.value = 25;
      final mediaStore = MediaStore();
      await mediaStore.readFileUsingUri(
        uriString: originalUri,
        tempFilePath: tempFile.path,
      );

      // ===== PROGRESS 50%: Apply tags =====
      saveProgress.value = 50;
      final tagger = FlutterAudioTagger();
      final tag = Tag(
        title: titleController.text.trim(),
        artist: artistController.text.trim(),
        album: albumController.text.trim(),
        genre: genreController.text.trim(),
        artwork: albumArtBytes.value,
      );
      await tagger.editTagsAndArtwork(tag, tempFile.path);

      // ===== PROGRESS 75%: Save to MediaStore =====
      saveProgress.value = 75;
      final saveInfo = await mediaStore.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.audio,
        dirName: DirName.music,
      );

      if (saveInfo?.uri.toString() == null) {
        throw Exception("Save operation returned null URI");
      }

      final newUri = saveInfo!.uri
          .toString(); // ✅ CORRECT WAY TO GET URI IN 0.1.3
      log("Saved to URI: $newUri");

      // ===== PROGRESS 90%: Delete original =====
      saveProgress.value = 90;
      try {
        await mediaStore.deleteFileUsingUri(uriString: originalUri);
        log("Original file deleted successfully");
      } catch (e) {
        log("Delete original warning: $e");
        // Continue anyway - we have the new file
      }

      // ===== PROGRESS 100%: Refresh & update state =====
      saveProgress.value = 100;
      
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // Smooth progress finish

     

      await songsController.loadSongs();

      // Update state
      currentFilePath.value = newUri;
      original['title'] = titleController.text.trim();
      original['artist'] = artistController.text.trim();
      original['album'] = albumController.text.trim();
      original['genre'] = genreController.text.trim();
      original['artwork'] = albumArtBytes.value;
      hasChanges.value = false;

      Get.snackbar(
        '✅ Success',
        'Tags saved successfully!\nFilename: $desiredFilename',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );

      return true;
    } catch (e, st) {
      log("saveTags error: $e\n$st");

      // User-friendly error messages
      String errorMsg = e.toString();
      if (errorMsg.contains('Permission')) {
        errorMsg =
            'Storage permission denied. Please allow access in Settings.';
      } else if (errorMsg.contains('exists')) {
        errorMsg = 'File already exists with this name. Try a different title.';
      } else if (errorMsg.length > 100) {
        errorMsg = '${errorMsg.substring(0, 100)}...';
      }

      Get.snackbar(
        '❌ Save Failed',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 6),
      );
      return false;
    } finally {
      isLoading.value = false;
      saveProgress.value = 0;

      // Cleanup temp file
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
    }
  }

  /// SANITIZE FILENAME FOR ANDROID
  String sanitizeFilename(String title, String extension) {
    if (title.isEmpty) title = 'untitled';

    // Remove invalid filesystem characters
    String sanitized = title.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');

    // Replace problematic whitespace
    sanitized = sanitized.replaceAll(RegExp(r'[\r\n\t]'), ' ');
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove leading/trailing dots and spaces (Android rejects these)
    while (sanitized.isNotEmpty && '. '.contains(sanitized[0])) {
      sanitized = sanitized.substring(1);
    }
    while (sanitized.isNotEmpty &&
        '. '.contains(sanitized[sanitized.length - 1])) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }

    if (sanitized.isEmpty) sanitized = 'untitled';

    // Length limit (Android max 255 chars including extension)
    final maxLength = 255 - extension.length;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength).trim();
      if (sanitized.isEmpty) sanitized = 'untitled';
    }

    // Ensure extension is included correctly
    if (!sanitized.toLowerCase().endsWith(extension.toLowerCase())) {
      sanitized += extension;
    }

    return sanitized;
  }

  /// DISCARD CHANGES CONFIRMATION
  Future<bool> confirmDiscardChanges() async {
    if (!hasChanges.value) return true;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('⚠️ Unsaved Changes'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// CLEANUP
  @override
  void onClose() {
    titleController.dispose();
    artistController.dispose();
    albumController.dispose();
    genreController.dispose();
    super.onClose();
  }
}
