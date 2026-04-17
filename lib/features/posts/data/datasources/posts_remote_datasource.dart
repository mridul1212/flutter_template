import 'package:flutter_template/core/network/api_client.dart';

/// Remote datasource for https://jsonplaceholder.typicode.com/posts
///
/// Demonstrates every HTTP verb through [ApiClient].
class PostsRemoteDataSource {
  PostsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchPost(int id) async {
    final response = await _api.get<dynamic>('/posts/$id');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid post response');
    }
    return data;
  }

  Future<void> createPostDemo() async {
    await _api.post<dynamic>(
      '/posts',
      data: <String, dynamic>{
        'title': 'Boilerplate',
        'body': 'Created via Dio POST',
        'userId': 1,
      },
      headers: <String, dynamic>{'X-Client': 'flutter_template'},
    );
  }

  Future<void> replacePostDemo() async {
    await _api.put<dynamic>(
      '/posts/1',
      data: <String, dynamic>{
        'id': 1,
        'title': 'Replaced',
        'body': 'PUT body',
        'userId': 1,
      },
    );
  }

  Future<void> patchPostDemo() async {
    await _api.patch<dynamic>(
      '/posts/1',
      data: <String, dynamic>{'title': 'Patched title'},
      headers: <String, dynamic>{'X-Client': 'flutter_template'},
    );
  }

  Future<void> deletePostDemo() async {
    await _api.delete<dynamic>('/posts/1');
  }
}
