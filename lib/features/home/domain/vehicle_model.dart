class Vehicle {
  final int? userCarId;
  final String? carBrand;
  final String? carColor;
  final String? carModel;
  final String? carPlate;
  final int? carTypeId;
  final String? userId;
  final DateTime? createdAt;

  Vehicle({
    this.userCarId,
    this.carBrand,
    this.carColor,
    this.carModel,
    this.carPlate,
    this.carTypeId,
    this.userId,
    this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      userCarId: json['userCarId'],
      carBrand: json['carBrand'],
      carColor: json['carColor'],
      carModel: json['carModel'],
      carPlate: json['carPlate'],
      carTypeId: json['carTypeId'],
      userId: json['userId'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userCarId != null) 'userCarId': userCarId,
      'carBrand': carBrand,
      'carColor': carColor,
      'carModel': carModel,
      'carPlate': carPlate,
      'carTypeId': carTypeId,
      if (userId != null) 'userId': userId,
    };
  }
}

class VehicleType {
  final int carTypeId;
  final String carTypeName;

  VehicleType({
    required this.carTypeId,
    required this.carTypeName,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      carTypeId: json['carTypeId'],
      carTypeName: json['carTypeName'],
    );
  }
}
