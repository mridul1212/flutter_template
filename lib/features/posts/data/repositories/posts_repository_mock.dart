import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_template/features/posts/domain/repositories/posts_repository.dart';

class PostsRepositoryMock implements PostsRepository {
  PostsRepositoryMock();

  @override
  Future<PostEntity> getPost(int id) async {
    // For demo purposes, we keep one fixture and ignore [id] if it's not 1.
    final raw = await rootBundle.loadString('assets/mock/post_1.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw StateError('Invalid mock post JSON');
    }
    return PostEntity(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  @override
  Future<String> runHttpVerbsDemo() async {
    // Simulates the full sequence without touching network.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'MOCK: GET → POST → PUT → PATCH → DELETE completed (asset fixtures).';
  }
}

