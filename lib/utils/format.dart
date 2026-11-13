import 'package:intl/intl.dart';

String formatMoney(double value, String locale) {
  final hasCents = (value * 100).round() % 100 != 0;
  final format = NumberFormat.currency(
    locale: locale == 'lt' ? 'lt_LT' : 'en_IE',
    symbol: '€',
    decimalDigits: hasCents ? 2 : 0,
  );
  return format.format(value).replaceAll('\u00A0', ' ').trim();
}

String formatMoneyDecimal(double value, String locale) {
  final format = NumberFormat.currency(
    locale: locale == 'lt' ? 'lt_LT' : 'en_IE',
    symbol: '€',
    decimalDigits: 2,
  );
  return format.format(value).replaceAll('\u00A0', ' ').trim();
}

String formatWeight(double value) {
  if (value == 0) return '0';
  final text = value < 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatDate(DateTime date, String locale, {bool weekday = false}) {
  final format = DateFormat(weekday ? 'EEE d MMM' : 'd MMM', locale);
  return format.format(date);
}

String formatLongDate(DateTime date, String locale) {
  return DateFormat('d MMMM y', locale).format(date);
}

String formatDayMonth(DateTime date, String locale) {
  return DateFormat('d MMM', locale).format(date);
}
