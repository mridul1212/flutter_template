import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/community/data/models/community_models.dart';
import 'package:flutter_template/features/community/data/repositories/community_repository.dart';

enum CommunityLoad { initial, loading, success, failure, sending }

final class CommunityState extends Equatable {
  const CommunityState({
    this.load = CommunityLoad.initial,
    this.rooms = const [],
    this.error,
    this.activeRoomId,
    this.messages = const [],
  });

  final CommunityLoad load;
  final List<ChatRoom> rooms;
  final String? error;
  final String? activeRoomId;
  final List<ChatMessage> messages;

  CommunityState copyWith({
    CommunityLoad? load,
    List<ChatRoom>? rooms,
    String? error,
    String? activeRoomId,
    List<ChatMessage>? messages,
    bool clearError = false,
    bool clearRoom = false,
  }) {
    return CommunityState(
      load: load ?? this.load,
      rooms: rooms ?? this.rooms,
      error: clearError ? null : (error ?? this.error),
      activeRoomId: clearRoom ? null : (activeRoomId ?? this.activeRoomId),
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [load, rooms, error, activeRoomId, messages];
}

class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit(this._repo) : super(const CommunityState());

  final CommunityRepository _repo;

  Future<void> loadRooms() async {
    emit(state.copyWith(load: CommunityLoad.loading, clearError: true));
    try {
      final data = await _repo.fetchRooms();
      emit(state.copyWith(load: CommunityLoad.success, rooms: data.rooms));
    } catch (e) {
      emit(state.copyWith(load: CommunityLoad.failure, error: e.toString()));
    }
  }

  Future<void> openRoom(String roomId) async {
    emit(state.copyWith(activeRoomId: roomId, load: CommunityLoad.loading, clearError: true));
    try {
      final msgs = await _repo.fetchMessages(roomId);
      emit(state.copyWith(load: CommunityLoad.success, messages: msgs));
    } catch (e) {
      emit(state.copyWith(load: CommunityLoad.failure, error: e.toString()));
    }
  }

  Future<void> send(String text) async {
    final roomId = state.activeRoomId;
    if (roomId == null) return;
    emit(state.copyWith(load: CommunityLoad.sending, clearError: true));
    try {
      final msg = await _repo.sendMessage(roomId: roomId, text: text);
      emit(state.copyWith(load: CommunityLoad.success, messages: [...state.messages, msg]));
    } catch (e) {
      emit(state.copyWith(load: CommunityLoad.success, error: e.toString()));
    }
  }

  void closeRoom() => emit(state.copyWith(clearRoom: true, messages: const []));
}
