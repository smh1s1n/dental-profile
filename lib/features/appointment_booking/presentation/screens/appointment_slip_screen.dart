import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bangla_formatter.dart';
import '../../domain/models/appointment_model.dart';
import '../../../live_serial_queue/presentation/screens/live_serial_tracker_screen.dart';
import '../../../doctor_portfolio/presentation/screens/doctor_profile_screen.dart';

class AppointmentSlipScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentSlipScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final patient = appointment.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Token / সিরিয়াল রসিদ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Digital Ticket Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      // Header with Doctor & Chamber Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.medical_services, color: AppColors.primaryTeal, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'SmileCraft Dental Care',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    appointment.id,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              AppStrings.doctorName,
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              AppStrings.bmdcRegNumber,
                              style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // Serial Number Highlight Section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        color: const Color(0xFFF0FDFA),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'YOUR SERIAL NUMBER',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal, letterSpacing: 1),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '#${appointment.serialNumber}',
                                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '(নং ${BanglaFormatter.toBanglaNumber(appointment.serialNumber)})',
                                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Dynamic QR Code for receptionist quick scanner
                            QrImageView(
                              data: 'SMILECRAFT:${appointment.id}:${appointment.patient.phone}:${appointment.serialNumber}',
                              version: QrVersions.auto,
                              size: 80.0,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ),

                      // Perforated Line Decoration
                      Row(
                        children: List.generate(
                          30,
                          (i) => Expanded(
                            child: Container(
                              height: 2,
                              color: i.isEven ? AppColors.surfaceBorder : Colors.transparent,
                            ),
                          ),
                        ),
                      ),

                      // Appointment Details Body
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildInfoRow('Chamber Location', appointment.chamberName),
                            const SizedBox(height: 12),
                            _buildInfoRow('Appointment Date', '${appointment.appointmentDate} (${appointment.slotTime})'),
                            const SizedBox(height: 12),
                            _buildInfoRow('Patient Name', '${patient.name} (${patient.age}y, ${patient.gender})'),
                            const SizedBox(height: 12),
                            _buildInfoRow('Contact Phone', patient.phone),
                            const SizedBox(height: 12),
                            _buildInfoRow('Chief Complaint', patient.chiefComplaint),
                            const SizedBox(height: 12),
                            _buildInfoRow('Consultation Fee', BanglaFormatter.formatBdt(appointment.consultationFee)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Payment Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: appointment.paymentStatus == PaymentStatus.paid ? AppColors.statusNowServing.withOpacity(0.15) : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    appointment.paymentStatus == PaymentStatus.paid
                                        ? 'PAID (${appointment.paymentMethod.name.toUpperCase()})'
                                        : 'DUE AT CHAMBER (৳${appointment.consultationFee})',
                                    style: TextStyle(
                                      color: appointment.paymentStatus == PaymentStatus.paid ? AppColors.statusNowServing : Colors.amber.shade900,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bilingual Instructions Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppStrings.arrivalNoticeBn,
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Primary Action: Track Live Serial Right Now!
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LiveSerialTrackerScreen(initialTokenOrPhone: appointment.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.radar, size: 20),
                    label: const Text(
                      'Track Live Serial Status (লাইভ সিরিয়াল ট্র্যাক করুন)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Appointment token slip ready for print / screenshot!')),
                          );
                        },
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: const Text('Save / Print'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Token ${appointment.id} details copied for WhatsApp sharing!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share Slip'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
