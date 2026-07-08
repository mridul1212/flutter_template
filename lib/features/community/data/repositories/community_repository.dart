import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/community/data/models/community_models.dart';

abstract class CommunityRepository {
  Future<CommunityData> fetchRooms();
  Future<List<ChatMessage>> fetchMessages(String roomId);
  Future<ChatMessage> sendMessage({required String roomId, required String text});
}

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityData? _cache;

  Future<CommunityData> _data() async {
    if (_cache != null) return _cache!;
    final text = await rootBundle.loadString('assets/mock/community_chat.json');
    _cache = CommunityData.fromJson(jsonDecode(text) as Map<String, dynamic>);
    return _cache!;
  }

  @override
  Future<CommunityData> fetchRooms() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _data();
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final data = await _data();
    return [...(data.messagesByRoom[roomId] ?? const [])];
  }

  @override
  Future<ChatMessage> sendMessage({required String roomId, required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw Exception('Message cannot be empty');
    if (trimmed.length > 500) throw Exception('Message too long (max 500)');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return ChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'You',
      text: trimmed,
      time: 'Now',
      isMe: true,
    );
  }
}
