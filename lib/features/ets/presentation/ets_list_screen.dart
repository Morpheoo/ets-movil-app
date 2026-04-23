import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/excel_generator.dart';
import '../../../core/utils/pdf_generator.dart';
import 'providers/ets_provider.dart';
import 'widgets/ets_card.dart';

class EtsListScreen extends ConsumerStatefulWidget {
  const EtsListScreen({super.key});

  @override
  ConsumerState<EtsListScreen> createState() => _EtsListScreenState();
}

class _EtsListScreenState extends ConsumerState<EtsListScreen> {
  String? _selectedCareer;
  int? _selectedSemester;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(etsListProvider.notifier).search(query);
    });
  }

  void _filterByCareer(String? career) {
    setState(() {
      _selectedCareer = (_selectedCareer == career) ? null : career;
    });
    ref.read(etsListProvider.notifier).filter(career: _selectedCareer);
  }

  void _filterBySemester(int? semester) {
    setState(() {
      _selectedSemester = (_selectedSemester == semester) ? null : semester;
    });
    ref.read(etsListProvider.notifier).filterBySemester(_selectedSemester);
  }

  void _clearAll() {
    setState(() { _selectedCareer = null; _selectedSemester = null; });
    _searchController.clear();
    ref.read(etsListProvider.notifier).clearFilters();
  }

  bool get _hasActiveFilters =>
      _selectedCareer != null || _selectedSemester != null || _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final etsAsync = ref.watch(etsListProvider);

    ref.listen(etsListProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final failure = next.error;
        String msg = 'Error inesperado';
        if (failure is NetworkFailure) { msg = failure.message; }
        else if (failure is TimeoutFailure) { msg = failure.message; }
        else if (failure is ServerFailure) { msg = failure.message; }
        else if (failure is Failure) { msg = failure.message; }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: etsAsync.hasValue && etsAsync.value!.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'btnExcel',
                  onPressed: () => ExcelGenerator.generateAndShareEtsList(etsAsync.value!),
                  backgroundColor: const Color(0xFF27AE60),
                  mini: true,
                  child: const Icon(Icons.table_view_outlined, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'btnPdf',
                  onPressed: () => PdfGenerator.generateAndPrintEtsList(etsAsync.value!),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ETS Especial',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '10 de febrero de 2026 • ESCOM',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sem. 2026-1',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar materia, profesor, salón...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(etsListProvider.notifier).search('');
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Career filter chips ──
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CareerChip(label: 'Todos', isSelected: _selectedCareer == null, onTap: () { setState(() => _selectedCareer = null); ref.read(etsListProvider.notifier).filter(career: null); }),
                  _CareerChip(label: 'ISC', subtitle: 'Sistemas', isSelected: _selectedCareer == 'ISC', color: AppColors.primary, onTap: () => _filterByCareer('ISC')),
                  _CareerChip(label: 'IIA', subtitle: 'IA', isSelected: _selectedCareer == 'IIA', color: const Color(0xFF2980B9), onTap: () => _filterByCareer('IIA')),
                  _CareerChip(label: 'LCD', subtitle: 'Datos', isSelected: _selectedCareer == 'LCD', color: const Color(0xFF27AE60), onTap: () => _filterByCareer('LCD')),
                  _CareerChip(label: 'ISISA', subtitle: 'Automotriz', isSelected: _selectedCareer == 'ISISA', color: const Color(0xFFE67E22), onTap: () => _filterByCareer('ISISA')),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ── Semester filter chips ──
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8, top: 4),
                    child: Text(
                      'Sem:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  for (int i = 1; i <= 8; i++)
                    _SemesterChip(
                      semester: i,
                      isSelected: _selectedSemester == i,
                      onTap: () => _filterBySemester(i),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Results count + clear ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: etsAsync.when(
                data: (list) => Row(
                  children: [
                    Text(
                      '${list.length} exámenes encontrados',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (_hasActiveFilters)
                      GestureDetector(
                        onTap: _clearAll,
                        child: const Row(
                          children: [
                            Icon(Icons.clear_all, size: 14, color: AppColors.primary),
                            SizedBox(width: 2),
                            Text('Limpiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ],
                        ),
                      ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ),

            // ── ETS List ──
            Expanded(
              child: etsAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          const Text('No se encontraron exámenes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            'Intenta con otro término de búsqueda',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _clearAll,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Mostrar todos'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => EtsCard(
                      ets: list[i],
                      onTap: () => context.push('/ets-detail', extra: list[i]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) {
                  String msg = 'Error inesperado';
                  if (err is Failure) msg = err.message;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
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
    );
  }
}

class _CareerChip extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _CareerChip({required this.label, this.subtitle, required this.isSelected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : chipColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 3),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white.withValues(alpha: 0.8) : chipColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SemesterChip extends StatelessWidget {
  final int semester;
  final bool isSelected;
  final VoidCallback onTap;

  const _SemesterChip({required this.semester, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$semester',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
