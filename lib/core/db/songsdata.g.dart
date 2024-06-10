// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songsdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaItemModelAdapter extends TypeAdapter<MediaItemModel> {
  @override
  final int typeId = 0;

  @override
  MediaItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaItemModel(
      id: fields[0] as String,
      displayDescription: fields[5] as String,
      title: fields[2] as String,
      artist: fields[3] as String,
      genre: fields[6] as String,
      duration: fields[4] as int,
      artUri: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MediaItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.artUri)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.displayDescription)
      ..writeByte(6)
      ..write(obj.genre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
