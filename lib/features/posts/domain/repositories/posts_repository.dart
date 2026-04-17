import 'package:flutter_template/features/posts/domain/entities/post_entity.dart';

abstract class PostsRepository {
  Future<PostEntity> getPost(int id);

  /// Calls GET/POST/PUT/PATCH/DELETE on the dummy API to prove the stack (dev/demo).
  Future<String> runHttpVerbsDemo();
}
