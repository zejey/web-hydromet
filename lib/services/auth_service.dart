import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Firebase imports (optional, if you want to keep Firebase Auth fallback)
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, superadmin }

class AppUser {
  final String uid;
  final String username;
  final String email;
  final UserRole role;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    final roleStr = (data['role'] as String?)?.toLowerCase();
    final role = switch (roleStr) {
      'admin' => UserRole.admin,
      'superadmin' => UserRole.superadmin,
      _ => throw StateError('Unknown role for user: $roleStr'),
    };
    return AppUser(
      uid: uid,
      username: (data['username'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: role,
    );
  }
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Replace with your actual backend URL (without trailing slash)
  static const String _backendBase = 'https://caring-kindness-production.up.railway.app';
  static const String _loginEndpoint = '$_backendBase/api/admins/login';

  // For simplicity, storing JWT in secure storage
  final _secureStorage = const FlutterSecureStorage();

  // --------- BACKEND LOGIN (FastAPI/JWT) ---------
  Future<UserRole> loginWithBackend({
    required String usernameOrEmail,
    required String password,
  }) async {
    // Pick "email" if user types email, else username if your backend allows either
    final body = {
      // adjust the key if your backend expects "username" instead of "email"
      'email': usernameOrEmail,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(_loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

   
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      await _secureStorage.write(key: 'jwt_token', value: token);

      // Optionally decode JWT to get role
      UserRole? role;
      try {
        final parts = token.split('.');
        if (parts.length != 3) throw Exception("Bad JWT format");
        final payloadRaw = base64.normalize(parts[1]);
        final payload = json.decode(utf8.decode(base64Url.decode(payloadRaw)));
        print('LOGIN JWT payload: $payload');  // PRINT the JWT payload
        if (payload.containsKey('role')) {
          final roleStr = payload['role'] as String;
          role = switch (roleStr.toLowerCase()) {
            'admin' => UserRole.admin,
            'superadmin' => UserRole.superadmin,
            _ => UserRole.admin,
          };
        }
      } catch (_) {
        // Default to admin if missing or not readable
        role = UserRole.admin;
      }

      return role ?? UserRole.admin;
    } else {
      throw Exception('Invalid username or password');
    }
  }

  /// Returns the last stored JWT token, if any
  Future<String?> getJwtToken() => _secureStorage.read(key: 'jwt_token');

  /// Call this to clear the JWT token (logout)
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  Future<String?> sendForgotPasswordEmail({required String email}) async {
    final response = await http.post(
      Uri.parse('https://your-backend.com/api/admins/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: '{"email":"$email"}',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['msg'];
    } else {
      throw Exception("Failed to send reset request");
    }
  }

  // --------- OPTIONAL: Firebase login kept for reference below ---------

  /* 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String userCollection = 'admin';
  static const String _usernameEmailDomain = 'cdrrmo.local';

  String _normalizeToEmail(String input) {
    final s = input.trim();
    return s.contains('@') ? s : '$s@$_usernameEmailDomain';
  }

  Future<UserRole> loginWithFirebase({
    required String username,
    required String password,
  }) async {
    final email = _normalizeToEmail(username);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User authentication failed.',
        );
      }
      DocumentSnapshot<Map<String, dynamic>> doc = await _db
          .collection(userCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw StateError(
          'User profile not found in "$userCollection". Create a document for this user.',
        );
      }
      final data = doc.data()!;
      final appUser = AppUser.fromMap(doc.id, data);
      return appUser.role;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-email':
          throw Exception('Incorrect username or password');
        default:
          throw Exception(e.message ?? 'Authentication failed');
      }
    }
  }
  */

  // --------- USAGE: ---------
  // Call loginWithBackend(...) for FastAPI-based login.
  // Call getJwtToken() to get the currently saved token for API requests.
  // Call logout() to clear the token.
}
