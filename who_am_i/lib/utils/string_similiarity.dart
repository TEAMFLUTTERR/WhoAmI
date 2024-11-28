import 'dart:math';

extension StringSimilarity on String {
  double similarityTo(String other) {
    if (this == other) return 1.0;
    if (this.isEmpty || other.isEmpty) return 0.0;

    String str1 = this.toLowerCase();
    String str2 = other.toLowerCase();

    // Simple Levenshtein distance implementation
    var dist = List.generate(
      str1.length + 1,
      (i) => List.generate(str2.length + 1, (j) => j == 0 ? i : 0),
    );

    for (var j = 1; j <= str2.length; j++) {
      dist[0][j] = j;
    }

    for (var i = 1; i <= str1.length; i++) {
      for (var j = 1; j <= str2.length; j++) {
        if (str1[i - 1] == str2[j - 1]) {
          dist[i][j] = dist[i - 1][j - 1];
        } else {
          dist[i][j] = [
                dist[i - 1][j], // deletion
                dist[i][j - 1], // insertion
                dist[i - 1][j - 1] // substitution
              ].reduce(min) +
              1;
        }
      }
    }

    double maxLength = max(str1.length, str2.length).toDouble();
    return 1 - (dist[str1.length][str2.length] / maxLength);
  }
}
