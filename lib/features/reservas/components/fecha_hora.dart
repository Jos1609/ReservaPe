import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/reservas/controllers/nueva_reserva_controller.dart';

class DateTimePicker extends StatefulWidget {
  final Function(DateTime?, DateTime?) onDateTimeChanged;
  final DateTime? initialStartDateTime;
  final DateTime? initialEndDateTime;

  const DateTimePicker({
    super.key,
    required this.onDateTimeChanged,
    this.initialStartDateTime,
    this.initialEndDateTime,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.initialStartDateTime != null
          ? DateFormat('dd/MM/yyyy').format(widget.initialStartDateTime!)
          : '',
    );
    _startTimeController = TextEditingController(
      text: widget.initialStartDateTime != null
          ? DateFormat('HH:mm').format(widget.initialStartDateTime!)
          : '',
    );
    _endTimeController = TextEditingController(
      text: widget.initialEndDateTime != null
          ? DateFormat('HH:mm').format(widget.initialEndDateTime!)
          : '',
    );
    _selectedDate = widget.initialStartDateTime;
    if (_selectedDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NewReservationController>().fetchAvailableSlots(_selectedDate!);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;
    final controller = context.watch<NewReservationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha y Hora',
          style: AppTextStyles.heading3(context).copyWith(fontSize: isMobile ? 16 : null),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        isMobile
            ? Column(
                children: [
                  _buildDateField(context),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  _buildTimeFields(context, controller.availableSlots),
                  if (controller.availableSlots.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingSmall),
                    _buildAvailableSlots(context, controller.availableSlots),
                  ],
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildDateField(context)),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeFields(context, controller.availableSlots),
                        if (controller.availableSlots.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.spacingSmall),
                          _buildAvailableSlots(context, controller.availableSlots),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha*',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.gray),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null && context.mounted) {
          _selectedDate = date;
          _dateController.text = DateFormat('dd/MM/yyyy').format(date);
          await context.read<NewReservationController>().fetchAvailableSlots(date);
          _startTimeController.clear();
          _endTimeController.clear();
          widget.onDateTimeChanged(null, null);
        }
      },
    );
  }

  Widget _buildTimeFields(
      BuildContext context, List<Map<String, DateTime>> availableSlots) {

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _startTimeController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Hora de Inicio*',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              suffixIcon: const Icon(Icons.access_time, color: AppColors.gray),
            ),
            onTap: () => _showTimePicker(context, isStart: true, availableSlots: availableSlots),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Expanded(
          child: TextFormField(
            controller: _endTimeController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Hora de Fin*',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              suffixIcon: const Icon(Icons.access_time, color: AppColors.gray),
            ),
            onTap: () => _showTimePicker(context, isStart: false, availableSlots: availableSlots),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(
    BuildContext context, {
    required bool isStart,
    required List<Map<String, DateTime>> availableSlots,
  }) {
    if (availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay horarios disponibles para esta fecha')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isStart ? 'Seleccionar Hora de Inicio' : 'Seleccionar Hora de Fin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final slot = availableSlots[index];
              final start = DateFormat('HH:mm').format(slot['start']!);
              final end = DateFormat('HH:mm').format(slot['end']!);
              return ListTile(
                title: Text('$start - $end'),
                onTap: () {
                  final selectedTime = isStart ? slot['start'] : slot['end'];
                  if (isStart) {
                    _startTimeController.text = start;
                    widget.onDateTimeChanged(
                      _combineDateAndTime(_selectedDate, selectedTime),
                      widget.initialEndDateTime,
                    );
                  } else {
                    _endTimeController.text = end;
                    widget.onDateTimeChanged(
                      widget.initialStartDateTime,
                      _combineDateAndTime(_selectedDate, selectedTime),
                    );
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlots(
      BuildContext context, List<Map<String, DateTime>> availableSlots) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios Disponibles',
          style: AppTextStyles.bodyBold(context).copyWith(fontSize: isMobile ? 14 : null),
        ),
        const SizedBox(height: AppDimensions.spacingXSmall),
        Wrap(
          spacing: AppDimensions.spacingSmall,
          runSpacing: AppDimensions.spacingXSmall,
          children: availableSlots.map((slot) {
            final start = DateFormat('HH:mm').format(slot['start']!);
            final end = DateFormat('HH:mm').format(slot['end']!);
            return Chip(
              label: Text(
                '$start-$end',
                style: AppTextStyles.body(context).copyWith(fontSize: isMobile ? 12 : null),
              ),
              backgroundColor: AppColors.light,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  DateTime? _combineDateAndTime(DateTime? date, DateTime? time) {
    if (date == null || time == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}