class SignalModel {
  final String id;
  final String pair;
  final String direction; // BUY | SELL
  final double entryPrice;
  final double stopLoss;
  final double takeProfit1;
  final double takeProfit2;
  final double riskRewardRatio;
  final int confidenceScore;
  final String timeframe;
  final String status;
  final String? explanation;
  final List<String> confirmations;
  final DateTime createdAt;

  SignalModel({
    required this.id,
    required this.pair,
    required this.direction,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit1,
    required this.takeProfit2,
    required this.riskRewardRatio,
    required this.confidenceScore,
    required this.timeframe,
    required this.status,
    this.explanation,
    required this.confirmations,
    required this.createdAt,
  });

  bool get isBuy => direction.toUpperCase() == 'BUY';

  factory SignalModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedConfirmations = [];
    final rawConfirmations = json['confirmations'];
    if (rawConfirmations is String && rawConfirmations.isNotEmpty) {
      try {
        final decoded = rawConfirmations
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',');
        parsedConfirmations = decoded.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } catch (_) {
        parsedConfirmations = [];
      }
    }

    return SignalModel(
      id: json['id'] as String,
      pair: json['pair'] as String,
      direction: json['direction'] as String,
      entryPrice: (json['entry_price'] as num).toDouble(),
      stopLoss: (json['stop_loss'] as num).toDouble(),
      takeProfit1: (json['take_profit_1'] as num).toDouble(),
      takeProfit2: (json['take_profit_2'] as num).toDouble(),
      riskRewardRatio: (json['risk_reward_ratio'] as num).toDouble(),
      confidenceScore: (json['confidence_score'] as num).toInt(),
      timeframe: json['timeframe'] as String? ?? '1h',
      status: json['status'] as String? ?? 'ACTIVE',
      explanation: json['explanation'] as String?,
      confirmations: parsedConfirmations,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
