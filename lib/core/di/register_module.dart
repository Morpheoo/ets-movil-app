import 'package:injectable/injectable.dart';
import '../data/local/database_helper.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  DatabaseHelper get databaseHelper => DatabaseHelper.instance;
}
