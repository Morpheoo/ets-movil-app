import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../domain/entities/ets_entity.dart';
import 'providers/ets_provider.dart';

const _meses = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Arranca en el mes con más exámenes (o el actual)
    _focusedMonth = DateTime(2026, 2);
    _selectedDay = DateTime(2026, 2, 10);
  }

  // Agrupa los ETS por fecha (solo año/mes/día)
  Map<DateTime, List<EtsEntity>> _groupByDate(List<EtsEntity> list) {
    final map = <DateTime, List<EtsEntity>>{};
    for (final e in list) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      (map[key] ??= []).add(e);
    }
    return map;
  }

  void _previousMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        _selectedDay = null;
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        _selectedDay = null;
      });

  @override
  Widget build(BuildContext context) {
    final etsState = ref.watch(etsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Calendario ETS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Semestre 2026-1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: etsState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (etsList) {
          final grouped = _groupByDate(etsList);
          final selectedExams = _selectedDay != null
              ? (grouped[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
              : <EtsEntity>[];

          return Column(
            children: [
              _MonthHeader(
                month: _focusedMonth,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              _WeekdayLabels(),
              _MonthGrid(
                focusedMonth: _focusedMonth,
                examDays: grouped,
                selectedDay: _selectedDay,
                onDayTapped: (day) => setState(() => _selectedDay = day),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: _ExamsList(
                  selectedDay: _selectedDay,
                  exams: selectedExams,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Cabecera del mes ──────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({required this.month, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final label = '${_meses[month.month]} ${month.year}';
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: onPrevious,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Encabezados L M X J V S D ────────────────────────────────────────────────

class _WeekdayLabels extends StatelessWidget {
  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: _labels.map((l) {
          final isSunday = l == 'D';
          return Expanded(
            child: Center(
              child: Text(
                l,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSunday ? AppColors.error.withValues(alpha: 0.7) : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Grid del mes ──────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final Map<DateTime, List<EtsEntity>> examDays;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDayTapped;

  const _MonthGrid({
    required this.focusedMonth,
    required this.examDays,
    required this.selectedDay,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    // weekday: 1=Mon … 7=Sun → offset para grilla lunes-primero
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: rows * 7,
        itemBuilder: (context, index) {
          final dayNumber = index - startOffset + 1;
          if (dayNumber < 1 || dayNumber > lastDay.day) {
            return const SizedBox.shrink();
          }
          final day = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
          final dayKey = DateTime(day.year, day.month, day.day);
          final exams = examDays[dayKey] ?? [];
          final isSelected = selectedDay != null &&
              selectedDay!.year == day.year &&
              selectedDay!.month == day.month &&
              selectedDay!.day == day.day;
          final isToday = _isToday(day);
          final isSunday = day.weekday == 7;

          return GestureDetector(
            onTap: () => onDayTapped(day),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isSunday
                              ? AppColors.error.withValues(alpha: 0.7)
                              : AppColors.textPrimary,
                    ),
                  ),
                  if (exams.isNotEmpty)
                    _ExamDots(exams: exams, isSelected: isSelected),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}

// ── Puntos de colores por carrera ─────────────────────────────────────────────

class _ExamDots extends StatelessWidget {
  final List<EtsEntity> exams;
  final bool isSelected;

  const _ExamDots({required this.exams, required this.isSelected});

  static Color _careerColor(String career) {
    switch (career) {
      case 'ISC':   return AppColors.primary;
      case 'IIA':   return const Color(0xFF5B8DD9);
      case 'LCD':   return AppColors.success;
      case 'ISISA': return AppColors.warning;
      default:      return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Máximo 3 puntos, uno por carrera única
    final careers = exams.map((e) => e.career).toSet().take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: careers.map((c) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : _careerColor(c),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }
}

// ── Lista de exámenes del día seleccionado ────────────────────────────────────

class _ExamsList extends StatelessWidget {
  final DateTime? selectedDay;
  final List<EtsEntity> exams;

  const _ExamsList({required this.selectedDay, required this.exams});

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const Center(
        child: Text(
          'Selecciona un día para ver los exámenes',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    final dayLabel = '${selectedDay!.day} de ${_meses[selectedDay!.month]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.event, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                dayLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (exams.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${exams.length} examen${exams.length != 1 ? 'es' : ''}',
                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: exams.isEmpty
              ? const Center(
                  child: Text(
                    'Sin exámenes este día',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: exams.length,
                  itemBuilder: (context, i) => _ExamCard(ets: exams[i]),
                ),
        ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  final EtsEntity ets;

  const _ExamCard({required this.ets});

  static Color _careerColor(String career) {
    switch (career) {
      case 'ISC':   return AppColors.primary;
      case 'IIA':   return const Color(0xFF5B8DD9);
      case 'LCD':   return AppColors.success;
      case 'ISISA': return AppColors.warning;
      default:      return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _careerColor(ets.career);
    return GestureDetector(
      onTap: () => context.push('/ets-detail', extra: ets),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.divider.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ets.career,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sem. ${ets.semester}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ets.subject,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ets.shift,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.room, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    ets.classroom,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
