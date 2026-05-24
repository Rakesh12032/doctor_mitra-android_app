class AppUser {
  final String id;
  final String role;
  final String name;
  final String mobile;
  final String email;
  final String? password;
  final String district;
  final String createdAt;

  AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.mobile,
    required this.email,
    this.password,
    required this.district,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
        'district': district,
        'createdAt': createdAt,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        role: json['role'] as String,
        name: json['name'] as String,
        mobile: json['mobile'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String?,
        district: json['district'] as String? ?? 'Patna',
        createdAt: json['createdAt'] as String,
      );

  AppUser copyWith({String? name, String? mobile, String? district}) => AppUser(
        id: id,
        role: role,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email,
        password: password,
        district: district ?? this.district,
        createdAt: createdAt,
      );
}
