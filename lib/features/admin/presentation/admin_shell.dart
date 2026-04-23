import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'manage_catalogs_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    _ExamsManageScreen(),
    ManageCatalogsScreen(),
    _AdminSettingsPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'DASH'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'EXAMS'),
            BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'CATÁLOGOS'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'SETTS'),
          ],
        ),
      ),
    );
  }
}

class _ExamsManageScreen extends StatelessWidget {
  const _ExamsManageScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Exams')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExamTile(context, 'Cálculo I', 'ISC - Semestre 1', 'Jun 15, 2024'),
          _buildExamTile(context, 'Estructuras de Datos', 'ISC - Semestre 3', 'Jun 18, 2024'),
          _buildExamTile(context, 'POO', 'ISC - Semestre 2', 'Jun 20, 2024'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/manage-ets'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExamTile(BuildContext context, String subject, String info, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$info • $date', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
        onTap: () => context.push('/manage-ets'),
      ),
    );
  }
}


class _AdminSettingsPlaceholder extends StatelessWidget {
  const _AdminSettingsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Configuración próximamente'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
