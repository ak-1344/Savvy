import 'package:hive/hive.dart';
import '../models/user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.readString(),
      name: reader.readString(),
      email: reader.readString(),
      password: '',
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
  }
}
