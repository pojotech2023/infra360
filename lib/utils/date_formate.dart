

import 'package:intl/intl.dart';

String formatDate(String? inputDate) {
  if (inputDate == null) {
    return "";
  } else {
    DateTime date = DateTime.parse(inputDate); // parses "1997-01-27"
    return DateFormat('dd/MM/yyyy').format(date);
  } // returns "27/01/1997"
}