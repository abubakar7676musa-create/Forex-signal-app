import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String price(double value, String pair) {
    final decimals = pair.contains('JPY')
        ? 3
        : pair == 'XAU/USD'
            ? 2
            : pair == 'BTC/USD'
                ? 1
                : 5;
    return value.toStringAsFixed(decimals);
  }

  static String percent(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().toUtc().difference(dateTime.toUtc());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dateTime.toLocal());
  }

  static String fullDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime.toLocal());
  }
}
