class AmbulanceProviderModel {
  final String id;
  final String name;
  final String district;
  final String phone;
  final bool isAvailable;

  AmbulanceProviderModel({
    required this.id,
    required this.name,
    required this.district,
    required this.phone,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'district': district,
        'phone': phone,
        'isAvailable': isAvailable,
      };

  factory AmbulanceProviderModel.fromJson(Map<String, dynamic> json) =>
      AmbulanceProviderModel(
        id: json['id'] as String,
        name: json['name'] as String,
        district: json['district'] as String,
        phone: json['phone'] as String,
        isAvailable: json['isAvailable'] as bool,
      );
}

class AmbulanceRequest {
  final String id;
  final String patientId;
  final String patientName;
  final String patientMobile;
  final String district;
  final String pickupAddress;
  final String emergencyType;
  final String providerId;
  final String status;
  final String createdAt;

  AmbulanceRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientMobile,
    required this.district,
    required this.pickupAddress,
    required this.emergencyType,
    required this.providerId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'patientMobile': patientMobile,
        'district': district,
        'pickupAddress': pickupAddress,
        'emergencyType': emergencyType,
        'providerId': providerId,
        'status': status,
        'createdAt': createdAt,
      };

  factory AmbulanceRequest.fromJson(Map<String, dynamic> json) =>
      AmbulanceRequest(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        patientMobile: json['patientMobile'] as String,
        district: json['district'] as String,
        pickupAddress: json['pickupAddress'] as String,
        emergencyType: json['emergencyType'] as String,
        providerId: json['providerId'] as String? ?? '',
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
      );

  AmbulanceRequest copyWith({String? status}) => AmbulanceRequest(
        id: id,
        patientId: patientId,
        patientName: patientName,
        patientMobile: patientMobile,
        district: district,
        pickupAddress: pickupAddress,
        emergencyType: emergencyType,
        providerId: providerId,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
