enum DoctorChamberStatus {
  inChamber, // চেম্বারে উপস্থিত আছেন
  inTransit, // চেম্বারের উদ্দেশ্যে পথে আছেন
  inSurgery, // জরুরি চিকিৎসায় ব্যস্ত
  onBreak, // সাময়িক বিরতি
  closed, // চেম্বার বন্ধ
}

class ChamberQueueState {
  final String chamberId;
  final String chamberName;
  final String date;
  final int activeSerial;
  final String? activePatientName;
  final DoctorChamberStatus doctorStatus;
  final String? delayNotice;
  final int completedCount;
  final int waitingCount;
  final int totalBooked;
  final DateTime lastUpdated;

  const ChamberQueueState({
    required this.chamberId,
    required this.chamberName,
    required this.date,
    required this.activeSerial,
    this.activePatientName,
    this.doctorStatus = DoctorChamberStatus.inChamber,
    this.delayNotice,
    required this.completedCount,
    required this.waitingCount,
    required this.totalBooked,
    required this.lastUpdated,
  });

  String get doctorStatusLabelEn {
    switch (doctorStatus) {
      case DoctorChamberStatus.inChamber:
        return 'Doctor is IN CHAMBER';
      case DoctorChamberStatus.inTransit:
        return 'Doctor IN TRANSIT (On the way)';
      case DoctorChamberStatus.inSurgery:
        return 'Doctor in Procedure / Minor Surgery';
      case DoctorChamberStatus.onBreak:
        return 'Prayer / Evening Break';
      case DoctorChamberStatus.closed:
        return 'Chamber Closed Today';
    }
  }

  String get doctorStatusLabelBn {
    switch (doctorStatus) {
      case DoctorChamberStatus.inChamber:
        return 'ডাক্তার চেম্বারে উপস্থিত আছেন';
      case DoctorChamberStatus.inTransit:
        return 'ডাক্তার পথে আছেন (শীঘ্রই পৌঁছাবেন)';
      case DoctorChamberStatus.inSurgery:
        return 'ডাক্তার অস্ত্রোপচার/চিকিৎসায় ব্যস্ত';
      case DoctorChamberStatus.onBreak:
        return 'নামাজ ও চা বিরতি';
      case DoctorChamberStatus.closed:
        return 'আজকের চেম্বার বন্ধ';
    }
  }

  ChamberQueueState copyWith({
    String? chamberId,
    String? chamberName,
    String? date,
    int? activeSerial,
    String? activePatientName,
    DoctorChamberStatus? doctorStatus,
    String? delayNotice,
    int? completedCount,
    int? waitingCount,
    int? totalBooked,
    DateTime? lastUpdated,
  }) {
    return ChamberQueueState(
      chamberId: chamberId ?? this.chamberId,
      chamberName: chamberName ?? this.chamberName,
      date: date ?? this.date,
      activeSerial: activeSerial ?? this.activeSerial,
      activePatientName: activePatientName ?? this.activePatientName,
      doctorStatus: doctorStatus ?? this.doctorStatus,
      delayNotice: delayNotice ?? this.delayNotice,
      completedCount: completedCount ?? this.completedCount,
      waitingCount: waitingCount ?? this.waitingCount,
      totalBooked: totalBooked ?? this.totalBooked,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chamberId': chamberId,
      'chamberName': chamberName,
      'date': date,
      'activeSerial': activeSerial,
      'activePatientName': activePatientName,
      'doctorStatus': doctorStatus.name,
      'delayNotice': delayNotice,
      'completedCount': completedCount,
      'waitingCount': waitingCount,
      'totalBooked': totalBooked,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ChamberQueueState.fromJson(Map<String, dynamic> json) {
    return ChamberQueueState(
      chamberId: json['chamberId'] as String,
      chamberName: json['chamberName'] as String,
      date: json['date'] as String,
      activeSerial: json['activeSerial'] as int,
      activePatientName: json['activePatientName'] as String?,
      doctorStatus: DoctorChamberStatus.values.firstWhere(
        (e) => e.name == json['doctorStatus'],
        orElse: () => DoctorChamberStatus.inChamber,
      ),
      delayNotice: json['delayNotice'] as String?,
      completedCount: json['completedCount'] as int,
      waitingCount: json['waitingCount'] as int,
      totalBooked: json['totalBooked'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
