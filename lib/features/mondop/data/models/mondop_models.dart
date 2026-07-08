/// Default map center — Dhaka, Bangladesh.
const kBangladeshMapCenter = MapPosition(23.8103, 90.4125);

/// Simple lat/lng pair (no Google Maps dependency).
class MapPosition {
  const MapPosition(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class MondopReview {
  MondopReview({required this.id, required this.user, required this.rating, required this.comment, required this.date});

  final String id;
  final String user;
  final int rating;
  final String comment;
  final String date;

  factory MondopReview.fromJson(Map<String, dynamic> json) {
    return MondopReview(
      id: json['id'] as String,
      user: json['user'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
}

class MondopReviewSummary {
  MondopReviewSummary({required this.averageRating, required this.reviewCount, required this.items});

  final double averageRating;
  final int reviewCount;
  final List<MondopReview> items;

  factory MondopReviewSummary.fromJson(Map<String, dynamic> json) {
    return MondopReviewSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MondopReview.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
    );
  }
}

class MondopTiming {
  MondopTiming({required this.label, required this.time});

  final String label;
  final String time;

  factory MondopTiming.fromJson(Map<String, dynamic> json) {
    return MondopTiming(
      label: json['label'] as String,
      time: json['time'] as String,
    );
  }
}

class MondopDetail {
  MondopDetail({
    required this.address,
    required this.description,
    required this.organizer,
    required this.phone,
    required this.timings,
    required this.highlights,
    this.capacity,
    this.parking,
  });

  final String address;
  final String description;
  final String organizer;
  final String phone;
  final List<MondopTiming> timings;
  final List<String> highlights;
  final String? capacity;
  final String? parking;

  factory MondopDetail.fromJson(Map<String, dynamic> json) {
    return MondopDetail(
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      timings: (json['timings'] as List<dynamic>?)
              ?.map((e) => MondopTiming.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e as String).toList(growable: false) ?? const [],
      capacity: json['capacity'] as String?,
      parking: json['parking'] as String?,
    );
  }
}

class MondopItem {
  MondopItem({
    required this.id,
    required this.name,
    required this.theme,
    required this.area,
    required this.lat,
    required this.lng,
    required this.index,
    this.detail,
    this.rating,
    this.reviewCount,
  });

  final String id;
  final String name;
  final String theme;
  final String area;
  final double lat;
  final double lng;
  final int index;
  final MondopDetail? detail;
  final double? rating;
  final int? reviewCount;

  MapPosition get position => MapPosition(lat, lng);

  factory MondopItem.fromJson(Map<String, dynamic> json, int index) {
    final detailJson = json['detail'];
    return MondopItem(
      id: json['id'] as String,
      name: json['name'] as String,
      theme: json['theme'] as String,
      area: json['area'] as String? ?? 'Bangladesh',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      index: index,
      detail: detailJson is Map<String, dynamic> ? MondopDetail.fromJson(detailJson) : null,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
    );
  }
}

class MondopWithDistance {
  MondopWithDistance(this.mondop, this.km);

  final MondopItem mondop;
  final double? km;
}
