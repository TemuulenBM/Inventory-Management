import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/database/app_database.dart';

part 'database_provider.g.dart';

/// Database provider (singleton)
///
/// AppDatabase singleton instance-ийг Riverpod-оор хүрч авах
/// Drift database operations-д ашиглагдана
@riverpod
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}
