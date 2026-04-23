import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ets_entity.dart';
import '../../domain/repositories/ets_repository.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/di/injection.dart';

// Providers
final etsRepositoryProvider = Provider<EtsRepository>((ref) => getIt<EtsRepository>());

// Notifiers
final etsListProvider = AsyncNotifierProvider<EtsListNotifier, List<EtsEntity>>(EtsListNotifier.new);

class EtsListNotifier extends AsyncNotifier<List<EtsEntity>> {
  List<EtsEntity> _allEts = [];
  String? _currentCareer;
  int? _currentSemester;
  String _currentQuery = '';

  @override
  Future<List<EtsEntity>> build() async {
    _allEts = await _fetchAll();
    return _allEts;
  }

  Future<List<EtsEntity>> _fetchAll() async {
    final repository = ref.read(etsRepositoryProvider);
    return await repository.getEtsList();
  }

  /// Apply all filters combined: career + semester + text
  void _applyFilters() {
    var results = List<EtsEntity>.from(_allEts);

    // Career filter
    if (_currentCareer != null && _currentCareer!.isNotEmpty) {
      results = results.where((e) => e.career == _currentCareer).toList();
    }

    // Semester filter
    if (_currentSemester != null) {
      results = results.where((e) => e.semester == _currentSemester).toList();
    }

    // Text search
    if (_currentQuery.isNotEmpty) {
      final q = _currentQuery.toLowerCase();
      results = results.where((e) {
        return e.subject.toLowerCase().contains(q) ||
            e.professor.toLowerCase().contains(q) ||
            e.classroom.toLowerCase().contains(q) ||
            e.career.toLowerCase().contains(q) ||
            e.careerFullName.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q) ||
            (e.note?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    state = AsyncValue.data(results);
  }

  void filter({String? career}) {
    _currentCareer = career;
    _applyFilters();
  }

  void filterBySemester(int? semester) {
    _currentSemester = semester;
    _applyFilters();
  }

  void search(String query) {
    _currentQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _currentCareer = null;
    _currentSemester = null;
    _currentQuery = '';
    state = AsyncValue.data(_allEts);
  }

  /// Get available semesters (for dynamic UI)
  List<int> get availableSemesters {
    final semesters = _allEts.map((e) => e.semester).toSet().toList();
    semesters.sort();
    return semesters;
  }
}

final savedEtsProvider = AsyncNotifierProvider<SavedEtsNotifier, List<EtsEntity>>(SavedEtsNotifier.new);

class SavedEtsNotifier extends AsyncNotifier<List<EtsEntity>> {
  @override
  Future<List<EtsEntity>> build() async {
     final repository = ref.read(etsRepositoryProvider);
     return await repository.getSavedEts();
  }
  
  Future<void> toggleSave(EtsEntity ets) async {
     final repository = ref.read(etsRepositoryProvider);
     final currentList = state.value ?? [];
     final isSaved = currentList.any((e) => e.id == ets.id);
     
     if (isSaved) {
       await repository.removeSavedEts(ets.id);
       await NotificationService().cancelReminder(ets.id);
     } else {
       await repository.saveEts(ets);
       await NotificationService().scheduleEtsReminder(ets);
     }
     // Refresh list
     ref.invalidateSelf();
  }
}
