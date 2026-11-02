import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/utils/bangla_formatter.dart';
import '../../../appointment_booking/domain/models/appointment_model.dart';
import '../../../appointment_booking/presentation/providers/appointment_providers.dart';
import '../../domain/models/chamber_queue_state.dart';

class LiveSerialTrackerScreen extends ConsumerStatefulWidget {
  final String? initialTokenOrPhone;

  const LiveSerialTrackerScreen({super.key, this.initialTokenOrPhone});

  @override
  ConsumerState<LiveSerialTrackerScreen> createState() => _LiveSerialTrackerScreenState();
}

class _LiveSerialTrackerScreenState extends ConsumerState<LiveSerialTrackerScreen> {
  final _searchController = TextEditingController();
  AppointmentModel? _searchedAppointment;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTokenOrPhone != null) {
      _searchController.text = widget.initialTokenOrPhone!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final repo = ref.read(appointmentRepositoryProvider);

    // Try by Token ID first
    var appointment = await repo.getAppointmentById(query);

    // If not found, try by phone
    if (appointment == null) {
      final list = await repo.getAppointmentsByPhone(query);
      if (list.isNotEmpty) {
        appointment = list.last; // Most recent appointment
      }
    }

    setState(() {
      _searchedAppointment = appointment;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedChamberId = ref.watch(selectedChamberIdProvider);
    final chambers = MockData.chambers;
    final queueAsync = ref.watch(chamberQueueNotifierProvider(selectedChamberId));
    final appointmentsAsync = ref.watch(appointmentsListProvider(selectedChamberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Serial Tracker / লাইভ সিরিয়াল', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Queue',
            onPressed: () {
              ref.invalidate(chamberQueueNotifierProvider(selectedChamberId));
              ref.invalidate(appointmentsListProvider(selectedChamberId));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chamber Selector Segment
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: chambers.map((chamber) {
                      final isSelected = chamber.id == selectedChamberId;
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            ref.read(selectedChamberIdProvider.notifier).setChamber(chamber.id);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              chamber.locationArea.split(',').first,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Live Active Queue Display
                queueAsync.when(
                  data: (queue) => _buildLiveQueueCard(queue),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading queue: $e'),
                ),

                const SizedBox(height: 24),

                // Patient Personal Token Search Bar
                _buildPatientLookupBar(),

                if (_hasSearched) ...[
                  const SizedBox(height: 16),
                  if (_searchedAppointment != null)
                    _buildPatientStatusCard(
                      queueAsync.value ?? MockData.getInitialQueueStates()[selectedChamberId]!,
                      _searchedAppointment!,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No appointment found with this Token ID or Phone Number. Please check and try again.',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 30),

                // Queue Serial Line-up List
                const Text(
                  'Today\'s Chamber Queue (সিরিয়াল তালিকা):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                appointmentsAsync.when(
                  data: (appointments) => _buildQueueList(appointments),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading appointments: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveQueueCard(ChamberQueueState queue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Doctor Chamber Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: queue.doctorStatus == DoctorChamberStatus.inChamber
                  ? AppColors.statusNowServing.withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: queue.doctorStatus == DoctorChamberStatus.inChamber
                    ? AppColors.statusNowServing
                    : Colors.amber,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: queue.doctorStatus == DoctorChamberStatus.inChamber
                      ? AppColors.statusNowServing
                      : Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  queue.doctorStatusLabelEn,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          if (queue.delayNotice != null && queue.delayNotice!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Notice: ${queue.delayNotice!}',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Now Serving Indicator
          const Text(
            'NOW CALLING / SERVING',
            style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                queue.activeSerial > 0 ? '#${queue.activeSerial}' : '--',
                style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: AppColors.statusNowServing),
              ),
              if (queue.activeSerial > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '(নং ${BanglaFormatter.toBanglaNumber(queue.activeSerial)})',
                  style: const TextStyle(fontSize: 18, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),

          if (queue.activePatientName != null && queue.activePatientName!.isNotEmpty)
            Text(
              'Patient: ${queue.activePatientName}',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // Queue Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Total Booked', '${queue.totalBooked}'),
              _buildMetric('Completed', '${queue.completedCount}'),
              _buildMetric('Still Waiting', '${queue.waitingCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
      ],
    );
  }

  Widget _buildPatientLookupBar() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check Your Serial Status (আপনার সিরিয়াল জানুন):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter your Token ID (e.g. DENT-8904) or Phone Number (017XXXXXXXX):',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Token or Phone...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: const Text('Check'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientStatusCard(ChamberQueueState queue, AppointmentModel apt) {
    final ahead = apt.serialNumber - queue.activeSerial;
    final isNow = apt.serialNumber == queue.activeSerial;
    final isPassed = apt.serialNumber < queue.activeSerial;

    Color cardColor;
    String statusMessage;
    String statusMessageBn;

    if (isNow) {
      cardColor = AppColors.statusNowServing.withOpacity(0.12);
      statusMessage = 'IT IS YOUR TURN! Please enter Doctor\'s room.';
      statusMessageBn = 'আপনার সিরিয়াল এসেছে! অনুগ্রহ করে ডাক্তারের চেম্বারে প্রবেশ করুন।';
    } else if (ahead > 0) {
      cardColor = AppColors.primaryLight.withOpacity(0.4);
      statusMessage = '$ahead patient(s) ahead of you. Est. wait: ~${ahead * 15} minutes.';
      statusMessageBn = 'আপনার আগে $ahead জন রোগী আছেন। আনুমানিক অপেক্ষার সময়: ~${ahead * 15} মিনিট।';
    } else {
      cardColor = Colors.grey.shade100;
      statusMessage = 'Your serial has already been called or completed.';
      statusMessageBn = 'আপনার সিরিয়াল ইতোমধ্যে সম্পন্ন বা অতিক্রান্ত হয়েছে।';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNow ? AppColors.statusNowServing : AppColors.primaryTeal, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${apt.patient.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Token: ${apt.id} • Phone: ${apt.patient.phone}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isNow ? AppColors.statusNowServing : AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Your Serial: #${apt.serialNumber}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isNow ? Icons.notifications_active : Icons.hourglass_top,
                color: isNow ? AppColors.statusNowServing : AppColors.primaryTeal,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isNow ? AppColors.statusNowServing : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      statusMessageBn,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No appointments booked for this chamber today.'),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceBorder),
        itemBuilder: (context, index) {
          final apt = appointments[index];
          final isCalling = apt.status == AppointmentStatus.called || apt.status == AppointmentStatus.inChamber;

          return Container(
            color: isCalling ? AppColors.statusNowServing.withOpacity(0.08) : Colors.transparent,
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCalling ? AppColors.statusNowServing : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#${apt.serialNumber}',
                    style: TextStyle(
                      color: isCalling ? Colors.white : AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                apt.patient.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                '${apt.slotTime} • ${apt.patient.chiefComplaint}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(apt.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apt.statusDisplayEn,
                  style: TextStyle(
                    color: _getStatusColor(apt.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
}
