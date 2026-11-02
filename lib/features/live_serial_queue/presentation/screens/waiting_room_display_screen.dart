import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/utils/bangla_formatter.dart';
import '../../../appointment_booking/domain/models/appointment_model.dart';
import '../../../appointment_booking/presentation/providers/appointment_providers.dart';
import '../../domain/models/chamber_queue_state.dart';

class WaitingRoomDisplayScreen extends ConsumerStatefulWidget {
  const WaitingRoomDisplayScreen({super.key});

  @override
  ConsumerState<WaitingRoomDisplayScreen> createState() => _WaitingRoomDisplayScreenState();
}

class _WaitingRoomDisplayScreenState extends ConsumerState<WaitingRoomDisplayScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  bool _flashAnimation = false;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _triggerCallAlert(int serial, String name) {
    setState(() {
      _flashAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _flashAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedChamberId = ref.watch(selectedChamberIdProvider);
    final chambers = MockData.chambers;
    final queueAsync = ref.watch(chamberQueueNotifierProvider(selectedChamberId));
    final appointmentsAsync = ref.watch(appointmentsListProvider(selectedChamberId));

    // Listen to live queue broadcast events for TV chime
    ref.listen(liveQueueEventsProvider, (previous, next) {
      next.whenData((event) {
        if (event.chamberId == selectedChamberId && event.activeSerial > 0) {
          _triggerCallAlert(event.activeSerial, event.patientName);
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // Top TV Header Bar
            _buildTvHeader(chambers, selectedChamberId),

            // Main Display Body
            Expanded(
              child: queueAsync.when(
                data: (queue) {
                  return appointmentsAsync.when(
                    data: (appointments) => _buildTvMainLayout(queue, appointments),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.statusNowServing)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.statusNowServing)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
              ),
            ),

            // Bottom Ticker / Scrolling Guidelines
            _buildBottomTicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildTvHeader(List<dynamic> chambers, String selectedChamberId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Exit TV Mode',
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tv, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SmileCraft Dental Clinic • Waiting Room TV Display',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Dr. Syed Tanvir Rahman | BMDC Reg. No: D-12845',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          // Chamber Selector Pills on TV
          Row(
            children: chambers.map((c) {
              final isSelected = c.id == selectedChamberId;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.locationArea.split(',').first),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedChamberIdProvider.notifier).setChamber(c.id);
                    }
                  },
                  selectedColor: AppColors.primaryTeal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),

          // Real-time Digital Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primaryAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('hh:mm:ss a').format(_currentTime),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvMainLayout(ChamberQueueState queue, List<AppointmentModel> appointments) {
    final upcoming = appointments
        .where((a) => a.serialNumber > queue.activeSerial && a.status != AppointmentStatus.completed)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Giant Serving Panel (65%)
          Expanded(
            flex: 65,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: _flashAnimation ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _flashAnimation ? AppColors.statusNowServing : const Color(0xFF1E293B),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _flashAnimation ? AppColors.statusNowServing.withOpacity(0.4) : Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: _flashAnimation ? 10 : 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Now Calling Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.statusNowServing.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.statusNowServing, width: 2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up, color: AppColors.statusNowServing, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'NOW SERVING / এখন ডাকা হয়েছে',
                          style: TextStyle(
                            color: AppColors.statusNowServing,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Giant Serial Number
                  Text(
                    queue.activeSerial > 0 ? '#${queue.activeSerial.toString().padLeft(2, '0')}' : '--',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  if (queue.activeSerial > 0)
                    Text(
                      '(সিরিয়াল নং ${BanglaFormatter.toBanglaNumber(queue.activeSerial)})',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Patient Name
                  Text(
                    queue.activePatientName != null ? queue.activePatientName!.toUpperCase() : 'WAITING FOR DOCTOR TO CALL',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: queue.activePatientName != null ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Please proceed to Doctor\'s Consultation Chamber (Room 01)',
                    style: TextStyle(fontSize: 16, color: Colors.teal.shade200, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'অনুগ্রহ করে ডাক্তার স্যারের কামরায় (রুম ১) প্রবেশ করুন',
                    style: TextStyle(fontSize: 15, color: Colors.teal.shade200),
                  ),

                  const SizedBox(height: 30),

                  // Doctor Status Indicator Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.medical_services, color: AppColors.primaryAccent, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          '${queue.chamberName} • ${queue.doctorStatusLabelEn}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Right Next-In-Line Panel (35%)
          Expanded(
            flex: 35,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF1E293B), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.queue, color: AppColors.primaryAccent, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'NEXT IN LINE (পরবর্তী সিরিয়াল)',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 16),

                  Expanded(
                    child: upcoming.isEmpty
                        ? const Center(
                            child: Text(
                              'No more queued patients for today.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                            ),
                          )
                        : ListView.separated(
                            itemCount: upcoming.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = upcoming[index];
                              final isNext = index == 0;

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isNext ? const Color(0xFF1E293B) : const Color(0xFF141E33),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isNext ? AppColors.primaryTeal : const Color(0xFF1E293B),
                                    width: isNext ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isNext ? AppColors.primaryTeal : const Color(0xFF334155),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '#${item.serialNumber}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.patient.name,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          Text(
                                            'Slot: ${item.slotTime}',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isNext ? AppColors.statusNowServing.withOpacity(0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: isNext ? Border.all(color: AppColors.statusNowServing) : null,
                                      ),
                                      child: Text(
                                        isNext ? 'BE READY' : 'WAITING',
                                        style: TextStyle(
                                          color: isNext ? AppColors.statusNowServing : const Color(0xFF64748B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: const Color(0xFF0F172A),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusAbsent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('NOTICE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'অনুগ্রহ করে সিরিয়ালের ১৫ মিনিট পূর্বে উপস্থিত থাকুন • জরুরি দাঁতের তীব্র ব্যথা বা রক্তক্ষরণে রিসিপশনে জানান • প্রতিটি ইন্সট্রুমেন্ট ১০০% অটোক্লেভ ক্লাস-বি স্টেরিলাইজড',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
