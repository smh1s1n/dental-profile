class BanglaFormatter {
  BanglaFormatter._();

  static const Map<String, String> _englishToBanglaDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Converts English digits in a string to Bengali digits
  static String toBanglaNumber(dynamic input) {
    if (input == null) return '';
    final String str = input.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_englishToBanglaDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Formats currency with BDT symbol e.g., ৳1,000 / ৳১,০০০
  static String formatBdt(int amount, {bool inBanglaDigits = false}) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    if (inBanglaDigits) {
      return '৳${toBanglaNumber(formatted)}';
    }
    return '৳$formatted';
  }

  /// Validates Bangladeshi phone number format (+8801... or 01...)
  static bool isValidBdPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s+|-'), '');
    final bdRegex = RegExp(r'^(?:\+88|88)?01[3-9]\d{8}$');
    return bdRegex.hasMatch(clean);
  }
}
