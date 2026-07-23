import 'package:flutter/material.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/core/utils/formatters.dart';
import 'package:forex_signals_app/models/price_model.dart';

class PriceTickerItem extends StatelessWidget {
  final PriceModel price;
  const PriceTickerItem({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final color = price.isUp ? AppColors.buy : AppColors.sell;
    return Container(
      width: 132,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(price.pair, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            Formatters.price(price.price, price.pair),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(price.isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded, size: 16, color: color),
              Text(Formatters.percent(price.changePercent), style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
