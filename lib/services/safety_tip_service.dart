import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyTipService {
  static const String baseUrl =
      'https://caring-kindness-production.up.railway.app/api/safety';

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

  // ==================== CATEGORIES ====================

  /// Get all safety categories
  Future<List<Map<String, dynamic>>> getCategories(
      {bool activeOnly = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories?active_only=$activeOnly'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((cat) => cat as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Get single category by ID
  Future<Map<String, dynamic>> getCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Category not found');
      } else {
        throw Exception('Failed to fetch category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category: $e');
    }
  }

  /// Create a new category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String description,
    required int orderNum,
    required String icon,
    required List<String> gradientColors,
    bool isActive = true,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'description': description,
        'order_num': orderNum,
        'icon': icon,
        'gradient_colors': gradientColors,
        'is_active': isActive,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/categories/'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Failed to create category: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail']?.toString() ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  /// Update a category
  Future<Map<String, dynamic>> updateCategory(
    int categoryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$categoryId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // ==================== TIPS ====================

  /// Get all tips for a specific category (with details/bullet points)
  Future<List<Map<String, dynamic>>> getTipsForCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tips/category/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((tip) => tip as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tips: $e');
    }
  }

  /// Get all tips (without details)
  Future<List<Map<String, dynamic>>> getAllTips({bool activeOnly = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tips?active_only=$activeOnly'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((tip) => tip as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tips: $e');
    }
  }

  /// Get single tip by ID (with details)
  Future<Map<String, dynamic>> getTip(int tipId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tips/$tipId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Tip not found');
      } else {
        throw Exception('Failed to fetch tip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tip: $e');
    }
  }

  /// Create a new tip
  Future<Map<String, dynamic>> createTip({
    required int categoryId,
    required String rangeLabel,
    required String level,
    required String color,
    int orderNum = 0,
    bool isActive = true,
  }) async {
    try {
      final requestBody = {
        'category_id': categoryId,
        'range_label': rangeLabel,
        'level': level,
        'color': color,
        'order_num': orderNum,
        'is_active': isActive,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/tips/'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Failed to create tip: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail']?.toString() ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error creating tip: $e');
    }
  }

  /// Update a tip
  Future<Map<String, dynamic>> updateTip(
    int tipId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tips/$tipId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update tip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating tip: $e');
    }
  }

  /// Delete a tip
  Future<void> deleteTip(int tipId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tips/$tipId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete tip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting tip: $e');
    }
  }

  // ==================== TIP DETAILS (Bullet Points) ====================

  /// Add a bullet point/detail to a tip
  Future<Map<String, dynamic>> addTipDetail({
    required int tipId,
    required String description,
    int orderNum = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tips/$tipId/details?description=${Uri.encodeComponent(description)}&order_num=$orderNum'),
        headers: _headers,
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add tip detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding tip detail: $e');
    }
  }

  /// Delete a tip detail/bullet point
  Future<void> deleteTipDetail(int detailId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tips/details/$detailId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete tip detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting tip detail: $e');
    }
  }
}
