import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/utils/bangla_formatter.dart';
import '../../../chamber_management/domain/models/chamber_model.dart';
import '../../../appointment_booking/presentation/providers/appointment_providers.dart';
import '../../../appointment_booking/presentation/screens/booking_flow_screen.dart';
import '../../../live_serial_queue/presentation/screens/live_serial_tracker_screen.dart';
import '../../../live_serial_queue/presentation/screens/waiting_room_display_screen.dart';
import '../../../staff_portal/presentation/screens/staff_login_screen.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = MockData.doctorProfile;
    final chambersAsync = ref.watch(allChambersProvider);
    final selectedChamberId = ref.watch(selectedChamberIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services, color: AppColors.primaryTeal, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    AppStrings.appName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'BMDC Verified: D-12845',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live Waiting Room TV Display Quick Button
          Tooltip(
            message: 'Waiting Room TV Display Mode',
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WaitingRoomDisplayScreen()),
                );
              },
              icon: const Icon(Icons.tv, color: AppColors.royalBlue, size: 20),
              label: const Text(
                'TV Display',
                style: TextStyle(color: AppColors.royalBlue, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Doctor / Staff Portal Login Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            icon: const Icon(Icons.lock_outline, size: 16),
            label: const Text('Staff / Doctor', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Doctor Profile Banner
            _buildHeroHeader(context, doctor),

            // Live Serial Floating Quick Bar
            _buildLiveSerialQuickBar(context, ref, selectedChamberId),

            // Main Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chambers & Schedule Section
                    _buildSectionHeader(
                      title: 'Our Chambers & Visiting Hours',
                      titleBn: 'চেম্বার সমূহ ও রোগী দেখার সময়সূচী',
                      subtitle: 'Practicing across top medical centers in Dhaka with dedicated live queue management.',
                    ),
                    const SizedBox(height: 16),
                    chambersAsync.when(
                      data: (chambers) => _buildChambersGrid(context, ref, chambers),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error loading chambers: $err'),
                    ),

                    const SizedBox(height: 40),

                    // Specialized Dental Services Section
                    _buildSectionHeader(
                      title: 'Specialized Dental Treatments',
                      titleBn: 'বিশেষজ্ঞ চিকিৎসা ও সেবাসমূহ',
                      subtitle: 'World-class sterile operatory equipped with Japanese Rotary Endodontics, RVG digital X-rays, and CAD/CAM implants.',
                    ),
                    const SizedBox(height: 16),
                    _buildServicesGrid(context),

                    const SizedBox(height: 40),

                    // Clinical Technology & Safety Standards
                    _buildSafetyBanner(context),

                    const SizedBox(height: 40),

                    // Verified Patient Testimonials
                    _buildSectionHeader(
                      title: 'Patient Stories & Experiences',
                      titleBn: 'রোগীদের বাস্তব অভিজ্ঞতা ও প্রতিক্রিয়া',
                      subtitle: 'Real patients treated across our Dhanmondi, Uttara & Banani chambers.',
                    ),
                    const SizedBox(height: 16),
                    _buildReviewsSection(context),

                    const SizedBox(height: 50),

                    // Footer with Emergency Hotline
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Bottom Call / Book Quick Action on Mobile
      bottomNavigationBar: MediaQuery.of(context).size.width < 768
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LiveSerialTrackerScreen()),
                        );
                      },
                      icon: const Icon(Icons.radar, color: AppColors.primaryTeal, size: 18),
                      label: const Text('Live Serial', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BookingFlowScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Book Serial (সিরিয়াল বুক করুন)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildHeroHeader(BuildContext context, dynamic doctor) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 7, child: _buildDoctorIntro(context, doctor)),
                    const SizedBox(width: 40),
                    Expanded(flex: 5, child: _buildDoctorCard(context, doctor)),
                  ],
                )
              : Column(
                  children: [
                    _buildDoctorCard(context, doctor),
                    const SizedBox(height: 24),
                    _buildDoctorIntro(context, doctor),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, dynamic doctor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryTeal.withOpacity(0.4), blurRadius: 16),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 75, color: AppColors.primaryTeal),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusNowServing,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'BMDC Verified',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            doctor.bnName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.primaryLight.withOpacity(0.9), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.5)),
            ),
            child: Text(
              doctor.bmdcRegNo,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            doctor.degrees,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorIntro(BuildContext context, dynamic doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.goldAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.goldAccent.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: AppColors.goldAccent, size: 16),
              SizedBox(width: 6),
              Text(
                'Top Rated Dental Surgeon & Implantologist in Dhaka',
                style: TextStyle(color: AppColors.goldAccent, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Gentle, Pain-Free &\nPrecision Dental Care',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'স্মার্ট লাইভ সিরিয়াল ট্র্যাকিং সহ উন্নত ও ব্যথামুক্ত আন্তর্জাতিক মানের দন্ত চিকিৎসা',
          style: TextStyle(fontSize: 15, color: Colors.teal.shade100, height: 1.4),
        ),
        const SizedBox(height: 16),
        Text(
          doctor.bioEn,
          style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.6),
        ),
        const SizedBox(height: 24),
        // Key Stats Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatItem('14+ Years', 'Clinical Experience'),
              _buildDivider(),
              _buildStatItem('16,800+', 'Happy Smiles'),
              _buildDivider(),
              _buildStatItem('4.96 ★', '740+ Reviews'),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Primary Call to Action Buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookingFlowScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.calendar_month, size: 18),
              label: const Text('Book Serial Now (সিরিয়াল নিন)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveSerialTrackerScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.radar, size: 18),
              label: const Text('Track Live Serial (লাইভ সিরিয়াল)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildLiveSerialQuickBar(BuildContext context, WidgetRef ref, String selectedChamberId) {
    final queueAsync = ref.watch(chamberQueueNotifierProvider(selectedChamberId));

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F766E),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: queueAsync.when(
            data: (queue) {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.statusNowServing,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sensors, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'LIVE QUEUE: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                          ),
                          TextSpan(
                            text: '${queue.chamberName} • ',
                            style: TextStyle(color: Colors.teal.shade100, fontSize: 13),
                          ),
                          TextSpan(
                            text: queue.activeSerial > 0
                                ? 'Now Calling Serial #${queue.activeSerial} (${queue.activePatientName ?? ""})'
                                : queue.doctorStatusLabelEn,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          TextSpan(
                            text: ' • Total Waiting: ${queue.waitingCount}',
                            style: TextStyle(color: Colors.teal.shade100, fontSize: 12),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LiveSerialTrackerScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('View Live Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String titleBn, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, color: AppColors.primaryTeal),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          titleBn,
          style: const TextStyle(fontSize: 14, color: AppColors.primaryTeal, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildChambersGrid(BuildContext context, WidgetRef ref, List<ChamberModel> chambers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;
        return isMobile
            ? Column(
                children: chambers.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildChamberCard(context, ref, c),
                )).toList(),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: chambers.map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildChamberCard(context, ref, c),
                  ),
                )).toList(),
              );
      },
    );
  }

  Widget _buildChamberCard(BuildContext context, WidgetRef ref, ChamberModel chamber) {
    final queueAsync = ref.watch(chamberQueueNotifierProvider(chamber.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chamber.locationArea,
                      style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                queueAsync.when(
                  data: (q) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: q.activeSerial > 0 ? AppColors.statusNowServing.withOpacity(0.15) : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      q.activeSerial > 0 ? 'Now: #${q.activeSerial}' : 'Schedule Today',
                      style: TextStyle(
                        color: q.activeSerial > 0 ? AppColors.statusNowServing : Colors.amber.shade900,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              chamber.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              chamber.bnName,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    chamber.fullAddress,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${chamber.activeDaysBn} (${chamber.scheduleTime})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Fee: ${BanglaFormatter.formatBdt(chamber.regularFee)} (Follow-up: ${BanglaFormatter.formatBdt(chamber.followUpFee)})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.surfaceBorder),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(selectedChamberIdProvider.notifier).setChamber(chamber.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LiveSerialTrackerScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('Live Serial', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(selectedChamberIdProvider.notifier).setChamber(chamber.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookingFlowScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('Book Serial', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = MockData.dentalServices;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 950 ? 2 : 4);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 2.2 : 0.88,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final s = services[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.health_and_safety, color: AppColors.primaryTeal, size: 26),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      s.bnTitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        s.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'From ${s.startingPrice}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            s.duration,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSafetyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.sanitizer, color: AppColors.primaryTeal, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '100% Autoclave Class-B Sterilization & Clean Operatory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                SizedBox(height: 4),
                Text(
                  'আন্তর্জাতিক প্রটোকল অনুযায়ী প্রতিটি রোগীর জন্য পৃথক সিল করা জীবাণুমুক্ত বাটারি ও ডেন্টাল ইন্সট্রুমেন্ট ব্যবহার করা হয়। হেপাটাইটিস ও ক্রস-সংক্রমণ মুক্ত নিরাপদ পরিবেশ।',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final reviews = MockData.reviews;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 750 ? 1 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final r = reviews[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          radius: 18,
                          child: Text(
                            r.patientName.substring(0, 1),
                            style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${r.area} • ${r.treatmentTaken}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => const Icon(Icons.star, color: Colors.amber, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        '"${r.comment}"',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.medical_services, color: AppColors.primaryTeal, size: 36),
          const SizedBox(height: 12),
          const Text(
            'SmileCraft Dental & Implant Center',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dr. Syed Tanvir Rahman | BMDC Reg: D-12845',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Text(
            'Emergency Chamber Hotline: +880 1711-234567 | WhatsApp Support Available',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dhanmondi • Uttara • Banani | Dhaka, Bangladesh',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
