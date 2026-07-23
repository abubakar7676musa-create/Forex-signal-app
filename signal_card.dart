import 'package:flutter/material.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/core/utils/formatters.dart';
import 'package:forex_signals_app/models/signal_model.dart';

class SignalCard extends StatelessWidget {
  final SignalModel signal;
  final VoidCallback onTap;

  const SignalCard({super.key, required this.signal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final directionColor = signal.isBuy ? AppColors.buy : AppColors.sell;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(signal.pair, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: directionColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          signal.isBuy ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 14,
                          color: directionColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          signal.direction,
                          style: TextStyle(color: directionColor, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _ConfidenceBadge(confidence: signal.confidenceScore),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _PriceStat(label: 'Entry', value: Formatters.price(signal.entryPrice, signal.pair)),
                  _PriceStat(label: 'Stop Loss', value: Formatters.price(signal.stopLoss, signal.pair), color: AppColors.sell),
                  _PriceStat(label: 'TP 1', value: Formatters.price(signal.takeProfit1, signal.pair), color: AppColors.buy),
                  _PriceStat(label: 'TP 2', value: Formatters.price(signal.takeProfit2, signal.pair), color: AppColors.buy),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.balance_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('RR 1:${signal.riskRewardRatio.toStringAsFixed(1)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  const Spacer(),
                  Text(Formatters.timeAgo(signal.createdAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _PriceStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final int confidence;
  const _ConfidenceBadge({required this.confidence});

  Color get _color {
    if (confidence >= 85) return AppColors.buy;
    if (confidence >= 70) return AppColors.accent;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 12, color: _color),
          const SizedBox(width: 3),
          Text('$confidence%', style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
