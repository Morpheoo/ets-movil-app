import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/ets_entity.dart';
import '../models/ets_model.dart';

abstract class EtsRemoteDataSource {
  Future<List<EtsEntity>> getEtsList({String? career, int? semester});
  Future<List<EtsEntity>> searchEts(String query);
}

// Implementación real: usa Dio + EtsModel.fromJson.
// Activar cuando el backend esté disponible (quitar @LazySingleton del Mock).
class EtsRemoteDataSourceImpl implements EtsRemoteDataSource {
  final DioClient _dioClient;

  EtsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<EtsEntity>> getEtsList({String? career, int? semester}) async {
    try {
      final response = await _dioClient.dio.get(
        '/ets',
        queryParameters: {
          if (career != null && career.isNotEmpty) 'career': career,
          if (semester != null && semester > 0) 'semester': semester,
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<EtsEntity>> searchEts(String query) async {
    try {
      final response = await _dioClient.dio.get(
        '/ets/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}

// Mock para desarrollo: carga datos del período ETS Especial 2026-1 desde assets.
@LazySingleton(as: EtsRemoteDataSource)
class EtsRemoteDataSourceMock implements EtsRemoteDataSource {
  List<EtsEntity>? _cache;

  Future<List<EtsEntity>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/ets_data.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((j) => EtsModel.fromJson(j as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  @override
  Future<List<EtsEntity>> getEtsList({String? career, int? semester}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var result = List<EtsEntity>.from(await _loadAll());

    if (career != null && career.isNotEmpty) {
      result = result.where((e) => e.career == career).toList();
    }
    if (semester != null && semester > 0) {
      result = result.where((e) => e.semester == semester).toList();
    }

    result.sort((a, b) => a.subject.compareTo(b.subject));
    return result;
  }

  @override
  Future<List<EtsEntity>> searchEts(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = await _loadAll();
    return all.where((e) => e.matches(query)).toList();
  }
}
