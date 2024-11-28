class Store {
  int workerId;
  int itemModelno;
  String workerName;
  int? userId; // Nullable int
  int? stationId;

  Store({
    required this.workerId,
    required this.itemModelno,
    required this.workerName,
    this.userId,
    this.stationId,
  });

  // Veritabanından alınan haritayı Store modeline çevirir
  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      workerId: map['worker_id'],
      itemModelno: map['item_modelno'],
      workerName: map['worker_name'],
      userId: map['user_id'], // Nullable
      stationId: map['station_id'],
    );
  }

  // Store modelini veritabanına eklenebilecek bir haritaya çevirir
  Map<String, dynamic> toMap() {
    return {
      'worker_id': workerId,
      'item_modelno': itemModelno,
      'worker_name': workerName,
      'user_id': userId, // Nullable
      'station_id': stationId,
    };
  }
}
