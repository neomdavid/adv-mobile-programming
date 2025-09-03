import 'dart:convert';
import 'package:david_advmobprog/constants.dart';
import 'package:http/http.dart';

class ArticleService {
  List listData = [];

  Future<List> getAllArticle() async {
    print('ArticleService: Host is: $host');
    print('ArticleService: Making request to: $host/api/articles');

    Response response = await get(Uri.parse('$host/api/articles'));
    print('ArticleService: Response status: ${response.statusCode}');
    print('ArticleService: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('ArticleService: Parsed response: $jsonResponse');

      // Handle the actual response format from your backend
      print('ArticleService: Checking for articles field...');
      print('ArticleService: jsonResponse keys: ${jsonResponse.keys.toList()}');
      print(
          'ArticleService: articles field exists: ${jsonResponse.containsKey('articles')}');
      print('ArticleService: articles value: ${jsonResponse['articles']}');

      if (jsonResponse['articles'] != null) {
        print(
            'ArticleService: Returning ${jsonResponse['articles'].length} articles');
        return jsonResponse['articles'];
      } else {
        throw Exception('Invalid response format - no articles field found');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map> createArticle(dynamic article) async {
    Response response = await post(
      Uri.parse('$host/api/articles'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
          'Failed to create article: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map> updateArticle(String id, dynamic article) async {
    Response response = await put(
      Uri.parse('$host/api/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
          'Failed to update article: ${response.statusCode} - ${response.body}');
    }
  }
}
