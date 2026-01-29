import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/features/sync/presentation/widgets/pending_operation_card.dart';

/// Pending operations-ийн жагсаалт
///
/// SyncQueueData list-ийг PendingOperationCard widgets-р wrap хийнэ
class PendingOperationsList extends StatelessWidget {
  final List<SyncQueueData> operations;

  const PendingOperationsList({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    if (operations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: operations
          .map((op) => PendingOperationCard(operation: op))
          .toList(),
    );
  }
}
