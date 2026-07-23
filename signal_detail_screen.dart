import 'package:flutter/material.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/core/utils/formatters.dart';
import 'package:forex_signals_app/models/signal_model.dart';

class SignalDetailScreen extends StatelessWidget {
  final SignalModel signal;
  const SignalDetailScreen({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final directionColor = signal.isBuy ? AppColors.buy : AppColors.sell;

    return Scaffold(
      appBar: AppBar(title: Text(signal.pair)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: directionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(signal.isBuy ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: directionColor, size: 18),
                      const SizedBox(width: 6),
                      Text(signal.direction, style: TextStyle(color: directionColor, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Text('${signal.timeframe} • ${Formatters.timeAgo(signal.createdAt)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 20),
            _ConfidenceGauge(confidence: signal.confidenceScore),
            const SizedBox(height: 24),
            _PriceLevelsCard(signal: signal),
            const SizedBox(height: 20),
            if (signal.explanation != null) ...[
              Text('AI Explanation', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(signal.explanation!, style: const TextStyle(height: 1.5, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (signal.confirmations.isNotEmpty) ...[
              Text('Confluences (${signal.confirmations.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...signal.confirmations.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.buy),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c, style: const TextStyle(fontSize: 13.5))),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI signals are analytical estimates, not guarantees. Always manage your own risk.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceGauge extends StatelessWidget {
  final int confidence;
  const _ConfidenceGauge({required this.confidence});

  Color get _color {
    if (confidence >= 85) return AppColors.buy;
    if (confidence >= 70) return AppColors.accent;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: confidence / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(_color),
                  ),
                  Text('$confidence%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Confidence Score', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(
                    'Weighted confluence across technical indicators and Smart Money Concepts.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceLevelsCard extends StatelessWidget {
  final SignalModel signal;
  const _PriceLevelsCard({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _LevelRow(label: 'Entry Price', value: Formatters.price(signal.entryPrice, signal.pair), icon: Icons.flag_rounded, color: AppColors.primary),
            const Divider(height: 28),
            _LevelRow(label: 'Stop Loss', value: Formatters.price(signal.stopLoss, signal.pair), icon: Icons.shield_outlined, color: AppColors.sell),
            const Divider(height: 28),
            _LevelRow(label: 'Take Profit 1', value: Formatters.price(signal.takeProfit1, signal.pair), icon: Icons.flag_circle_rounded, color: AppColors.buy),
            const Divider(height: 28),
            _LevelRow(label: 'Take Profit 2', value: Formatters.price(signal.takeProfit2, signal.pair), icon: Icons.flag_circle_rounded, color: AppColors.buy),
            const Divider(height: 28),
            _LevelRow(label: 'Risk : Reward', value: '1 : ${signal.riskRewardRatio.toStringAsFixed(1)}', icon: Icons.balance_rounded, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _LevelRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
      ],
    );
  }
}
