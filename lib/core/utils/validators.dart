abstract final class Validators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Include at least one letter';
    if (!RegExp(r'\d').hasMatch(v)) return 'Include at least one number';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  static String? phone(String? value) {
    final digits = RegExp(r'\d').allMatches(value ?? '').map((m) => m.group(0)!).join();
    if (digits.isEmpty) return 'Phone number is required';
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? district(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'District is required';
    return null;
  }

  static String? dateOfBirth(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Date of birth is required';
    final parsed = DateTime.tryParse(v);
    if (parsed == null) return 'Use format YYYY-MM-DD';
    if (parsed.isAfter(DateTime.now())) return 'Date cannot be in the future';
    return null;
  }

  static String? birthTime(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(v)) return 'Use format HH:MM (24h)';
    final parts = v.split(':');
    final h = int.tryParse(parts[0]) ?? -1;
    final m = int.tryParse(parts[1]) ?? -1;
    if (h < 0 || h > 23 || m < 0 || m > 59) return 'Invalid time';
    return null;
  }

  static String? deliveryAddress(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 10) return 'Enter a full delivery address';
    return null;
  }

  static String? codPhone(String? value) {
    final digits = RegExp(r'\d').allMatches(value ?? '').map((m) => m.group(0)!).join();
    if (digits.length < 11) return 'Enter a valid Bangladesh phone (11 digits)';
    return null;
  }

  static String? rating(int? value) {
    if (value == null || value < 1 || value > 5) return 'Select a rating (1–5 stars)';
    return null;
  }

  static String? reviewComment(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 10) return 'Write at least 10 characters';
    return null;
  }
}
