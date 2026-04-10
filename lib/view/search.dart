import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final Searchcontroller searchController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      title: _buildSearchField(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          if (searchController.isSearching.value) {
            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              // Fixed size to prevent layout jumping when indicator appears
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          if (searchController.searchQuery.isNotEmpty) {
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: searchController.clear,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController.textController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search songs, artists, albums...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
      ),
      style: TextStyle(fontSize: 16.sp),
      onChanged: searchController.search,
      // Hide keyboard if user hits "search" on their keyboard
      onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() {
        if (searchController.hasError.value) {
          return _buildErrorState();
        }

        // Only show loading if we are searching AND have no previous results
        if (searchController.isSearching.value &&
            searchController.filteredSongs.isEmpty) {
          return _buildLoadingState();
        }

        if (searchController.searchQuery.isEmpty) {
          return _buildInitialState();
        }

        if (searchController.resultCount == 0) {
          return _buildEmptyState();
        }

        return _buildResultsList();
      }),
    );
  }

  Widget _buildInitialState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          'Search Music',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          'Find your favorite songs, artists, or albums',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text('Searching...', style: TextStyle(fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'No results found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red.shade400),
          SizedBox(height: 16.h),
          Text(
            'Search failed',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
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

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'Found ${searchController.resultCount} results',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: ListView.builder(
            // UX optimization: Drops keyboard when user starts scrolling
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: searchController.filteredSongs.length,
            itemBuilder: (context, index) {
              final song = searchController.filteredSongs[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h), // Spacing for Neubox
                child: _buildSongTile(context, song),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongTile(BuildContext context, MediaItem song) {
    return Neubox(
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: Container(
          width: 40.w, // Standardized touch target size
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.music_note,
            color: Colors.grey.shade600,
            size: 24.sp,
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Text(
          song.artist ?? 'Unknown Artist',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          Icons.play_arrow,
          color: Theme.of(context).primaryColor, // Safe context usage
        ),
        onTap: () => _onSongTap(song),
      ),
    );
  }

  void _onSongTap(MediaItem song) async {
    // Drop the keyboard before navigating
    FocusManager.instance.primaryFocus?.unfocus();

    Navigatorcontroller navigator = Get.find();
    await searchController.playSongFromSearch(song);
    navigator.changepage(2);
  }
}
