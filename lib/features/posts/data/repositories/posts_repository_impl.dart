import 'package:flutter_template/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_template/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_template/features/posts/domain/repositories/posts_repository.dart';

class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl(this._remote);

  final PostsRemoteDataSource _remote;

  @override
  Future<PostEntity> getPost(int id) async {
    final json = await _remote.fetchPost(id);
    return PostEntity(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  @override
  Future<String> runHttpVerbsDemo() async {
    await _remote.fetchPost(1);
    await _remote.createPostDemo();
    await _remote.replacePostDemo();
    await _remote.patchPostDemo();
    await _remote.deletePostDemo();
    return 'GET → POST → PUT → PATCH → DELETE completed (dummy API).';
  }
}
