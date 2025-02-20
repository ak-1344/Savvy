import 'package:hive/hive.dart';
import '../models/ledger.dart';

class LedgerAdapter extends TypeAdapter<Ledger> {
  @override
  final int typeId = 2;

  @override
  Ledger read(BinaryReader reader) {
    return Ledger(
      id: reader.readString(),
      name: reader.readString(),
      balance: reader.readDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      userId: '',
    );
  }

  @override
  void write(BinaryWriter writer, Ledger obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.balance);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
