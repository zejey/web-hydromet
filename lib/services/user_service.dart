import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String _baseUrl = 'https://caring-kindness-production.up.railway.app/api/users/';

  // Get all users
  static Future<List<UserModel>> getUsers() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  // Get user by ID
  static Future<UserModel> getUserById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load user');
  }

  // Create user
  static Future<UserModel> addUser(UserModel user) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return UserModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to add user');
  }

  // Update user
  static Future<void> updateUser(String id, UserModel user) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  // Delete user
  static Future<void> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  // Check if phone exists (returns UserModel if found, null if not)
  static Future<UserModel?> getUserByPhone(String phone) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}phone/$phone'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Not found
    }
    throw Exception('Failed to get user by phone');
  }
}
