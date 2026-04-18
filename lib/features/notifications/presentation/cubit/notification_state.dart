import 'package:equatable/equatable.dart';
import 'package:flutter_template/features/notifications/domain/entities/notification_interaction.dart';

final class NotificationState extends Equatable {
  const NotificationState({
    this.initializing = false,
    this.permissionGranted,
    this.systemNotificationsEnabled,
    this.lastInteraction,
    this.busy = false,
    this.message,
    this.errorMessage,
  });

  final bool initializing;
  final bool? permissionGranted;
  final bool? systemNotificationsEnabled;
  final NotificationInteraction? lastInteraction;
  final bool busy;
  final String? message;
  final String? errorMessage;

  NotificationState copyWith({
    bool? initializing,
    bool? permissionGranted,
    bool? systemNotificationsEnabled,
    bool updateSystemNotificationsEnabled = false,
    NotificationInteraction? lastInteraction,
    bool clearLastInteraction = false,
    bool? busy,
    String? message,
    bool clearMessage = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      initializing: initializing ?? this.initializing,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      systemNotificationsEnabled: updateSystemNotificationsEnabled
          ? systemNotificationsEnabled
          : (systemNotificationsEnabled ?? this.systemNotificationsEnabled),
      lastInteraction: clearLastInteraction ? null : (lastInteraction ?? this.lastInteraction),
      busy: busy ?? this.busy,
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        initializing,
        permissionGranted,
        systemNotificationsEnabled,
        lastInteraction,
        busy,
        message,
        errorMessage,
      ];
}
