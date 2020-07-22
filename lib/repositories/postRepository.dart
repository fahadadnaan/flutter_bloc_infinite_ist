import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc_infinite_list/models/models.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts(int startIndex, int limit);
}

class PostRepositoryImpl implements PostRepository {
  @override
  Future<List<Post>> getPosts(int startIndex, int limit) async {
    var response =  await http.get('https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if(response.statusCode == 200){
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }

}