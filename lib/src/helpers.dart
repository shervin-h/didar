extension DurationExtensions on Duration {
  /// Converts the duration to a `MM:SS` formatted string.
  ///
  /// - Minutes (`MM`) and seconds (`SS`) are always two digits, with leading zeros if needed.
  /// - Example:
  ///   ```dart
  ///   Duration(seconds: 65).toMMSS(); // Returns "01:05"
  ///   Duration(seconds: 9).toMMSS();  // Returns "00:09"
  ///   ```
  ///
  /// Returns a string representation of the duration in `MM:SS` format.
  String toMMSS() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}