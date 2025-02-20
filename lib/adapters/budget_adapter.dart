import 'package:hive/hive.dart';
import '../models/budget.dart';

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 6;

  @override
  Budget read(BinaryReader reader) {
    return Budget(
      id: reader.readString(),
      name: reader.readString(),
      amount: reader.readDouble(),
      categoryId: reader.readString(),
      startDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      ledgerId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name ?? '');
    writer.writeDouble(obj.amount);
    writer.writeString(obj.categoryId);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeInt(obj.endDate.millisecondsSinceEpoch);
  }
}
