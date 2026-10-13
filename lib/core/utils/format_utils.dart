// Path: core/utils/format_utils.dart
/// Compact number formatting for stats chips ("1.2k" instead of "1200").
String compactCount(int n) =>
    n >= 1000 ? "${(n / 1000).toStringAsFixed(1)}k" : "$n";
