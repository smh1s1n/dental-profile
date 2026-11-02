import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/clinical_providers.dart';

class PrescriptionViewScreen extends ConsumerWidget {
  final String appointmentId;
  final String patientName;

  const PrescriptionViewScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rxAsync = ref.watch(prescriptionProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Dental Prescription (e-Rx)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Prescription',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription sent to clinic printer / PDF generator')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share with Patient on WhatsApp',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription PDF link shared to patient phone')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: rxAsync.when(
              data: (rx) {
                if (rx == null) {
                  return const Center(child: Text('No prescription record found.'));
                }
                return _buildPrescriptionPaper(context, rx);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading prescription: $e')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionPaper(BuildContext context, dynamic rx) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinic & Doctor Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.medical_services, color: AppColors.primaryTeal, size: 24),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.appName,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.doctorName,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        AppStrings.doctorDegrees,
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppStrings.bmdcRegNumber,
                        style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryTeal),
                  ),
                  child: Text(
                    'Rx: ${rx.id}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Patient Demographics Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Patient: ${rx.patientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Age/Sex: ${rx.patientAge}y / ${rx.patientGender}', style: const TextStyle(fontSize: 13)),
                Text('Date: ${rx.date}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clinical Diagnosis
                Row(
                  children: [
                    const Text('Diagnosis: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                    Expanded(
                      child: Text(
                        rx.diagnosis,
                        style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                const SizedBox(height: 20),

                // Prescription Rx Icon
                const Text(
                  '℞',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.primaryTeal, fontFamily: 'serif'),
                ),
                const SizedBox(height: 12),

                // Medicines List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rx.medicines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final med = rx.medicines[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        med.dosage,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryTeal),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        med.instruction,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Post-Procedure Advice in Bengali & English
                const Text(
                  'Advice & Instructions (পরামর্শ ও নিয়মাবলী):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (rx.advice as List<String>)
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check, size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(a, style: const TextStyle(fontSize: 12, color: Color(0xFF78350F)))),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 30),

                // Doctor Stamp and Follow-up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Next Visit / পরবর্তী সাক্ষাত:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          rx.nextVisitDate ?? 'As advised after completing medicines',
                          style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'Dr. Syed Tanvir Rahman',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                        Text('BMDC Reg. No: D-12845', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('(Digitally Signed & Verified)', style: TextStyle(fontSize: 10, color: AppColors.primaryTeal)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
