import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admin_management_service.dart';
import 'package:go_router/go_router.dart';

class SetPasswordScreen extends StatefulWidget {
  final String? token;
  const SetPasswordScreen({super.key, this.token});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _service = AdminManagementService();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _token;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _extractToken();
  }

  void _extractToken() {
    // First try the normal query parameters (works for non-hash URLs)
    final qp = Uri.base.queryParameters;
    if (qp['token'] != null && qp['token']!.isNotEmpty) {
      setState(() => _token = qp['token']);
      return;
    }

    // If not found, parse the fragment (works for hash URLs like /#/set-password?token=...)
    final frag = Uri.base.fragment; // e.g. "/set-password?token=XYZ"
    if (frag.isNotEmpty) {
      try {
        // Remove leading slash if present so Uri.parse can interpret path+query
        final normalized = frag.startsWith('/') ? frag.substring(1) : frag;
        final fragUri = Uri.parse(normalized); // e.g. Uri(path: 'set-password', queryParameters: {...})
        final token = fragUri.queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          setState(() => _token = token);
        }
      } catch (_) {
        // ignore parse errors
      }
    }
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
    });

    final pwd = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (_token == null || _token!.isEmpty) {
      setState(() => _error = 'Missing invite token. Please open the invite link or paste a token.');
      return;
    }
    if (pwd.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (pwd != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.setPassword(_token!, pwd);

      // success — show confirmation dialog then redirect to login
      if (!mounted) return;

      // Clear the token locally so it isn't accidentally reused on the same page
      setState(() {
        _token = null;
      });

      // Show dialog with option to go to login now; also auto-redirect after short delay
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          // schedule auto-redirect after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              // Pop dialog if still open then navigate to login
              try {
                Navigator.of(context, rootNavigator: true).pop();
              } catch (_) {}
              context.go('/login');
            }
          });

          return AlertDialog(
            title: const Text('Password Set'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 12),
                Text('Your password was set successfully. You will be redirected to the login page shortly.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.go('/login');
                },
                child: const Text('Go to Login Now'),
              ),
            ],
          );
        },
      );

      // Also show a short SnackBar for extra feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Password set. Redirecting to login...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // map common backend messages to friendly messages
      final msg = e.toString();
      String friendly;
      if (msg.contains('Invite expired') || msg.contains('expired')) {
        friendly = 'This invite has expired. Ask the admin to send a new invite.';
      } else if (msg.contains('Invite already used') || msg.contains('already used')) {
        friendly = 'This invite was already used. Ask the admin to send a new invite.';
      } else if (msg.contains('Invalid token')) {
        friendly = 'Invalid invite token. Please check the link or paste the correct token.';
      } else {
        // fallback to the raw message (trimmed)
        friendly = msg.replaceFirst('Exception: ', '');
      }

      setState(() => _error = friendly);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _passwordStrengthHint(String password) {
    if (password.isEmpty) return const SizedBox.shrink();
    final lengthOk = password.length >= 8;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));

    int score = 0;
    if (lengthOk) score++;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasDigit) score++;
    if (hasSymbol) score++;

    String label;
    Color color;
    if (score <= 2) {
      label = 'Weak';
      color = Colors.red;
    } else if (score == 3 || score == 4) {
      label = 'Fair';
      color = Colors.orange;
    } else {
      label = 'Strong';
      color = Colors.green;
    }

    return Row(
      children: [
        Text('Strength: ', style: TextStyle(color: Colors.grey[700])),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPassword = _passwordController.text;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Admin Password'),
        backgroundColor: const Color(0xFF2d5f3f),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_token == null || _token!.isEmpty) ...[
                  const Text(
                    'No token found in the URL. You can paste the token below.',
                    style: TextStyle(color: Colors.orange),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Invite token',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _token = v.trim(),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (_) => setState(() {}), // update strength hint
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: _passwordStrengthHint(currentPassword)),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2d5f3f),
                    ),
                    child: _loading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Set Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
