class DateHelper {
  static DateTime? parseFlexibleDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          // YYYY-MM-DD
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        } else {
          // DD-MM-YYYY
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
