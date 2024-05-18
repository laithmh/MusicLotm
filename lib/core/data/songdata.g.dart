// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongdataAdapter extends TypeAdapter<Songdata> {
  @override
  final int typeId = 1;

  @override
  Songdata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Songdata(
      id: fields[0] as String,
      title: fields[1] as String,
      album: fields[2] as String?,
      artist: fields[3] as String?,
      genre: fields[4] as String?,
      duration: fields[5] as int?,
      artUri: fields[6] as String?,
      playable: fields[8] as bool?,
      displayTitle: fields[9] as String?,
      displaySubtitle: fields[10] as String?,
      displayDescription: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Songdata obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.album)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.genre)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.artUri)
      ..writeByte(7)
      ..writeByte(8)
      ..write(obj.playable)
      ..writeByte(9)
      ..write(obj.displayTitle)
      ..writeByte(10)
      ..write(obj.displaySubtitle)
      ..writeByte(11)
      ..write(obj.displayDescription);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongdataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
