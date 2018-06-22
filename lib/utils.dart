/// Collection of utility functions

/// Pretty prints numbers
String prettyPrintInt(int num) =>
    (num >= 1000) ? (num / 1000.0).toStringAsFixed(1) + 'k' : '$num';
