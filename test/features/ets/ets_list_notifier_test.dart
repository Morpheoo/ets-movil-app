import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ets_movil/core/error/failures.dart';
import 'package:ets_movil/features/ets/domain/entities/ets_entity.dart';
import 'package:ets_movil/features/ets/domain/repositories/ets_repository.dart';
import 'package:ets_movil/features/ets/presentation/providers/ets_provider.dart';

EtsEntity _ets({
  required String id,
  String subject = 'Cálculo',
  String career = 'ISC',
  int semester = 1,
  String professor = 'García',
  String classroom = '3301',
}) {
  return EtsEntity(
    id: id,
    subject: subject,
    career: career,
    semester: semester,
    date: DateTime(2026, 2, 10),
    shift: '08:00 - 10:00',
    classroom: classroom,
    professor: professor,
  );
}

class _FakeEtsRepository implements EtsRepository {
  _FakeEtsRepository(this.list);
  final List<EtsEntity> list;
  Object? errorToThrow;

  @override
  Future<List<EtsEntity>> getEtsList({String? career, int? semester}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return list;
  }

  @override
  Future<List<EtsEntity>> searchEts(String query) async => list;

  @override
  Future<void> saveEts(EtsEntity ets) async {}

  @override
  Future<List<EtsEntity>> getSavedEts() async => const [];

  @override
  Future<void> removeSavedEts(String id) async {}
}

ProviderContainer _containerWith(EtsRepository repo) {
  final container = ProviderContainer(
    overrides: [etsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('EtsListNotifier', () {
    final all = [
      _ets(id: '1', career: 'ISC', semester: 1, subject: 'Cálculo'),
      _ets(id: '2', career: 'ISC', semester: 3, subject: 'POO'),
      _ets(id: '3', career: 'IIA', semester: 1, subject: 'Redes Neuronales'),
      _ets(id: '4', career: 'LCD', semester: 5, subject: 'Estadística'),
      _ets(id: '5', career: 'ISISA', semester: 7, subject: 'Motores'),
    ];

    test('build() carga todos los exámenes', () async {
      final container = _containerWith(_FakeEtsRepository(all));
      final data = await container.read(etsListProvider.future);
      expect(data.length, 5);
    });

    test('filter(career) deja solo los de esa carrera', () async {
      final container = _containerWith(_FakeEtsRepository(all));
      await container.read(etsListProvider.future);

      container.read(etsListProvider.notifier).filter(career: 'ISC');
      final state = container.read(etsListProvider).value!;
      expect(state.length, 2);
      expect(state.every((e) => e.career == 'ISC'), isTrue);
    });

    test('filterBySemester combinado con filter(career) intersecta filtros', () async {
      final container = _containerWith(_FakeEtsRepository(all));
      await container.read(etsListProvider.future);

      final notifier = container.read(etsListProvider.notifier);
      notifier.filter(career: 'ISC');
      notifier.filterBySemester(1);

      final state = container.read(etsListProvider).value!;
      expect(state.length, 1);
      expect(state.first.id, '1');
    });

    test('search() filtra por subject, professor, classroom o career', () async {
      final container = _containerWith(_FakeEtsRepository(all));
      await container.read(etsListProvider.future);

      container.read(etsListProvider.notifier).search('motores');
      final state = container.read(etsListProvider).value!;
      expect(state.length, 1);
      expect(state.first.career, 'ISISA');
    });

    test('clearFilters() restaura la lista completa', () async {
      final container = _containerWith(_FakeEtsRepository(all));
      await container.read(etsListProvider.future);

      final notifier = container.read(etsListProvider.notifier);
      notifier.filter(career: 'ISC');
      notifier.clearFilters();

      final state = container.read(etsListProvider).value!;
      expect(state.length, 5);
    });

    test('availableSemesters devuelve semestres únicos ordenados', () async {
      final container = _containerWith(_FakeEtsRepository(all));
      await container.read(etsListProvider.future);

      final notifier = container.read(etsListProvider.notifier);
      expect(notifier.availableSemesters, [1, 3, 5, 7]);
    });

    test('propaga NetworkFailure cuando el repo falla', () async {
      final repo = _FakeEtsRepository(const [])
        ..errorToThrow = const NetworkFailure('sin red');
      final container = _containerWith(repo);

      await expectLater(
        container.read(etsListProvider.future),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
