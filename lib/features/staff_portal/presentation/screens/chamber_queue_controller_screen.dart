import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../appointment_booking/domain/models/appointment_model.dart';
import '../../../appointment_booking/domain/models/patient_model.dart';
import '../../../appointment_booking/presentation/providers/appointment_providers.dart';
import '../../../clinical_records/presentation/screens/dental_chart_screen.dart';
import '../../../clinical_records/presentation/screens/prescription_view_screen.dart';
import '../../../live_serial_queue/domain/models/chamber_queue_state.dart';
import '../providers/staff_providers.dart';
import 'staff_login_screen.dart';

class ChamberQueueControllerScreen extends ConsumerStatefulWidget {
  const ChamberQueueControllerScreen({super.key});

  @override
  ConsumerState<ChamberQueueControllerScreen> createState() => _ChamberQueueControllerScreenState();
}

class _ChamberQueueControllerScreenState extends ConsumerState<ChamberQueueControllerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _delayNoticeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _delayNoticeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authStateNotifierProvider);
    final selectedChamberId = ref.watch(selectedChamberIdProvider);
    final chambers = MockData.chambers;
    final currentChamber = chambers.firstWhere((c) => c.id == selectedChamberId, orElse: () => chambers.first);
    final queueAsync = ref.watch(chamberQueueNotifierProvider(selectedChamberId));
    final appointmentsAsync = ref.watch(appointmentsListProvider(selectedChamberId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${session?.name ?? "Staff Portal"} (${session?.isDoctor == true ? "Doctor" : "Compounder"})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Live Queue Controller • ${currentChamber.name}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          // Emergency Walk-in Button
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.statusNowServing),
            tooltip: 'Add Walk-in Patient (জরুরি রোগী)',
            onPressed: () => _showAddWalkInDialog(currentChamber),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authStateNotifierProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chamber Switcher & Doctor Status Control Strip
          _buildChamberAndDoctorStatusStrip(currentChamber, queueAsync.value),

          // Quick Action Bar for Calling Serials
          if (queueAsync.value != null) _buildQueueActionControlBar(queueAsync.value!, appointmentsAsync.value ?? []),

          // Tabs: All, Waiting, In Consultation, Completed
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryTeal,
              indicatorColor: AppColors.primaryTeal,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'All Serials (সকল)'),
                Tab(text: 'Waiting (অপেক্ষমান)'),
                Tab(text: 'In Chamber (ভেতরে)'),
                Tab(text: 'Completed (সম্পন্ন)'),
              ],
            ),
          ),

          // Patient Queue List Views
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPatientList(appointments),
                    _buildPatientList(appointments.where((a) => a.status == AppointmentStatus.booked || a.status == AppointmentStatus.called).toList()),
                    _buildPatientList(appointments.where((a) => a.status == AppointmentStatus.inChamber).toList()),
                    _buildPatientList(appointments.where((a) => a.status == AppointmentStatus.completed).toList()),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChamberAndDoctorStatusStrip(dynamic currentChamber, ChamberQueueState? queue) {
    final chambers = MockData.chambers;
    final selectedChamberId = ref.watch(selectedChamberIdProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: selectedChamberId,
            underline: const SizedBox.shrink(),
            items: chambers
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(selectedChamberIdProvider.notifier).setChamber(val);
              }
            },
          ),
          const Spacer(),
          if (queue != null) ...[
            TextButton.icon(
              onPressed: () => _showDoctorStatusDialog(currentChamber.id, queue),
              icon: Icon(
                Icons.circle,
                size: 10,
                color: queue.doctorStatus == DoctorChamberStatus.inChamber ? AppColors.statusNowServing : Colors.amber,
              ),
              label: Text(
                queue.doctorStatusLabelEn,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueueActionControlBar(ChamberQueueState queue, List<AppointmentModel> appointments) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.statusNowServing, shape: BoxShape.circle),
                child: Text(
                  queue.activeSerial > 0 ? '#${queue.activeSerial}' : '--',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACTIVE SERIAL', style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    queue.activePatientName ?? 'No Patient Called',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          // Primary Quick Action Buttons
          Wrap(
            spacing: 8,
            children: [
              // Call Next Serial
              ElevatedButton.icon(
                onPressed: () => _callNextSerial(queue, appointments),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusNowServing,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                icon: const Icon(Icons.campaign, size: 18),
                label: const Text('Call Next (পরবর্তী সিরিয়াল)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              // Mark In Chamber
              OutlinedButton.icon(
                onPressed: queue.activeSerial > 0 ? () => _markActiveInChamber(queue, appointments) : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white60),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                icon: const Icon(Icons.meeting_room, size: 16),
                label: const Text('In Chamber', style: TextStyle(fontSize: 12)),
              ),
              // Mark Completed
              ElevatedButton.icon(
                onPressed: queue.activeSerial > 0 ? () => _markActiveCompleted(queue, appointments) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Complete', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(List<AppointmentModel> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No appointments in this category.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final apt = list[index];
        final isCurrent = apt.status == AppointmentStatus.called || apt.status == AppointmentStatus.inChamber;

        return Card(
          color: isCurrent ? AppColors.statusNowServing.withOpacity(0.06) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurrent ? AppColors.statusNowServing : AppColors.surfaceBorder,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.statusNowServing : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '#${apt.serialNumber}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                apt.patient.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              Text('(${apt.patient.age}y, ${apt.patient.gender})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phone: ${apt.patient.phone} • Slot: ${apt.slotTime} • Token: ${apt.id}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complaint: ${apt.patient.chiefComplaint}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          ),
                          if (apt.patient.medicalConditions.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: apt.patient.medicalConditions
                                  .map((c) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Text(c.split('/').first.trim(), style: TextStyle(color: Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status Badge & Payment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(apt.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            apt.statusDisplayEn,
                            style: TextStyle(color: _getStatusColor(apt.status), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _togglePayment(apt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: apt.paymentStatus == PaymentStatus.paid ? Colors.green.shade50 : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: apt.paymentStatus == PaymentStatus.paid ? Colors.green : Colors.amber,
                              ),
                            ),
                            child: Text(
                              apt.paymentStatus == PaymentStatus.paid ? 'PAID (৳${apt.consultationFee})' : 'DUE: ৳${apt.consultationFee}',
                              style: TextStyle(
                                color: apt.paymentStatus == PaymentStatus.paid ? Colors.green.shade800 : Colors.amber.shade900,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Per-patient Control Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Clinical Records (Doctor only / or shared)
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DentalChartScreen(
                                  patientPhoneOrId: apt.patient.phone,
                                  patientName: apt.patient.name,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shield, size: 16, color: AppColors.primaryTeal),
                          label: const Text('Dental Chart', style: TextStyle(fontSize: 12, color: AppColors.primaryTeal)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PrescriptionViewScreen(
                                  appointmentId: apt.id,
                                  patientName: apt.patient.name,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 16, color: AppColors.royalBlue),
                          label: const Text('e-Prescription', style: TextStyle(fontSize: 12, color: AppColors.royalBlue)),
                        ),
                      ],
                    ),

                    // Quick Action Menu
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.campaign, color: AppColors.statusNowServing, size: 20),
                          tooltip: 'Call Serial',
                          onPressed: () => _updateAptStatus(apt, AppointmentStatus.called),
                        ),
                        IconButton(
                          icon: const Icon(Icons.meeting_room, color: AppColors.primaryTeal, size: 20),
                          tooltip: 'Mark In Chamber',
                          onPressed: () => _updateAptStatus(apt, AppointmentStatus.inChamber),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.royalBlue, size: 20),
                          tooltip: 'Mark Completed',
                          onPressed: () => _updateAptStatus(apt, AppointmentStatus.completed),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_off, color: AppColors.statusAbsent, size: 20),
                          tooltip: 'Mark Absent / Delayed',
                          onPressed: () => _updateAptStatus(apt, AppointmentStatus.absent),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.called:
      case AppointmentStatus.inChamber:
        return AppColors.statusNowServing;
      case AppointmentStatus.booked:
        return AppColors.statusWaiting;
      case AppointmentStatus.completed:
        return AppColors.statusCompleted;
      case AppointmentStatus.absent:
        return AppColors.statusAbsent;
      case AppointmentStatus.emergency:
        return AppColors.statusEmergency;
    }
  }

  Future<void> _callNextSerial(ChamberQueueState queue, List<AppointmentModel> appointments) async {
    // Find next uncalled patient
    final next = appointments.where((a) => a.serialNumber > queue.activeSerial && a.status != AppointmentStatus.completed).toList();

    if (next.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No further queued patients waiting.')),
      );
      return;
    }

    final target = next.first;
    await _updateAptStatus(target, AppointmentStatus.called);
  }

  Future<void> _markActiveInChamber(ChamberQueueState queue, List<AppointmentModel> appointments) async {
    try {
      final active = appointments.firstWhere((a) => a.serialNumber == queue.activeSerial);
      await _updateAptStatus(active, AppointmentStatus.inChamber);
    } catch (_) {}
  }

  Future<void> _markActiveCompleted(ChamberQueueState queue, List<AppointmentModel> appointments) async {
    try {
      final active = appointments.firstWhere((a) => a.serialNumber == queue.activeSerial);
      await _updateAptStatus(active, AppointmentStatus.completed);
    } catch (_) {}
  }

  Future<void> _updateAptStatus(AppointmentModel apt, AppointmentStatus newStatus) async {
    final repo = ref.read(appointmentRepositoryProvider);
    await repo.updateStatus(appointmentId: apt.id, newStatus: newStatus);

    ref.invalidate(appointmentsListProvider(apt.chamberId));
    ref.invalidate(chamberQueueNotifierProvider(apt.chamberId));
  }

  Future<void> _togglePayment(AppointmentModel apt) async {
    final newStatus = apt.paymentStatus == PaymentStatus.paid ? PaymentStatus.pending : PaymentStatus.paid;
    final repo = ref.read(appointmentRepositoryProvider);
    await repo.updatePayment(appointmentId: apt.id, paymentStatus: newStatus);
    ref.invalidate(appointmentsListProvider(apt.chamberId));
  }

  void _showDoctorStatusDialog(String chamberId, ChamberQueueState queue) {
    DoctorChamberStatus selected = queue.doctorStatus;
    _delayNoticeController.text = queue.delayNotice ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Update Doctor Chamber Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<DoctorChamberStatus>(
                    value: selected,
                    decoration: const InputDecoration(labelText: 'Presence Status'),
                    items: DoctorChamberStatus.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selected = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _delayNoticeController,
                    decoration: const InputDecoration(
                      labelText: 'Broadcast Delay / Traffic Notice (optional)',
                      hintText: 'e.g. Doctor running 15 mins late due to Dhaka traffic',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(appointmentRepositoryProvider);
                    await repo.updateDoctorChamberStatus(
                      chamberId: chamberId,
                      status: selected,
                      delayNotice: _delayNoticeController.text.trim().isEmpty ? null : _delayNoticeController.text.trim(),
                    );
                    ref.invalidate(chamberQueueNotifierProvider(chamberId));
                    if (!mounted) return;
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Broadcast Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddWalkInDialog(dynamic chamber) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '32');
    final complaintCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Register Walk-in Patient (জরুরি রোগী)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Patient Full Name *')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Phone *')),
                const SizedBox(height: 10),
                TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')),
                const SizedBox(height: 10),
                TextField(controller: complaintCtrl, decoration: const InputDecoration(labelText: 'Chief Complaint / Urgent Concern')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;

                final today = DateTime.now();
                final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

                final patient = PatientModel(
                  name: nameCtrl.text.trim(),
                  age: int.tryParse(ageCtrl.text.trim()) ?? 30,
                  gender: 'Male',
                  phone: phoneCtrl.text.trim(),
                  addressArea: chamber.locationArea,
                  medicalConditions: const ['Emergency Walk-in'],
                  chiefComplaint: complaintCtrl.text.trim().isEmpty ? 'Acute Dental Pain' : complaintCtrl.text.trim(),
                  painScale: 9,
                );

                final repo = ref.read(appointmentRepositoryProvider);
                await repo.bookAppointment(
                  chamberId: chamber.id,
                  chamberName: chamber.name,
                  date: dateStr,
                  slotTime: 'Walk-in Urgent',
                  patient: patient,
                  consultationFee: chamber.regularFee,
                  isFollowUp: false,
                  paymentMethod: PaymentMethod.cashAtChamber,
                );

                ref.invalidate(appointmentsListProvider(chamber.id));
                ref.invalidate(chamberQueueNotifierProvider(chamber.id));

                if (!mounted) return;
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Walk-in patient assigned next available serial!')),
                );
              },
              child: const Text('Assign Serial'),
            ),
          ],
        );
      },
    );
  }
}
