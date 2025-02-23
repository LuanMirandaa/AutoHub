import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatNumber(double number) {
  final formatter = NumberFormat.decimalPattern('pt_BR');
  return formatter.format(number);
}

double parseFormattedNumber(String formattedNumber) {
  String cleanedNumber =
      formattedNumber.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleanedNumber) ?? 0.0;
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    double value = double.tryParse(cleanedText) ?? 0.0;
    final formatter = NumberFormat.decimalPattern('pt_BR');
    String formattedText = formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}