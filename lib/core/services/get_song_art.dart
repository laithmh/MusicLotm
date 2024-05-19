import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Asynchronous function to get the artwork for a song
Future<Uri?> getSongArt({
  required int id,
  required ArtworkType type,

  required int size,
}) async {
  try {
    // Create an instance of OnAudioQuery for querying artwork
    final OnAudioQuery onAudioQuery = OnAudioQuery();

    // Query artwork data for the specified song
    final Uint8List? data = await onAudioQuery.queryArtwork(
      id,
      type,
      format: ArtworkFormat.PNG,
      size: size,

    );

    
    Uri? art;

    
    if (data != null) {
      
      final Directory tempDir = Directory.systemTemp;

      
      final File file = File("${tempDir.path}/$id.jpg");

      
      await file.writeAsBytes(data);

      
      art = file.uri;
    }

    
    return art;
  } catch (e) {
    
    debugPrint('Error fetching song artwork: $e');
    return null; 
  }
}
