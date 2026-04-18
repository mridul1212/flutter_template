import 'package:flutter_template/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:flutter_template/features/notifications/domain/entities/notification_interaction.dart';
import 'package:flutter_template/features/notifications/domain/repositories/notification_repository.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._local);

  final LocalNotificationDataSource _local;

  var _initialized = false;

  @override
  Stream<NotificationInteraction> get interactions => _local.interactions;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _local.initialize();
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() => _local.requestPermission();

  @override
  Future<bool?> areNotificationsEnabled() => _local.areNotificationsEnabled();

  @override
  Future<void> showTestNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    return _local.showTestNotification(title: title, body: body, payload: payload);
  }
}
