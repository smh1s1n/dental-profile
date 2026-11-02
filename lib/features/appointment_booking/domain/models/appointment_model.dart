import 'patient_model.dart';

enum AppointmentStatus {
  booked, // বুক করা হয়েছে
  called, // সিরিয়াল ডাকা হয়েছে
  inChamber, // ডাক্তারের কামরায় উপস্থিত
  completed, // চিকিৎসা সম্পন্ন
  absent, // সাময়িক অনুপস্থিত
  emergency, // জরুরি অগ্রাধিকার
}

enum PaymentMethod {
  cashAtChamber,
  bKash,
  nagad,
}

enum PaymentStatus {
  pending,
  paid,
}

class AppointmentModel {
  final String id; // Token ID e.g. DENT-8921
  final String chamberId;
  final String chamberName;
  final int serialNumber;
  final String appointmentDate; // YYYY-MM-DD
  final String slotTime;
  final PatientModel patient;
  final AppointmentStatus status;
  final int consultationFee;
  final bool isFollowUp;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? trxId;
  final DateTime createdAt;
  final String? doctorNotes;

  const AppointmentModel({
    required this.id,
    required this.chamberId,
    required this.chamberName,
    required this.serialNumber,
    required this.appointmentDate,
    required this.slotTime,
    required this.patient,
    required this.status,
    required this.consultationFee,
    this.isFollowUp = false,
    this.paymentMethod = PaymentMethod.cashAtChamber,
    this.paymentStatus = PaymentStatus.pending,
    this.trxId,
    required this.createdAt,
    this.doctorNotes,
  });

  String get statusDisplayEn {
    switch (status) {
      case AppointmentStatus.booked:
        return 'Waiting / Queued';
      case AppointmentStatus.called:
        return 'CALLED (Proceed to Room)';
      case AppointmentStatus.inChamber:
        return 'In Consultation';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.absent:
        return 'Absent / Delayed';
      case AppointmentStatus.emergency:
        return 'EMERGENCY PRIORITY';
    }
  }

  String get statusDisplayBn {
    switch (status) {
      case AppointmentStatus.booked:
        return 'অপেক্ষমান';
      case AppointmentStatus.called:
        return 'ডাকা হয়েছে (ভেতরে আসুন)';
      case AppointmentStatus.inChamber:
        return 'পরীক্ষা চলছে';
      case AppointmentStatus.completed:
        return 'সম্পন্ন';
      case AppointmentStatus.absent:
        return 'অনুপস্থিত';
      case AppointmentStatus.emergency:
        return 'জরুরি অগ্রাধিকার';
    }
  }

  AppointmentModel copyWith({
    String? id,
    String? chamberId,
    String? chamberName,
    int? serialNumber,
    String? appointmentDate,
    String? slotTime,
    PatientModel? patient,
    AppointmentStatus? status,
    int? consultationFee,
    bool? isFollowUp,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? trxId,
    DateTime? createdAt,
    String? doctorNotes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      chamberId: chamberId ?? this.chamberId,
      chamberName: chamberName ?? this.chamberName,
      serialNumber: serialNumber ?? this.serialNumber,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      slotTime: slotTime ?? this.slotTime,
      patient: patient ?? this.patient,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      isFollowUp: isFollowUp ?? this.isFollowUp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      trxId: trxId ?? this.trxId,
      createdAt: createdAt ?? this.createdAt,
      doctorNotes: doctorNotes ?? this.doctorNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chamberId': chamberId,
      'chamberName': chamberName,
      'serialNumber': serialNumber,
      'appointmentDate': appointmentDate,
      'slotTime': slotTime,
      'patient': patient.toJson(),
      'status': status.name,
      'consultationFee': consultationFee,
      'isFollowUp': isFollowUp,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'trxId': trxId,
      'createdAt': createdAt.toIso8601String(),
      'doctorNotes': doctorNotes,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      chamberId: json['chamberId'] as String,
      chamberName: json['chamberName'] as String,
      serialNumber: json['serialNumber'] as int,
      appointmentDate: json['appointmentDate'] as String,
      slotTime: json['slotTime'] as String,
      patient: PatientModel.fromJson(json['patient'] as Map<String, dynamic>),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.booked,
      ),
      consultationFee: json['consultationFee'] as int,
      isFollowUp: json['isFollowUp'] as bool? ?? false,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cashAtChamber,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      trxId: json['trxId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      doctorNotes: json['doctorNotes'] as String?,
    );
  }
}
