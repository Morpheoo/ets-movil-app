import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';

// Proveedor global del cliente HTTP.
// Compartido entre todos los features que necesiten hacer llamadas a la API.
final dioClientProvider = Provider<DioClient>((ref) => DioClient());
