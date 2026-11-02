import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/utils/bangla_formatter.dart';
import '../../../chamber_management/domain/models/chamber_model.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/models/patient_model.dart';
import '../providers/appointment_providers.dart';
import 'appointment_slip_screen.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final String? initialChamberId;

  const BookingFlowScreen({super.key, this.initialChamberId});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;

  // Selected State
  String _selectedChamberId = 'CHAMBER-DHANMONDI';
  String _selectedServiceTitle = 'Single-Visit Rotary Root Canal (RCT)';
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = '06:00 PM';
  bool _isFollowUp = false;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '30');
  String _gender = 'Male';
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _complaintController = TextEditingController();
  double _painScale = 5.0;
  final List<String> _selectedMedicalConditions = [];

  // Payment
  PaymentMethod _paymentMethod = PaymentMethod.cashAtChamber;
  final _trxIdController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialChamberId != null) {
      _selectedChamberId = widget.initialChamberId!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _complaintController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chambers = MockData.chambers;
    final currentChamber = chambers.firstWhere(
      (c) => c.id == _selectedChamberId,
      orElse: () => chambers.first,
    );
    final fee = _isFollowUp ? currentChamber.followUpFee : currentChamber.regularFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Serial / সিরিয়াল বুকিং', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepTapped: (step) {
              if (step < _currentStep) {
                setState(() => _currentStep = step);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    const Spacer(),
                    if (_currentStep < 3)
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: const Text('Next Step →'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusNowServing,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_circle, size: 18),
                        label: Text(_isSubmitting ? 'Confirming...' : 'Confirm Serial (৳$fee)'),
                      ),
                  ],
                ),
              );
            },
            onStepContinue: () {
              if (_currentStep == 0) {
                setState(() => _currentStep = 1);
              } else if (_currentStep == 1) {
                setState(() => _currentStep = 2);
              } else if (_currentStep == 2) {
                setState(() => _currentStep = 3);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            steps: [
              Step(
                title: const Text('Chamber'),
                subtitle: const Text('চেম্বার নির্বাচন'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: _buildChamberSelectionStep(chambers),
              ),
              Step(
                title: const Text('Service & Date'),
                subtitle: const Text('চিকিৎসা ও সময়'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: _buildServiceAndDateStep(currentChamber),
              ),
              Step(
                title: const Text('Patient Info'),
                subtitle: const Text('রোগীর তথ্য'),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                content: _buildPatientInfoStep(),
              ),
              Step(
                title: const Text('Payment & Confirm'),
                subtitle: const Text('পেমেন্ট ও নিশ্চিতকরণ'),
                isActive: _currentStep >= 3,
                state: StepState.indexed,
                content: _buildPaymentStep(currentChamber, fee),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChamberSelectionStep(List<ChamberModel> chambers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your preferred chamber location:',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...chambers.map((chamber) {
          final isSelected = chamber.id == _selectedChamberId;
          return Card(
            color: isSelected ? AppColors.primaryLight.withOpacity(0.4) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primaryTeal : AppColors.surfaceBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              value: chamber.id,
              groupValue: _selectedChamberId,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedChamberId = val);
                }
              },
              title: Text(
                chamber.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${chamber.locationArea} • ${chamber.activeDaysBn} (${chamber.scheduleTime})'),
                  const SizedBox(height: 4),
                  Text(
                    'Fee: ৳${chamber.regularFee} (Follow-up ৳${chamber.followUpFee}) • Reception: ${chamber.phoneContact}',
                    style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildServiceAndDateStep(ChamberModel chamber) {
    final services = MockData.dentalServices;
    final slots = [
      '05:30 PM', '06:00 PM', '06:30 PM', '07:00 PM',
      '07:30 PM', '08:00 PM', '08:30 PM', '09:00 PM'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chief Dental Concern / Treatment:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedServiceTitle,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.medical_services_outlined)),
          items: services
              .map((s) => DropdownMenuItem(
                    value: s.title,
                    child: Text('${s.title} (${s.startingPrice})', overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedServiceTitle = v);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Appointment Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryTeal),
                          const SizedBox(width: 10),
                          Text(DateFormat('EEE, dd MMM yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Consultation Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: _isFollowUp,
                    items: const [
                      DropdownMenuItem(value: false, child: Text('New Patient (প্রথম ভিজিট)')),
                      DropdownMenuItem(value: true, child: Text('Follow-up (পুনরায় ভিজিট)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _isFollowUp = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Preferred Time Slot (সিরিয়াল স্লট):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = slot == _selectedSlot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedSlot = slot);
              },
              selectedColor: AppColors.primaryTeal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPatientInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Patient Full Name (রোগীর পুরো নাম) *',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter patient name' : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age (বয়স) *',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter age' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender (লিঙ্গ)'),
                  items: ['Male', 'Female', 'Child'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _gender = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Phone Number (01XXXXXXXXX) *',
              hintText: '017XXXXXXXX',
              prefixIcon: Icon(Icons.phone_outlined),
              helperText: 'You will track your live serial with this phone number',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
              if (!BanglaFormatter.isValidBdPhone(v)) return 'Enter valid BD phone number (e.g. 01712345678)';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Area / District (ঠিকানা/এলাকা)',
              hintText: 'e.g. Dhanmondi, Dhaka',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _complaintController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Describe Your Dental Problem (সমস্যার বিবরণ)',
              hintText: 'e.g., Severe toothache on lower jaw, bleeding gums, broken tooth',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pre-existing Health Conditions (পূর্বের কোনো রোগ থাকলে টিক দিন):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: AppStrings.medicalConditions.map((condition) {
              final isChecked = _selectedMedicalConditions.contains(condition);
              return FilterChip(
                label: Text(condition, style: const TextStyle(fontSize: 12)),
                selected: isChecked,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMedicalConditions.add(condition);
                    } else {
                      _selectedMedicalConditions.remove(condition);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Pain Severity Scale (ব্যথার তীব্রতা): ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${_painScale.toInt()} / 10', style: const TextStyle(color: AppColors.statusAbsent, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Slider(
            value: _painScale,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppColors.statusAbsent,
            label: '${_painScale.toInt()}',
            onChanged: (val) => setState(() => _painScale = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(ChamberModel chamber, int fee) {
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chamber: ${chamber.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text('Date & Slot: $dateStr at $_selectedSlot'),
              Text('Service: $_selectedServiceTitle'),
              Text('Patient: ${_nameController.text.isEmpty ? "Patient" : _nameController.text} (${_gender})'),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consultation Fee:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    '৳$fee',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Select Payment Option:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.cashAtChamber,
          groupValue: _paymentMethod,
          onChanged: (val) => setState(() => _paymentMethod = val!),
          title: const Text('Pay Cash at Chamber Counter (চেম্বারে নগদ প্রদান)', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Pay when you arrive at reception before meeting the doctor'),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.bKash,
          groupValue: _paymentMethod,
          onChanged: (val) => setState(() => _paymentMethod = val!),
          title: Row(
            children: const [
              Icon(Icons.payment, color: AppColors.bKashPink, size: 20),
              SizedBox(width: 8),
              Text('bKash Instant Pay (বিকাশ পেমেন্ট)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.bKashPink)),
            ],
          ),
          subtitle: const Text('Merchant / Send Money: 01711-234567'),
        ),
        if (_paymentMethod == PaymentMethod.bKash) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 16, top: 8),
            child: TextFormField(
              controller: _trxIdController,
              decoration: const InputDecoration(
                labelText: 'bKash TrxID (Transaction ID) *',
                hintText: 'e.g. BK9A7X32LM',
                prefixIcon: Icon(Icons.receipt_long, color: AppColors.bKashPink),
              ),
            ),
          ),
        ],
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.nagad,
          groupValue: _paymentMethod,
          onChanged: (val) => setState(() => _paymentMethod = val!),
          title: Row(
            children: const [
              Icon(Icons.payment, color: AppColors.nagadOrange, size: 20),
              SizedBox(width: 8),
              Text('Nagad Instant Pay (নগদ পেমেন্ট)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.nagadOrange)),
            ],
          ),
          subtitle: const Text('Merchant Number: 01819-987654'),
        ),
      ],
    );
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      setState(() => _currentStep = 2); // Jump back to patient info
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final chambers = MockData.chambers;
      final chamber = chambers.firstWhere((c) => c.id == _selectedChamberId);
      final fee = _isFollowUp ? chamber.followUpFee : chamber.regularFee;
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final patient = PatientModel(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 30,
        gender: _gender,
        phone: _phoneController.text.trim(),
        addressArea: _addressController.text.trim().isEmpty ? chamber.locationArea : _addressController.text.trim(),
        medicalConditions: _selectedMedicalConditions,
        chiefComplaint: _complaintController.text.trim().isEmpty ? _selectedServiceTitle : _complaintController.text.trim(),
        painScale: _painScale.toInt(),
      );

      final repo = ref.read(appointmentRepositoryProvider);
      final appointment = await repo.bookAppointment(
        chamberId: chamber.id,
        chamberName: chamber.name,
        date: dateStr,
        slotTime: _selectedSlot,
        patient: patient,
        consultationFee: fee,
        isFollowUp: _isFollowUp,
        paymentMethod: _paymentMethod,
        trxId: _trxIdController.text.trim().isEmpty ? null : _trxIdController.text.trim(),
      );

      // Invalidate appointment list provider to refresh UI
      ref.invalidate(appointmentsListProvider(chamber.id));

      if (!mounted) return;

      // Navigate to Appointment Token Slip Screen!
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppointmentSlipScreen(appointment: appointment),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book serial: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
