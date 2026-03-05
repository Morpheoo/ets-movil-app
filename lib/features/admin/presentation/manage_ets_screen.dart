import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../ets/domain/entities/ets_entity.dart';

class ManageEtsScreen extends StatefulWidget {
  final EtsEntity? ets; // null = create, non-null = edit

  const ManageEtsScreen({super.key, this.ets});

  @override
  State<ManageEtsScreen> createState() => _ManageEtsScreenState();
}

class _ManageEtsScreenState extends State<ManageEtsScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _professorController;
  late TextEditingController _classroomController;
  late TextEditingController _buildingController;
  String? _selectedCareer;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _careers = [
    'Ingeniería en Sistemas Computacionales',
    'Licenciatura en Ciencia de Datos',
    'Ingeniería en Inteligencia Artificial',
    'Ingeniería en Sistemas de Información',
  ];

  @override
  void initState() {
    super.initState();
    final ets = widget.ets;
    _subjectController = TextEditingController(text: ets?.subject ?? '');
    _professorController = TextEditingController(text: ets?.professor ?? '');
    _classroomController = TextEditingController(text: ets?.classroom ?? '');
    _buildingController = TextEditingController(text: ets != null ? 'Building ${ets.id}' : '');
    if (ets != null) {
      _selectedCareer = _careerFullName(ets.career);
      _selectedDate = ets.date;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _professorController.dispose();
    _classroomController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ets != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('< Back', style: TextStyle(color: AppColors.textOnPrimary, fontSize: 14)),
        ),
        leadingWidth: 80,
        title: const Text('Manage ETS'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Schedule' : 'New Schedule',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ACADEMIC YEAR 2024-2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Degree Program
                        _buildLabel('DEGREE PROGRAM'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCareer,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          hint: const Text('Select career'),
                          isExpanded: true,
                          items: _careers.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 14)),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedCareer = val),
                        ),
                        const SizedBox(height: 20),

                        // Subject
                        _buildLabel('SUBJECT'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Estructuras de Datos',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date & Time row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('DATE'),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          hintText: _formatDate(_selectedDate),
                                          suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        ),
                                        controller: TextEditingController(text: _formatDate(_selectedDate)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('TIME'),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _pickTime,
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          hintText: _formatTime(_selectedTime),
                                          suffixIcon: const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        ),
                                        controller: TextEditingController(text: _formatTime(_selectedTime)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Building & Classroom
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('BUILDING'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _buildingController,
                                    decoration: const InputDecoration(
                                      hintText: 'Building 1',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('CLASSROOM'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _classroomController,
                                    decoration: const InputDecoration(
                                      hintText: '1104',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Professor
                        _buildLabel('PROFESSOR'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _professorController,
                          decoration: const InputDecoration(
                            hintText: 'Dr. Roberto Sanchez',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ensure the professor is registered in the faculty directory.',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.blue.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Modifying this ETS entry will automatically notify students currently registered for this exam. Deleting this entry is permanent and cannot be undone.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                // Delete button
                if (isEditing)
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                if (isEditing) const SizedBox(width: 12),
                // Save button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text('Save ETS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.labelColor,
        letterSpacing: 1.2,
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ETS saved successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ETS'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ETS deleted'), backgroundColor: AppColors.error),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  String _formatTime(TimeOfDay t) => '${t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';

  String _careerFullName(String code) {
    switch (code) {
      case 'ISC': return 'Ingeniería en Sistemas Computacionales';
      case 'LCD': return 'Licenciatura en Ciencia de Datos';
      case 'IA': return 'Ingeniería en Inteligencia Artificial';
      default: return code;
    }
  }
}
