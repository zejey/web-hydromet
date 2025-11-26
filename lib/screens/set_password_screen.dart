import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admin_management_service.dart';
import 'package:go_router/go_router.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

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
    // Works on web and (often) for deep links where the token is in query params.
    final params = Uri.base.queryParameters;
    setState(() {
      _token = params['token'];
    });
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

      // success — navigate to login or show confirmation
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Password set. You can now log in.'),
          backgroundColor: Colors.green,
        ),
      );
      // go to login route (adjust path to your app)
      context.go('/login');
    } catch (e) {
      setState(() => _error = e.toString());
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

  @override
  Widget build(BuildContext context) {
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
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    border: OutlineInputBorder(),
                  ),
                ),
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
