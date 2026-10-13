class NumberToWords {
  static String convert(dynamic amount) {
    if (amount == null) return '';
    double val = 0.0;
    if (amount is num) {
      val = amount.toDouble();
    } else if (amount is String) {
      final cleaned = amount.replaceAll(',', '').trim();
      val = double.tryParse(cleaned) ?? 0.0;
    }

    if (val == 0.0) return "Zero Rupees Only";

    final bool isNegative = val < 0;
    if (isNegative) val = -val;

    final int rupees = val.floor();
    final int paise = ((val - rupees) * 100).round();

    final units = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    final tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];

    String convertUnderThousand(int n) {
      String str = "";
      if (n >= 100) {
        str += "${units[n ~/ 100]} Hundred ";
        n %= 100;
      }
      if (n >= 20) {
        str += "${tens[n ~/ 10]} ";
        n %= 10;
      }
      if (n > 0) {
        str += "${units[n]} ";
      }
      return str.trim();
    }

    int n = rupees;
    String res = "";
    if (n >= 10000000) {
      res += "${convertUnderThousand(n ~/ 10000000)} Crore ";
      n %= 10000000;
    }
    if (n >= 100000) {
      res += "${convertUnderThousand(n ~/ 100000)} Lakh ";
      n %= 100000;
    }
    if (n >= 1000) {
      res += "${convertUnderThousand(n ~/ 1000)} Thousand ";
      n %= 1000;
    }
    if (n > 0) {
      res += convertUnderThousand(n);
    }

    String rupeeWords = res.trim();
    String finalResult = rupeeWords.isNotEmpty ? "$rupeeWords Rupees" : "";
    if (paise > 0) {
      String paiseWords = convertUnderThousand(paise);
      finalResult += finalResult.isNotEmpty ? " and $paiseWords Paise" : "$paiseWords Paise";
    }

    if (finalResult.isEmpty) return "Zero Rupees Only";

    return "${isNegative ? 'Minus ' : ''}$finalResult Only";
  }
}
