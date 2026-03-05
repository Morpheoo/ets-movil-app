import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../domain/entities/ets_entity.dart';

class EtsCard extends StatelessWidget {
  final EtsEntity ets;
  final VoidCallback? onTap;

  const EtsCard({super.key, required this.ets, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject + career badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ets.subject,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _careerColor(ets.career).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ets.career,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _careerColor(ets.career),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Plan + semester code
            Text(
              'Plan ${ets.plan} • Semestre ${ets.semester}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            // Info chips row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _InfoChip(icon: Icons.access_time, text: ets.shift.split(' y ').first),
                if (ets.classroom.isNotEmpty)
                  _InfoChip(icon: Icons.location_on_outlined, text: ets.classroom),
              ],
            ),
            const SizedBox(height: 8),
            // Professor
            if (ets.professor.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ets.professor,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Guide/Project icons
                  if (ets.guideUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.description_outlined, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
                    ),
                  if (ets.projectUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.assignment_outlined, size: 16, color: AppColors.warning),
                    ),
                ],
              ),
            // Note
            if (ets.note != null && ets.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ets.note!,
                        style: const TextStyle(fontSize: 11, color: AppColors.warning),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _careerColor(String career) {
    switch (career) {
      case 'ISC': return AppColors.primary;
      case 'IIA': return const Color(0xFF2980B9);
      case 'LCD': return const Color(0xFF27AE60);
      case 'ISISA': return const Color(0xFFE67E22);
      default: return AppColors.primary;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
