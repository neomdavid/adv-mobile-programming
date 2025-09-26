import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:david_advmobprog/constants.dart';

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    Response response = await post(Uri.parse('$host/api/users/login'),
        body: {'email': email, 'password': password});

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    Response response = await post(
      Uri.parse('$host/api/users'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
          'Failed to register user: ${response.statusCode} - ${response.body}');
    }
  }

  /// Save data into SharedPreferences
  /// **Save User Data to SharedPreferences**
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', userData['firstName'] ?? '');
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setString('type', userData['type'] ?? '');
    await prefs.setString('_id', userData['_id'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setBool('isActive', userData['isActive'] ?? true);
  }

  /// **Retrieve User Data from SharedPreferences**
  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('firstName') ?? '',
      'token': prefs.getString('token') ?? '',
      'type': prefs.getString('type') ?? '',
      '_id': prefs.getString('_id') ?? '',
      'email': prefs.getString('email') ?? '',
      'isActive': prefs.getBool('isActive') ?? true,
    };
  }

  /// **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /// **Logout and Clear User Data**
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    Response response = await get(Uri.parse('$host/api/users/$userId'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['data'] != null) {
        return Map<String, dynamic>.from(jsonResponse['data']);
      }
      throw Exception('Invalid response format - no data field found');
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }
}
