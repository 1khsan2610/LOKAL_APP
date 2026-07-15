/// Model untuk riwayat tracking per status
class TrackingHistory {
  final String status;
  final String notes;
  final String createdAt;

  TrackingHistory({
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory TrackingHistory.fromJson(Map<String, dynamic> json) => TrackingHistory(
    status: json['status'] ?? '',
    notes: json['notes'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}

/// Model respons utama dari GET /api/orders/{id}/tracking
class TrackingResponse {
  final int orderId;
  final String orderNumber;
  final String statusSaatIni;
  final String? trackingNumber;
  final List<TrackingHistory> histories;

  TrackingResponse({
    required this.orderId,
    required this.orderNumber,
    required this.statusSaatIni,
    this.trackingNumber,
    this.histories = const [],
  });

  factory TrackingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TrackingResponse(
      orderId: data['order_id'] is int
          ? data['order_id']
          : int.tryParse(data['order_id'].toString()) ?? 0,
      orderNumber: data['order_number'] ?? '',
      statusSaatIni: data['status_saat_ini'] ?? data['status'] ?? '',
      trackingNumber: data['tracking_number'],
      histories: (data['histories'] as List<dynamic>?)
              ?.map((e) => TrackingHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}