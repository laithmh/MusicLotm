import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/song_options_sheet.dart';
import 'package:musiclotm/core/Widget/unified_song_tile.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final Searchcontroller searchController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.onPrimary,
      elevation: 0,
      title: _buildSearchField(context),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.inversePrimary),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          if (searchController.isSearching.value) {
            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
              ),
            );
          }
          if (searchController.searchQuery.isNotEmpty) {
            return IconButton(
              icon: Icon(Icons.clear, color: colorScheme.primary),
              onPressed: searchController.clear,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: searchController.textController,
      autofocus: false,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search songs, artists, albums...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: colorScheme.primary.withValues(alpha: 0.7),
          fontSize: 16.sp,
        ),
      ),
      style: TextStyle(
        fontSize: 16.sp,
        color: colorScheme.inversePrimary,
      ),
      onChanged: searchController.search,
      onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() {
        if (searchController.hasError.value) {
          return _buildErrorState(context);
        }

        if (searchController.isSearching.value && searchController.filteredSongs.isEmpty) {
          return _buildLoadingState(context);
        }

        if (searchController.searchQuery.isEmpty) {
          return _buildInitialState(context);
        }

        if (searchController.filteredSongs.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildResultsList(context);
      }),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          'Search Music',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.inversePrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Find your favorite songs, artists, or albums',
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'Searching...',
            style: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: colorScheme.primary),
          SizedBox(height: 16.h),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.inversePrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.redAccent),
          SizedBox(height: 16.h),
          Text(
            'Search failed',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () {
              if (searchController.searchQuery.isNotEmpty) {
                searchController.performSearch(searchController.searchQuery);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'Found ${searchController.resultCount} results',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: searchController.filteredSongs.length,
            itemBuilder: (context, index) {
              final song = searchController.filteredSongs[index];
              return _buildSongTile(context, song);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongTile(BuildContext context, MediaItem song) {
    final songscontroller = Get.find<Songscontroller>();

    return Obx(() {
      final isPlaying =
          songscontroller.currentMediaItem.value?.id == song.id;

      return UnifiedSongTile(
        song: song,
        isPlaying: isPlaying,
        onTap: () => _onSongTap(song),
        onMoreOptions: () {
          SongOptionsSheet.show(
            context: context,
            song: song,
          );
        },
      );
    });
  }

  void _onSongTap(MediaItem song) async {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigatorcontroller navigator = Get.find();
    await searchController.playSongFromSearch(song);
    navigator.changepage(2);
  }
}
