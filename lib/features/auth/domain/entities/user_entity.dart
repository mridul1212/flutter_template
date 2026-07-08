import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.district,
    this.dateOfBirth,
    this.timeOfBirth,
    this.birthPlace,
    this.gender,
    this.isProfileComplete = false,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? district;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? birthPlace;
  final String? gender;
  final bool isProfileComplete;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? district,
    String? dateOfBirth,
    String? timeOfBirth,
    String? birthPlace,
    String? gender,
    bool? isProfileComplete,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      district: district ?? this.district,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'district': district,
        'dateOfBirth': dateOfBirth,
        'timeOfBirth': timeOfBirth,
        'birthPlace': birthPlace,
        'gender': gender,
        'isProfileComplete': isProfileComplete,
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      district: json['district'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      timeOfBirth: json['timeOfBirth'] as String?,
      birthPlace: json['birthPlace'] as String?,
      gender: json['gender'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        district,
        dateOfBirth,
        timeOfBirth,
        birthPlace,
        gender,
        isProfileComplete,
      ];
}
