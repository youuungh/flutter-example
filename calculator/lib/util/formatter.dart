abstract class IFormatter {
  static String normalize(double value) {
    final String result = value.toString();
    if (result.contains('.') && result.endsWith('0')) {
      final List<String> parts = result.split('.');
      if (int.parse(parts[1]) == 0) {
        return parts[0];
      } else {
        return '${parts[0]}.${parts[1].replaceAll(RegExp(r'0+$'), '')}';
      }
    }
    return result;
  }
}