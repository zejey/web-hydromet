import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminManagementService {
  // Replace this with your actual API base URL
  static const String baseUrl = 'https://caring-kindness-production.up.railway.app/api';
  
  // Optional: Add authentication token if needed
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Fetch all admins from API
  Future<List<Map<String, dynamic>>> fetchAdmins() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admins/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((admin) {
          return {
            'id': admin['admin_id']?.toString() ?? admin['id']?.toString() ?? '',
            'username': admin['username'] ?? '',
            'email': admin['email'] ?? '',
            'role': admin['role'] ?? 'admin',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch admins: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching admins: $e');
    }
  }

  /// Add a new admin
  Future<void> addAdmin(Map<String, dynamic> adminData) async {
    try {
      // Generate UID if not provided (using timestamp + random suffix)
      final uid = adminData['uid'] ?? 
                  '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
      
      final requestBody = {
        'email': adminData['email'] ?? '',
        'role': adminData['role'] ?? 'admin',
        'username': adminData['username'] ?? '',
        'uid': uid, // Auto-generated or provided UID
      };
      
      print('Sending POST request to: $baseUrl/admins/');
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/admins/'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Try to parse error message from response
        String errorMessage = 'Failed to add admin: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {
          errorMessage = 'Failed to add admin: ${response.statusCode} - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error adding admin: $e');
    }
  }

  /// Edit an admin by ID
  Future<void> editAdmin(String adminId, Map<String, dynamic> adminData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admins/$adminId'),
        headers: _headers,
        body: json.encode({
          'username': adminData['username'] ?? '',
          'email': adminData['email'] ?? '',
          'role': adminData['role'] ?? 'admin',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update admin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating admin: $e');
    }
  }

  /// Delete an admin by ID
  Future<void> deleteAdmin(String adminId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admins/$adminId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete admin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting admin: $e');
    }
  }

  /// Get a single admin by ID
  Future<Map<String, dynamic>?> getAdmin(String adminId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admins/$adminId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final admin = json.decode(response.body);
        return {
          'id': admin['admin_id']?.toString() ?? admin['id']?.toString() ?? '',
          'username': admin['username'] ?? '',
          'email': admin['email'] ?? '',
          'role': admin['role'] ?? 'admin',
        };
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get admin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting admin: $e');
    }
  }
}
