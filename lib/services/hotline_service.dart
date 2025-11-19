import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emergency_hotline.dart';

class HotlineService {
  // TODO: Replace with your actual Railway URL
  static const String _baseUrl = 'https://caring-kindness-production.up.railway.app/api/hotlines/';
  
  static final _hotlinesController = StreamController<List<EmergencyHotline>>.broadcast();
  static Timer? _pollingTimer;

  /// Get hotlines as a stream (uses polling to simulate real-time updates)
  static Stream<List<EmergencyHotline>> getHotlinesStream() {
    // Start polling if not already started
    _startPolling();
    return _hotlinesController.stream;
  }

  /// Start polling the API for updates
  static void _startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;
    
    // Initial fetch
    _fetchHotlines();
    
    // Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchHotlines();
    });
  }

  /// Stop polling (call this when the widget is disposed)
  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetch hotlines from the API
  static Future<void> _fetchHotlines() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?active_only=false'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Even if empty, return empty list (not an error)
        final hotlines = data
            .map((json) => EmergencyHotline.fromJson(json))
            .toList();
        
        // Sort by priority
        hotlines.sort((a, b) => a.priority.compareTo(b.priority));
        
        _hotlinesController.add(hotlines);
      } else if (response.statusCode == 404) {
        // Table might be empty or endpoint not found
        // Return empty list instead of error
        _hotlinesController.add([]);
      } else {
        _hotlinesController.addError(
          'Failed to load hotlines: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Network error or other issues
      _hotlinesController.addError('Error fetching hotlines: $e');
    }
  }

  /// Check if hotlines table is empty
  static Future<bool> isEmpty() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?active_only=false'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.isEmpty;
      }
      
      // If we get 404 or other error, assume empty
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Get count of hotlines
  static Future<int> getCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?active_only=false'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Add a new hotline
  static Future<void> addHotline(EmergencyHotline hotline) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(hotline.toJson()),
      );

      if (response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to add hotline: ${errorBody['detail'] ?? response.statusCode}');
      }

      // Refresh the stream
      await _fetchHotlines();
    } catch (e) {
      throw Exception('Error adding hotline: $e');
    }
  }

  /// Update an existing hotline
  static Future<void> updateHotline(EmergencyHotline hotline) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl${hotline.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(hotline.toJson()),
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to update hotline: ${errorBody['detail'] ?? response.statusCode}');
      }

      // Refresh the stream
      await _fetchHotlines();
    } catch (e) {
      throw Exception('Error updating hotline: $e');
    }
  }

  /// Delete a hotline
  static Future<void> deleteHotline(String? id) async {
  if (id == null || id.isEmpty) {
    throw Exception('Hotline ID is required for delete');
  }
  try {
    final response = await http.delete(
      Uri.parse('$_baseUrl$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      throw Exception(
        'Failed to delete hotline: ${errorBody['detail'] ?? response.statusCode}'
      );
    }

    await _fetchHotlines();
  } catch (e) {
    throw Exception('Error deleting hotline: $e');
  }
}
  /// Get hotlines by category
  static Future<List<EmergencyHotline>> getHotlinesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => EmergencyHotline.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get a single hotline by ID
  static Future<EmergencyHotline> getHotlineById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EmergencyHotline.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Hotline not found');
      } else {
        throw Exception('Failed to load hotline: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching hotline: $e');
    }
  }

  /// Dispose resources
  static void dispose() {
    stopPolling();
    _hotlinesController.close();
  }
}
