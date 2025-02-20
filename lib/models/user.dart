import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? profilePicture;

  @HiveField(4)
  final DateTime joinDate;

  @HiveField(5)
  DateTime lastActive;

  @HiveField(6)
  String? imageUrl;

  var password;

  int get ledgerCount => 0; // Implement actual count
  String get formattedJoinDate => joinDate.toString();
  String get formattedLastActive => lastActive.toString();

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    DateTime? joinDate,
    DateTime? lastActive,
    this.imageUrl,
    required String password,
  })  : joinDate = joinDate ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now();
}
