import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/dental_chart_model.dart';
import '../providers/clinical_providers.dart';

class DentalChartScreen extends ConsumerStatefulWidget {
  final String patientPhoneOrId;
  final String patientName;

  const DentalChartScreen({
    super.key,
    required this.patientPhoneOrId,
    required this.patientName,
  });

  @override
  ConsumerState<DentalChartScreen> createState() => _DentalChartScreenState();
}

class _DentalChartScreenState extends ConsumerState<DentalChartScreen> {
  @override
  Widget build(BuildContext context) {
    final chartAsync = ref.watch(dentalChartProvider(widget.patientPhoneOrId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Interactive Dental Mouth Chart (FDI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Patient: ${widget.patientName} (${widget.patientPhoneOrId})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: chartAsync.when(
              data: (chart) => _buildChartContent(chart),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading dental chart: $e')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent(Map<int, ToothRecord> chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend Card
        _buildLegend(),

        const SizedBox(height: 24),

        // Upper Arch Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'UPPER ARCH (ম্যাক্সিলারি দাঁত - ওপরের পাটি)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryTeal),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Quadrant 1 (Upper Right: 18 -> 11)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [18, 17, 16, 15, 14, 13, 12, 11]
                            .map((t) => _buildToothWidget(chart[t] ?? ToothRecord(toothNumber: t)))
                            .toList(),
                      ),
                    ),
                    Container(width: 2, height: 60, color: AppColors.primaryDark, margin: const EdgeInsets.symmetric(horizontal: 10)),
                    // Quadrant 2 (Upper Left: 21 -> 28)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [21, 22, 23, 24, 25, 26, 27, 28]
                            .map((t) => _buildToothWidget(chart[t] ?? ToothRecord(toothNumber: t)))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Patient Right (ডান)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('Midline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Patient Left (বাম)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Lower Arch Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Patient Right (ডান)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('Midline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Patient Left (বাম)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Quadrant 4 (Lower Right: 48 -> 41)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [48, 47, 46, 45, 44, 43, 42, 41]
                            .map((t) => _buildToothWidget(chart[t] ?? ToothRecord(toothNumber: t)))
                            .toList(),
                      ),
                    ),
                    Container(width: 2, height: 60, color: AppColors.primaryDark, margin: const EdgeInsets.symmetric(horizontal: 10)),
                    // Quadrant 3 (Lower Left: 31 -> 38)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [31, 32, 33, 34, 35, 36, 37, 38]
                            .map((t) => _buildToothWidget(chart[t] ?? ToothRecord(toothNumber: t)))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'LOWER ARCH (ম্যান্ডিবুলার দাঁত - নিচের পাটি)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryTeal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToothWidget(ToothRecord tooth) {
    final color = _getConditionColor(tooth.condition);

    return Expanded(
      child: Tooltip(
        message: 'Tooth #${tooth.toothNumber}: ${tooth.condition.name.toUpperCase()}',
        child: InkWell(
          onTap: () => _showToothEditDialog(tooth),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  '${tooth.toothNumber}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: ToothCondition.values.map((cond) {
          final color = _getConditionColor(cond);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 6),
              Text(cond.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getConditionColor(ToothCondition condition) {
    switch (condition) {
      case ToothCondition.healthy:
        return Colors.green;
      case ToothCondition.decayed:
        return AppColors.toothDecayed;
      case ToothCondition.filled:
        return AppColors.toothFilled;
      case ToothCondition.crown:
        return AppColors.toothCrown;
      case ToothCondition.rct:
        return AppColors.toothRct;
      case ToothCondition.missing:
        return AppColors.toothMissing;
      case ToothCondition.impacted:
        return Colors.deepOrange;
    }
  }

  void _showToothEditDialog(ToothRecord tooth) {
    ToothCondition selectedCondition = tooth.condition;
    final noteController = TextEditingController(text: tooth.clinicalNote ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Edit Tooth #${tooth.toothNumber} Condition'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Clinical Condition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ToothCondition>(
                    value: selectedCondition,
                    items: ToothCondition.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCondition = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Clinical Notes / Treatment Plan'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final updated = tooth.copyWith(
                      condition: selectedCondition,
                      clinicalNote: noteController.text.trim(),
                    );
                    final repo = ref.read(clinicalRepositoryProvider);
                    await repo.updateToothRecord(widget.patientPhoneOrId, updated);
                    ref.invalidate(dentalChartProvider(widget.patientPhoneOrId));
                    if (!mounted) return;
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
