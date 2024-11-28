class User {
  final int? userId;
  String username;
  String password;
  String userAuthority;
  int stationId;

  User({
   required this.userId,
    required this.username,
    required this.password,
    required this.userAuthority,
    required this.stationId,
  });

  // Veritabanından alınan haritayı User modeline çevirir
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      password: map['password'],
      userAuthority: map['user_authority'],
      stationId: map['station_id'],
    );
  }

  // User modelini veritabanına eklenebilecek bir haritaya çevirir
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'password': password,
      'user_authority': userAuthority,
      'station_id': stationId,
    };
  }
}
