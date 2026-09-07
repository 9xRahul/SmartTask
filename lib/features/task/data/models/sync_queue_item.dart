import 'package:equatable/equatable.dart';

enum SyncActionType { create, update, delete }

/// Represents an offline action queued for synchronization with the REST API.
class SyncQueueItem extends Equatable {
  final String queueId;
  final SyncActionType actionType;
  final dynamic taskId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;

  const SyncQueueItem({
    required this.queueId,
    required this.actionType,
    required this.taskId,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'queueId': queueId,
      'actionType': actionType.name,
      'taskId': taskId,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncQueueItem.fromMap(Map<dynamic, dynamic> map) {
    SyncActionType type = SyncActionType.create;
    final actionStr = map['actionType']?.toString().toLowerCase();
    if (actionStr == 'update') {
      type = SyncActionType.update;
    } else if (actionStr == 'delete') {
      type = SyncActionType.delete;
    }

    return SyncQueueItem(
      queueId: map['queueId']?.toString() ?? '',
      actionType: type,
      taskId: map['taskId'],
      payload: Map<String, dynamic>.from(map['payload'] as Map? ?? {}),
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      retryCount: map['retryCount'] is int ? map['retryCount'] as int : 0,
    );
  }

  SyncQueueItem copyWith({
    String? queueId,
    SyncActionType? actionType,
    dynamic taskId,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return SyncQueueItem(
      queueId: queueId ?? this.queueId,
      actionType: actionType ?? this.actionType,
      taskId: taskId ?? this.taskId,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  List<Object?> get props => [queueId, actionType, taskId, payload, timestamp, retryCount];
}
