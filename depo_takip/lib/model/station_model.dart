class Station {
  int stationId;
  String stationName;

  Station({
   required this.stationId, 
    required this.stationName});

  // Veritabanından alınan haritayı Station modeline çevirir
  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      stationId: map['station_id'],
      stationName: map['station_name'],
    );
  }

  // Station modelini veritabanına eklenebilecek bir haritaya çevirir
  Map<String, dynamic> toMap() {
    return {
      'station_id': stationId,
      'station_name': stationName,
    };
  }
}
