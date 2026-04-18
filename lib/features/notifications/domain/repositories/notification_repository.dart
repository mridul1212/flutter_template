import 'package:flutter_template/features/notifications/domain/entities/notification_interaction.dart';

/// Local device notifications (channels, permission, display).
/// Push (FCM/APNs) can be added behind the same facade later.
abstract class NotificationRepository {
  /// Taps and cold-start opens from notifications.
  Stream<NotificationInteraction> get interactions;

  /// Initializes channels and handlers; safe to call once per process.
  Future<void> initialize();

  /// Android 13+ runtime prompt; iOS alert permission. No-op where not needed.
  Future<bool> requestPermission();

  /// Best-effort: `null` when the platform API is unavailable.
  Future<bool?> areNotificationsEnabled();

  /// Shows a simple local notification (for QA / wiring checks).
  Future<void> showTestNotification({required String title, required String body, String? payload});
}
