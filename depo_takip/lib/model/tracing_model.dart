class Tracing {
  int tracingId;
  int jobNumber;
  int rowNumber;
  int materialId;
  int? materialNumber;
  String materialName;
  int orderAmount;
  String note;
  String requester;
  int workerId;
  String date;
  bool approval;
  bool accepted;
  int userId;

  Tracing({
    required this.tracingId,
    required this.jobNumber,
    required this.rowNumber,
    required this.materialId,
     this.materialNumber,
    required this.materialName,
    required this.orderAmount,
    required this.note,
    required this.requester,
    required this.workerId,
    required this.date,
    this.approval = false,
    this.accepted = false,
    required this.userId,
  });

  factory Tracing.fromMap(Map<String, dynamic> map) {
    return Tracing(
      tracingId: map['tracing_id'],
      jobNumber: map['job_number'],
      rowNumber: map['row_number'],
      materialId: map['material_id'],
      materialNumber: map['material_number'],
      materialName: map['material_name'],
      orderAmount: map['order_amount'],
      note: map['note'],
      requester: map['requester'],
      workerId: map['worker_id'],
      date: map['date'],
      approval: map['approval'] == 1,
      accepted: map['accepted'] == 1,
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tracing_id': tracingId,
      'job_number': jobNumber,
      'row_number': rowNumber,
      'material_id': materialId,
      'material_number': materialNumber,
      'material_name': materialName,
      'order_amount': orderAmount,
      'note': note,
      'requester': requester,
      'worker_id': workerId,
      'date': date,
      'approval': approval ? 1 : 0,
      'accepted': accepted ? 1 : 0,
      'user_id': userId,
    };
  }

  // Add copyWith method
  Tracing copyWith({
    int? tracingId,
    int? jobNumber,
    int? rowNumber,
    int? materialId,
    int? materialNumber,
    String? materialName,
    int? orderAmount,
    String? note,
    String? requester,
    int? workerId,
    String? date,
    bool? approval,
    bool? accepted,
    int? userId,
  }) {
    return Tracing(
      tracingId: tracingId ?? this.tracingId,
      jobNumber: jobNumber ?? this.jobNumber,
      rowNumber: rowNumber ?? this.rowNumber,
      materialId: materialId ?? this.materialId,
      materialNumber: materialNumber ?? this.materialNumber,
      materialName: materialName ?? this.materialName,
      orderAmount: orderAmount ?? this.orderAmount,
      note: note ?? this.note,
      requester: requester ?? this.requester,
      workerId: workerId ?? this.workerId,
      date: date ?? this.date,
      approval: approval ?? this.approval,
      accepted: accepted ?? this.accepted,
      userId: userId ?? this.userId,
    );
  }
}
