import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 3;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeInt(obj.index);
  }
} 