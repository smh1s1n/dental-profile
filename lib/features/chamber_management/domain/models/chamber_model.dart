class ChamberModel {
  final String id;
  final String name;
  final String bnName;
  final String locationArea;
  final String fullAddress;
  final String phoneContact;
  final String mapUrl;
  final List<String> activeDays; // e.g. ['Sat', 'Mon', 'Wed']
  final String activeDaysBn; // e.g. 'শনি, সোম ও বুধবার'
  final String scheduleTime; // e.g. '5:30 PM - 10:00 PM'
  final int regularFee; // e.g. 1000 BDT
  final int followUpFee; // e.g. 500 BDT
  final int maxPatientsPerDay;
  final List<String> facilities;
  final String compounderName;

  const ChamberModel({
    required this.id,
    required this.name,
    required this.bnName,
    required this.locationArea,
    required this.fullAddress,
    required this.phoneContact,
    required this.mapUrl,
    required this.activeDays,
    required this.activeDaysBn,
    required this.scheduleTime,
    required this.regularFee,
    required this.followUpFee,
    required this.maxPatientsPerDay,
    required this.facilities,
    required this.compounderName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bnName': bnName,
      'locationArea': locationArea,
      'fullAddress': fullAddress,
      'phoneContact': phoneContact,
      'mapUrl': mapUrl,
      'activeDays': activeDays,
      'activeDaysBn': activeDaysBn,
      'scheduleTime': scheduleTime,
      'regularFee': regularFee,
      'followUpFee': followUpFee,
      'maxPatientsPerDay': maxPatientsPerDay,
      'facilities': facilities,
      'compounderName': compounderName,
    };
  }

  factory ChamberModel.fromJson(Map<String, dynamic> json) {
    return ChamberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bnName: json['bnName'] as String,
      locationArea: json['locationArea'] as String,
      fullAddress: json['fullAddress'] as String,
      phoneContact: json['phoneContact'] as String,
      mapUrl: json['mapUrl'] as String,
      activeDays: List<String>.from(json['activeDays'] as List),
      activeDaysBn: json['activeDaysBn'] as String,
      scheduleTime: json['scheduleTime'] as String,
      regularFee: json['regularFee'] as int,
      followUpFee: json['followUpFee'] as int,
      maxPatientsPerDay: json['maxPatientsPerDay'] as int,
      facilities: List<String>.from(json['facilities'] as List),
      compounderName: json['compounderName'] as String,
    );
  }
}
