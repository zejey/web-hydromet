import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
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

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': switch (role) {
        UserRole.admin => 'admin',
        UserRole.superadmin => 'superadmin',
      },
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Your Firestore collection
  static const String userCollection = 'admin';

  // If user types a plain username, we map it to an email with this domain.
  static const String _usernameEmailDomain = 'cdrrmo.local';

  // Accepts either an email or a username. If it looks like an email, use as-is.
  String _normalizeToEmail(String input) {
    final s = input.trim();
    return s.contains('@') ? s : '$s@$_usernameEmailDomain';
  }

  Future<UserRole> loginWithUsernamePassword({
    required String username, // may actually be email
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

      // First try doc keyed by uid
      DocumentSnapshot<Map<String, dynamic>> doc = await _db
          .collection(userCollection)
          .doc(uid)
          .get();

      // Fallback: by email, then by username
      if (!doc.exists) {
        final byEmail = await _db
            .collection(userCollection)
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (byEmail.docs.isNotEmpty) {
          doc = byEmail.docs.first;
        } else {
          final byUsername = await _db
              .collection(userCollection)
              .where('username', isEqualTo: username.trim())
              .limit(1)
              .get();
          if (byUsername.docs.isNotEmpty) {
            doc = byUsername.docs.first;
          }
        }
      }

      if (!doc.exists) {
        await _auth.signOut();
        throw StateError(
          'User profile not found in "$userCollection". Create a document for this user.',
        );
      }

      final data = doc.data()!;
      final appUser = AppUser.fromFirestore(doc.id, data);
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

  Future<void> signOut() => _auth.signOut();

  // Optional: seed demo users (adjust emails if you want to use real domains)
  Future<void> seedDemoUsers() async {
    assert(kDebugMode, 'seedDemoUsers should only be called in debug builds.');
    final demoUsers =
        <
          ({
            String emailOrUsername,
            String password,
            UserRole role,
            String usernameField,
          })
        >[
          (
            emailOrUsername: 'admin',
            password: 'admin123',
            role: UserRole.admin,
            usernameField: 'admin',
          ),
          (
            emailOrUsername: 'superadmin',
            password: 'superadmin123',
            role: UserRole.superadmin,
            usernameField: 'superadmin',
          ),
        ];

    for (final u in demoUsers) {
      final email = _normalizeToEmail(u.emailOrUsername);
      UserCredential? created;
      try {
        created = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: u.password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          try {
            final cred = await _auth.signInWithEmailAndPassword(
              email: email,
              password: u.password,
            );
            created = cred;
          } catch (_) {
            created = null;
          }
        } else {
          rethrow;
        }
      }

      final uid = created?.user?.uid;
      if (uid != null) {
        final docRef = _db.collection(userCollection).doc(uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set(
            AppUser(
              uid: uid,
              username: u.usernameField,
              email: email,
              role: u.role,
            ).toMap(),
          );
        }
        await _auth.signOut();
      }
    }
  }
}
