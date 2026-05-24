class Hospital {
  final String id;
  final String name;
  final String district;
  final String address;
  final String phone;
  final String type;

  Hospital({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.phone,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'district': district,
        'address': address,
        'phone': phone,
        'type': type,
      };

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        id: json['id'] as String,
        name: json['name'] as String,
        district: json['district'] as String,
        address: json['address'] as String,
        phone: json['phone'] as String,
        type: json['type'] as String,
      );
}
