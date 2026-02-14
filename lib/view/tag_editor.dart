import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/tag_editor_controller.dart';

class TagEditorScreen extends StatefulWidget {
  final String songId;

  const TagEditorScreen({super.key, required this.songId});

  @override
  State<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends State<TagEditorScreen> {
  late final TagEditorController controller = Get.find<TagEditorController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Use widget.songId directly (not Get.parameters)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSong(widget.songId);
    });
  }

  @override
  void dispose() {
    // Cleanup controller state when leaving screen
    controller.resetToOriginal();
    super.dispose();
  }

  // Fetch metadata by songId and populate form
  Future<void> _loadSong(String songId) async {
    try {
      await controller.loadSongForEditing(songId);

      // Check if file format is supported
      if (!controller.isFormatSupported()) {
        Get.snackbar(
          '⚠️ Format Warning',
          'This format (${controller.getFileExtension()}) has limited tag editing support',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        '❌ Load Error',
        'Failed to load song: ${e.toString().split('\n').first}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          () async => await controller.confirmDiscardChanges(),

      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: const Text('Edit Audio Tags'),
      actions: [
        Obx(() {
          if (controller.isLoading.value) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: controller.saveProgress.value / 100,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          }

          return IconButton(
            icon: Icon(
              controller.hasChanges.value
                  ? Icons.save
                  : Icons.save_alt_outlined,
              color: controller.hasChanges.value
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            onPressed: controller.hasChanges.value
                ? () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final saved = await controller.saveTags();
                      if (saved) {
                        Get.back();
                      }
                    }
                  }
                : null,
            tooltip: controller.hasChanges.value
                ? 'Save changes (${_getChangedFieldsCount()} fields)'
                : 'No changes to save',
          );
        }),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.selectedSong.value == null) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }

      if (controller.selectedSong.value == null) {
        return Center(
          child: Text(
            'Song not found',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey),
          ),
        );
      }

      return _buildEditorForm(context);
    });
  }

  Widget _buildEditorForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Song info card
            _buildSongInfoCard(context),
            SizedBox(height: 24.h),

            // Album art section
            _buildAlbumArtSection(context),
            SizedBox(height: 24.h),

            // Filename preview (CRITICAL FOR USER CONFIDENCE)
            _buildFilenamePreview(context),
            SizedBox(height: 24.h),

            // Required fields with undo buttons
            _buildTextFieldWithUndo(
              context: context,
              controller: controller.titleController,
              label: 'Title *',
              icon: Icons.title,
              originalValue: controller.original['title'] ?? '',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.length > 200) {
                  return 'Title too long (max 200 chars)';
                }
                if (RegExp(r'[<>:"/\\|?*\x00-\x1F]').hasMatch(value)) {
                  return 'Contains invalid characters (< > : " / \\ | ? *)';
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),

            _buildTextFieldWithUndo(
              context: context,
              controller: controller.artistController,
              label: 'Artist *',
              icon: Icons.person,
              originalValue: controller.original['artist'] ?? '',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Artist is required';
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),

            // Optional fields
            _buildTextFieldWithUndo(
              context: context,
              controller: controller.albumController,
              label: 'Album',
              icon: Icons.album,
              originalValue: controller.original['album'] ?? '',
            ),
            SizedBox(height: 12.h),

            _buildTextFieldWithUndo(
              context: context,
              controller: controller.genreController,
              label: 'Genre',
              icon: Icons.category,
              originalValue: controller.original['genre'] ?? '',
            ),
            SizedBox(height: 24.h),

            // Validation error display (global)
            Obx(() {
              if (controller.validationError.value.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          controller.validationError.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            SizedBox(height: 24.h),

            // Action buttons
            _buildActionButtons(context),
            SizedBox(height: 40.h), // Bottom padding for keyboard
          ],
        ),
      ),
    );
  }

  Widget _buildSongInfoCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: controller.isFormatSupported()
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isFormatSupported()
                        ? Icons.music_note
                        : Icons.warning,
                    size: 32,
                    color: controller.isFormatSupported()
                        ? Theme.of(context).colorScheme.primary
                        : Colors.orange,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedSong.value?.title ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.selectedSong.value?.artist ??
                            'Unknown Artist',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context: context,
                  icon: Icons.timer,
                  label: 'Duration',
                  value: _formatDuration(
                    controller
                            .selectedSong
                            .value
                            ?.duration
                            ?.minutes
                            .inMinutes ??
                        0,
                  ),
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.insert_drive_file,
                  label: 'Format',
                  value: controller.getFileExtension().toUpperCase().replaceAll(
                    '.',
                    '',
                  ),
                  isWarning: !controller.isFormatSupported(),
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.folder,
                  label: 'File',
                  value: _getFileName(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isWarning
              ? Colors.orange
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isWarning
                ? Colors.orange
                : Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAlbumArtSection(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Album Artwork',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    if (controller.albumArtBytes.value != null)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Remove Artwork?',
                            content: const Text(
                              'Are you sure you want to remove the album artwork?',
                            ),
                            confirm: TextButton(
                              onPressed: () {
                                Get.back();
                                controller.removeAlbumArt();
                              },
                              child: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            cancel: TextButton(
                              onPressed: Get.back,
                              child: const Text('Cancel'),
                            ),
                          );
                        },
                        tooltip: 'Remove artwork',
                      ),
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: controller.pickAlbumArt,
                      tooltip: 'Add artwork',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Obx(() {
                if (controller.albumArtBytes.value != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      controller.albumArtBytes.value!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildNoArtworkPlaceholder(
                          context,
                          isError: true,
                        );
                      },
                    ),
                  );
                } else {
                  return _buildNoArtworkPlaceholder(context, isError: false);
                }
              }),
            ),
            SizedBox(height: 10.h),
            Text(
              'Tap + to add JPG/PNG artwork (300x300 to 1000x1000 recommended)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoArtworkPlaceholder(
    BuildContext context, {
    required bool isError,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image : Icons.image_outlined,
            size: 64.sp,
            color: isError ? Colors.red : Colors.grey[400],
          ),
          SizedBox(height: 12.h),
          Text(
            isError ? 'Failed to load artwork' : 'No artwork added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isError ? Colors.red : Colors.grey[600],
            ),
          ),
          if (!isError) ...[
            SizedBox(height: 4.h),
            Text(
              'Tap + to add album art',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilenamePreview(BuildContext context) {
    final title = controller.titleController.text.trim();
    final ext = controller.getFileExtension();
    final preview = title.isNotEmpty
        ? controller.sanitizeFilename(title, ext)
        : 'untitled$ext';

    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_display_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Filename Preview',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                preview,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'This will be the actual filename after saving',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithUndo({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String originalValue,
    String? Function(String?)? validator,
  }) {
    final isModified = controller.text.trim() != originalValue.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            suffixIcon: isModified
                ? IconButton(
                    icon: Icon(Icons.undo, size: 18.sp, color: Colors.blue),
                    onPressed: () {
                      controller.text = originalValue;
                    },
                    tooltip: 'Revert to original',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isModified
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5)
                    : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isModified
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3)
                    : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 16.h,
            ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        if (isModified) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              'Changed from: "$originalValue"',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  controller.isLoading.value || !controller.hasChanges.value
                  ? null
                  : controller.resetToOriginal,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: BorderSide(
                  color: controller.hasChanges.value
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey,
                ),
                foregroundColor: controller.hasChanges.value
                    ? Theme.of(context).colorScheme.error
                    : Colors.grey,
              ),
              child: Text(
                controller.hasChanges.value ? 'Revert All' : 'No Changes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: controller.hasChanges.value
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value || !controller.hasChanges.value
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final saved = await controller.saveTags();
                        if (saved) {
                          Get.back();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: controller.hasChanges.value
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: controller.isLoading.value
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Saving... ${controller.saveProgress.value}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Text(
                      controller.hasChanges.value
                          ? 'SAVE CHANGES (${_getChangedFieldsCount()})'
                          : 'ALL SAVED',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  int _getChangedFieldsCount() {
    int count = 0;
    if (controller.titleController.text.trim() !=
        (controller.original['title'] ?? '').trim()) {
      count++;
    }
    if (controller.artistController.text.trim() !=
        (controller.original['artist'] ?? '').trim()) {
      count++;
    }
    if (controller.albumController.text.trim() !=
        (controller.original['album'] ?? '').trim()) {
      count++;
    }
    if (controller.genreController.text.trim() !=
        (controller.original['genre'] ?? '').trim()) {
      count++;
    }
    if (controller.albumArtBytes.value != controller.original['artwork']) {
      count++;
    }
    return count;
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) return '0:00';
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getFileName() {
    try {
      final path = controller.currentFilePath.value;
      if (path.isEmpty) return 'Unknown';

      // Extract filename from content URI or file path
      final segments = path.split('/');
      String fileName = segments.isNotEmpty ? segments.last : 'Unknown';

      // Clean up content URI artifacts
      if (fileName.contains('?')) {
        fileName = fileName.split('?').first;
      }

      return fileName.length > 20
          ? '${fileName.substring(0, 8)}...${fileName.substring(fileName.length - 8)}'
          : fileName;
    } catch (e) {
      return 'Unknown';
    }
  }
}
