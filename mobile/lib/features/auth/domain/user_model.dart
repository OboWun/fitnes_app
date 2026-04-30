class UserModel {
  final String id;
  final String deviceId;
  final String? name;
  final int? weight;
  final int? height;
  final int? age;
  final String? gender;
  final List<String>? contraindications;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.deviceId,
    this.name,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.contraindications,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      name: json['name'] as String?,
      weight: json['weight'] as int?,
      height: json['height'] as int?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      contraindications: (json['contraindications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'contraindications': contraindications,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? deviceId,
    String? name,
    int? weight,
    int? height,
    int? age,
    String? gender,
    List<String>? contraindications,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contraindications: contraindications ?? this.contraindications,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isProfileComplete => name != null && name!.isNotEmpty && gender != null && gender!.isNotEmpty;
}
