import 'dart:convert';
import 'package:david_advmobprog/constants.dart';
import 'package:http/http.dart';

class ArticleService {
  List listData = [];

  Future<List> getAllArticle() async {
    Response response = await get(Uri.parse('$host/posts'));

    if (response.statusCode == 200) {
      listData = jsonDecode(response.body);

      return listData;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
