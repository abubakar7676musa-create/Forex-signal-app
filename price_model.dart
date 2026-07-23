class PriceModel {
  final String pair;
  final double price;
  final double changePercent;
  final DateTime timestamp;

  PriceModel({
    required this.pair,
    required this.price,
    required this.changePercent,
    required this.timestamp,
  });

  bool get isUp => changePercent >= 0;

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      pair: json['pair'] as String,
      price: (json['price'] as num).toDouble(),
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
