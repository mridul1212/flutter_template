import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_template/features/notifications/domain/entities/notification_interaction.dart';

/// Wraps [FlutterLocalNotificationsPlugin] — keep platform details here only.
final class LocalNotificationDataSource {
  LocalNotificationDataSource() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationInteraction> _interactions =
      StreamController<NotificationInteraction>.broadcast();

  static const _channelId = 'app_general';
  static const _channelName = 'General';
  static const _channelDescription = 'App messages and reminders';

  Stream<NotificationInteraction> get interactions => _interactions.stream;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onForegroundResponse,
    );

    await _ensureAndroidChannel();

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      final response = launch!.notificationResponse;
      if (response != null) {
        _emit(response, NotificationOpenSource.coldStart);
      }
    }
  }

  Future<void> _ensureAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
    );
    await android.createNotificationChannel(channel);
  }

  void _onForegroundResponse(NotificationResponse response) {
    _emit(response, NotificationOpenSource.tap);
  }

  void _emit(NotificationResponse response, NotificationOpenSource source) {
    if (_interactions.isClosed) return;
    _interactions.add(
      NotificationInteraction(
        notificationId: response.id?.toString(),
        actionId: response.actionId,
        payload: response.payload,
        source: source,
      ),
    );
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted != null) return granted;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
      if (granted != null) return granted;
    }

    return true;
  }

  Future<bool?> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return android?.areNotificationsEnabled();
  }

  Future<void> showTestNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
