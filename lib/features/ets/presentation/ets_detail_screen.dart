import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_theme.dart';
import '../domain/entities/ets_entity.dart';

class EtsDetailScreen extends StatelessWidget {
  final EtsEntity ets;

  const EtsDetailScreen({super.key, required this.ets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(ets.career)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                border: Border(
                  bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ets.subject,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _CareerBadge(career: ets.career),
                      const SizedBox(width: 8),
                      Text(
                        'Plan ${ets.plan} • Semestre ${ets.semester}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Información del Examen ──
                  const _SectionTitle('Información del Examen'),
                  const SizedBox(height: 12),
                  _DetailRow(icon: Icons.calendar_today, label: 'Fecha', value: _formatDate(ets.date)),
                  _DetailRow(icon: Icons.access_time, label: 'Horario', value: ets.shift),
                  if (ets.classroom.isNotEmpty)
                    _DetailRow(icon: Icons.location_on, label: 'Salón/Laboratorio', value: ets.classroom),
                  _DetailRow(icon: Icons.school, label: 'Carrera', value: ets.careerFullName),

                  const Divider(height: 32),

                  // ── Coordinador ──
                  const _SectionTitle('Coordinador'),
                  const SizedBox(height: 12),
                  if (ets.professor.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              ets.professor.isNotEmpty ? ets.professor[0] : '?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ets.professor,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (ets.email.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () => _launchEmail(ets.email),
                                    child: Text(
                                      ets.email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (ets.email.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.email_outlined, color: AppColors.primary),
                              onPressed: () => _launchEmail(ets.email),
                            ),
                        ],
                      ),
                    ),

                  // ── Recursos ──
                  if (ets.guideUrl != null || ets.projectUrl != null) ...[
                    const Divider(height: 32),
                    const _SectionTitle('Recursos'),
                    const SizedBox(height: 12),
                    if (ets.guideUrl != null)
                      _ResourceButton(
                        icon: Icons.description_outlined,
                        label: 'Descargar Guía del ETS',
                        color: AppColors.primary,
                        onTap: () => _launchUrl(ets.guideUrl!),
                      ),
                    if (ets.projectUrl != null) ...[
                      const SizedBox(height: 8),
                      _ResourceButton(
                        icon: Icons.assignment_outlined,
                        label: 'Descargar Proyecto',
                        color: AppColors.warning,
                        onTap: () => _launchUrl(ets.projectUrl!),
                      ),
                    ],
                  ],

                  // ── Nota ──
                  if (ets.note != null && ets.note!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_outlined, size: 20, color: AppColors.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nota del Coordinador',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ets.note!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} de ${months[d.month]} de ${d.year}';
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try { await launchUrl(uri); } catch (_) {}
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (_) {}
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareerBadge extends StatelessWidget {
  final String career;
  const _CareerBadge({required this.career});

  Color get _color {
    switch (career) {
      case 'ISC': return AppColors.primary;
      case 'IIA': return const Color(0xFF2980B9);
      case 'LCD': return const Color(0xFF27AE60);
      case 'ISISA': return const Color(0xFFE67E22);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        career,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _color),
      ),
    );
  }
}

class _ResourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ResourceButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              ),
            ),
            Icon(Icons.download_outlined, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
