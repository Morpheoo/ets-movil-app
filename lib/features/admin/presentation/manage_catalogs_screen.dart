import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../domain/entities/career_entity.dart';
import '../domain/entities/classroom_entity.dart';
import 'providers/catalog_provider.dart';

class ManageCatalogsScreen extends StatelessWidget {
  const ManageCatalogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Gestión de Catálogos'),
          bottom: const TabBar(
            labelColor: AppColors.textOnPrimary,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.accentLight,
            tabs: [
              Tab(icon: Icon(Icons.school_outlined), text: 'Carreras'),
              Tab(icon: Icon(Icons.meeting_room_outlined), text: 'Salones'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CareersTab(),
            _ClassroomsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tab Carreras ──────────────────────────────────────────────────────────────

class _CareersTab extends ConsumerWidget {
  const _CareersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        data: (careers) => careers.isEmpty
            ? const _EmptyState(icon: Icons.school_outlined, label: 'No hay carreras registradas')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: careers.length,
                itemBuilder: (context, i) => _CareerTile(career: careers[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCareerDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCareerDialog(BuildContext context, WidgetRef ref, [CareerEntity? existing]) {
    showDialog(
      context: context,
      builder: (_) => _CareerDialog(existing: existing, ref: ref),
    );
  }
}

class _CareerTile extends ConsumerWidget {
  final CareerEntity career;
  const _CareerTile({required this.career});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            career.code,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        title: Text(career.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(
          career.isActive ? 'Activa' : 'Inactiva',
          style: TextStyle(fontSize: 11, color: career.isActive ? AppColors.success : AppColors.error),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _CareerDialog(existing: career, ref: ref),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar carrera'),
        content: Text('¿Eliminar "${career.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(careersProvider.notifier).delete(career.code);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CareerDialog extends StatefulWidget {
  final CareerEntity? existing;
  final WidgetRef ref;
  const _CareerDialog({this.existing, required this.ref});

  @override
  State<_CareerDialog> createState() => _CareerDialogState();
}

class _CareerDialogState extends State<_CareerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.existing?.code ?? '');
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final career = CareerEntity(
      code: _codeCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      isActive: _isActive,
    );
    if (widget.existing == null) {
      widget.ref.read(careersProvider.notifier).add(career);
    } else {
      widget.ref.read(careersProvider.notifier).edit(career);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar carrera' : 'Nueva carrera'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Código (ej. ISC)'),
              textCapitalization: TextCapitalization.characters,
              enabled: !isEdit, // el código es la PK, no se puede editar
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activa', style: TextStyle(fontSize: 14)),
              value: _isActive,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
          onPressed: _save,
          child: Text(isEdit ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}

// ── Tab Salones ───────────────────────────────────────────────────────────────

class _ClassroomsTab extends ConsumerWidget {
  const _ClassroomsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classroomsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        data: (classrooms) => classrooms.isEmpty
            ? const _EmptyState(icon: Icons.meeting_room_outlined, label: 'No hay salones registrados')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: classrooms.length,
                itemBuilder: (context, i) => _ClassroomTile(classroom: classrooms[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => _ClassroomDialog(ref: ref),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ClassroomTile extends ConsumerWidget {
  final ClassroomEntity classroom;
  const _ClassroomTile({required this.classroom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceVariant,
          child: Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 20),
        ),
        title: Text(classroom.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text('ID: ${classroom.id}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _ClassroomDialog(existing: classroom, ref: ref),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar salón'),
        content: Text('¿Eliminar "${classroom.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(classroomsProvider.notifier).delete(classroom.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ClassroomDialog extends StatefulWidget {
  final ClassroomEntity? existing;
  final WidgetRef ref;
  const _ClassroomDialog({this.existing, required this.ref});

  @override
  State<_ClassroomDialog> createState() => _ClassroomDialogState();
}

class _ClassroomDialogState extends State<_ClassroomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _roomCtrl;

  @override
  void initState() {
    super.initState();
    _buildingCtrl = TextEditingController(text: widget.existing?.building ?? '');
    _roomCtrl = TextEditingController(text: widget.existing?.room ?? '');
  }

  @override
  void dispose() {
    _buildingCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final building = _buildingCtrl.text.trim();
    final room = _roomCtrl.text.trim();
    final classroom = ClassroomEntity(
      id: widget.existing?.id ?? ClassroomEntity.buildId(building, room),
      building: building,
      room: room,
    );
    if (widget.existing == null) {
      widget.ref.read(classroomsProvider.notifier).add(classroom);
    } else {
      widget.ref.read(classroomsProvider.notifier).edit(classroom);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar salón' : 'Nuevo salón'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _buildingCtrl,
              decoration: const InputDecoration(labelText: 'Edificio (ej. Edificio 3)'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roomCtrl,
              decoration: const InputDecoration(labelText: 'Salón (ej. 301)'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
          onPressed: _save,
          child: Text(isEdit ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Usa el botón + para agregar', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
