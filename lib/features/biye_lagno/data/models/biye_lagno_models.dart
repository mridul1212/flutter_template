class BiyeLagnoProfile {
  const BiyeLagnoProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    this.timeOfBirth,
    this.birthPlace,
    this.nakshatra,
    this.rashi,
  });

  final String id;
  final String name;
  final String gender;
  final String dateOfBirth;
  final String? timeOfBirth;
  final String? birthPlace;
  final String? nakshatra;
  final String? rashi;

  factory BiyeLagnoProfile.fromJson(Map<String, dynamic> json) {
    return BiyeLagnoProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      timeOfBirth: json['timeOfBirth'] as String?,
      birthPlace: json['birthPlace'] as String?,
      nakshatra: json['nakshatra'] as String?,
      rashi: json['rashi'] as String?,
    );
  }
}

class GunaFactorBreakdown {
  const GunaFactorBreakdown({required this.key, required this.points, required this.note});

  final String key;
  final int points;
  final String note;

  factory GunaFactorBreakdown.fromJson(Map<String, dynamic> json) {
    return GunaFactorBreakdown(
      key: json['key'] as String,
      points: (json['points'] as num).toInt(),
      note: json['note'] as String? ?? '',
    );
  }
}

class BiyeLagnoResult {
  const BiyeLagnoResult({
    required this.totalScore,
    required this.maxScore,
    required this.verdict,
    required this.verdictBn,
    required this.nadiDosha,
    required this.bhakootDosha,
    required this.breakdown,
    required this.summary,
  });

  final int totalScore;
  final int maxScore;
  final String verdict;
  final String verdictBn;
  final bool nadiDosha;
  final bool bhakootDosha;
  final List<GunaFactorBreakdown> breakdown;
  final String summary;

  factory BiyeLagnoResult.fromJson(Map<String, dynamic> json) {
    return BiyeLagnoResult(
      totalScore: (json['totalScore'] as num).toInt(),
      maxScore: (json['maxScore'] as num).toInt(),
      verdict: json['verdict'] as String,
      verdictBn: json['verdictBn'] as String? ?? '',
      nadiDosha: json['nadiDosha'] as bool? ?? false,
      bhakootDosha: json['bhakootDosha'] as bool? ?? false,
      breakdown: (json['breakdown'] as List<dynamic>)
          .map((e) => GunaFactorBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      summary: json['summary'] as String? ?? '',
    );
  }
}

class BiyeLagnoData {
  const BiyeLagnoData({required this.sampleProfiles, required this.factorLabels});

  final List<BiyeLagnoProfile> sampleProfiles;
  final Map<String, String> factorLabels;

  factory BiyeLagnoData.fromJson(Map<String, dynamic> json) {
    final factors = (json['gunaFactors'] as List<dynamic>? ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .toList(growable: false);
    final labels = <String, String>{
      for (final f in factors) f['key'] as String: f['label'] as String,
    };
    return BiyeLagnoData(
      sampleProfiles: (json['sampleProfiles'] as List<dynamic>)
          .map((e) => BiyeLagnoProfile.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      factorLabels: labels,
    );
  }
}
