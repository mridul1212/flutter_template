import 'package:equatable/equatable.dart';

/// How the user reached the app from a notification (for routing / analytics).
enum NotificationOpenSource {
  /// User tapped while the app was in memory (foreground or background).
  tap,

  /// App was opened from a terminated state via a notification tap.
  coldStart,
}

final class NotificationInteraction extends Equatable {
  const NotificationInteraction({
    required this.notificationId,
    this.actionId,
    this.payload,
    required this.source,
  });

  final String? notificationId;
  final String? actionId;
  final String? payload;
  final NotificationOpenSource source;

  @override
  List<Object?> get props => [notificationId, actionId, payload, source];
}
