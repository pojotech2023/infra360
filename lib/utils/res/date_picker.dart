
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<String> selectDate(BuildContext context) async {
  DateTime now = DateTime.now();
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate:DateTime.now(),
    firstDate: now.subtract(Duration(days: 365)),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
    return formattedDate;
  }
  else{
    return '';
  }
}


String formatDate(String dateString) {
  try {
    // Try parsing as yyyy-MM-dd
    final inputFormat = DateFormat('yyyy-MM-dd');
    final date = inputFormat.parseStrict(dateString);

    // If parsing succeeds, convert to dd-MM-yyyy
    return DateFormat('dd-MM-yyyy').format(date);
  } catch (e) {
    // If parsing fails, assume it's already formatted
    return dateString;
  }
}
String convertMonthFormat(String input) {
  // Example input: "Oct-2025"
  final months = {
    'Jan': '01',
    'Feb': '02',
    'Mar': '03',
    'Apr': '04',
    'May': '05',
    'Jun': '06',
    'Jul': '07',
    'Aug': '08',
    'Sep': '09',
    'Oct': '10',
    'Nov': '11',
    'Dec': '12',
  };

  final parts = input.split('-');
  if (parts.length != 2) return input; // invalid format safeguard

  final monthName = parts[0];
  final year = parts[1];

  final monthNumber = months[monthName] ?? '00';

  return '$year-$monthNumber'; // Output: 2025-10
}
