import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/notifications/domain/entities/notification_interaction.dart';
import 'package:flutter_template/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_template/features/notifications/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(const NotificationState()) {
    _interactionSub = _repository.interactions.listen(_onInteraction);
  }

  final NotificationRepository _repository;
  StreamSubscription<NotificationInteraction>? _interactionSub;

  /// Call once after app start (e.g. from [BlocProvider.create]).
  Future<void> bootstrap() async {
    if (state.initializing) return;
    emit(state.copyWith(initializing: true, clearError: true, clearMessage: true));
    try {
      await _repository.initialize();
      await refreshStatus();
      emit(state.copyWith(initializing: false));
    } catch (e) {
      emit(
        state.copyWith(
          initializing: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshStatus() async {
    try {
      final system = await _repository.areNotificationsEnabled();
      emit(
        state.copyWith(
          updateSystemNotificationsEnabled: true,
          systemNotificationsEnabled: system,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> requestPermission() async {
    emit(state.copyWith(busy: true, clearError: true, clearMessage: true));
    try {
      final granted = await _repository.requestPermission();
      await refreshStatus();
      emit(
        state.copyWith(
          busy: false,
          permissionGranted: granted,
          message: granted ? 'Notifications enabled.' : 'Permission not granted.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
    }
  }

  Future<void> sendTestNotification() async {
    emit(state.copyWith(busy: true, clearError: true, clearMessage: true));
    try {
      await _repository.initialize();
      await _repository.showTestNotification(
        title: 'Flutter Template',
        body: 'Local notifications are wired. Tap to open notification settings.',
        payload: 'route:/notifications',
      );
      emit(
        state.copyWith(
          busy: false,
          message: 'Test notification sent.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
    }
  }

  void clearLastInteraction() {
    if (state.lastInteraction != null) {
      emit(state.copyWith(clearLastInteraction: true));
    }
  }

  void clearTransient() {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }

  void _onInteraction(NotificationInteraction interaction) {
    emit(state.copyWith(lastInteraction: interaction));
  }

  @override
  Future<void> close() async {
    await _interactionSub?.cancel();
    return super.close();
  }
}
