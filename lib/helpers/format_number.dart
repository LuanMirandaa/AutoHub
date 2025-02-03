import 'package:intl/intl.dart';

String formatNumber(double number) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    return formatter.format(number);
  }