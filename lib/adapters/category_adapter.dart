import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 5;

  @override
  Category read(BinaryReader reader) {
    return Category(
      id: reader.readString(),
      name: reader.readString(),
      color: Color(reader.readInt()),
      icon: IconData(reader.readInt(), fontFamily: 'MaterialIcons'),
      ledgerId: '',
      emoji: '',
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.color.value);
    writer.writeInt(obj.icon!.codePoint);
  }
}
