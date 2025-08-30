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
      
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        print('ArticleService: Returning ${jsonResponse['data'].length} articles');
        return jsonResponse['data'];
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
