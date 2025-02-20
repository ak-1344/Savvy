import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 4;

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(
      id: reader.readString(),
      description: reader.readString(),
      amount: reader.readDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      categoryId: reader.readString(),
      ledgerId: reader.readString(),
      type: reader.read() as TransactionType,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.description ?? '');
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.categoryId);
    writer.writeString(obj.ledgerId);
    writer.write(obj.type);
  }
}
