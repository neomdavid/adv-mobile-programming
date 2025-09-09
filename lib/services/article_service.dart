import 'dart:convert';
import 'package:david_advmobprog/constants.dart';
import 'package:http/http.dart';

class ArticleService {
  List listData = [];

  Future<List> getAllArticle() async {
    Response response = await get(Uri.parse('$host/api/articles'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        return jsonResponse['data'];
      } else {
        throw Exception('Invalid response format - expected data list');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getArticleById(String id) async {
    Response response = await get(Uri.parse('$host/api/articles/$id'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Some backends return the single record directly or inside data
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return Map<String, dynamic>.from(jsonResponse['data']);
      }
      return Map<String, dynamic>.from(jsonResponse);
    } else {
      throw Exception('Failed to load article: ${response.statusCode}');
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
