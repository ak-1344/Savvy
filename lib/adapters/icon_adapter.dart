import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IconDataAdapter extends TypeAdapter<IconData> {
  @override
  final int typeId = 8;

  @override
  IconData read(BinaryReader reader) {
    return IconData(
      reader.readInt(),
      fontFamily: reader.readString(),
      fontPackage: reader.readString(),
      matchTextDirection: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    writer.writeInt(obj.codePoint);
    writer.writeString(obj.fontFamily ?? '');
    writer.writeString(obj.fontPackage ?? '');
    writer.writeBool(obj.matchTextDirection);
  }
} 