import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_notifications.dart';
import 'dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _noTelpCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    if (_usernameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Username, email, dan password wajib diisi');
      AppNotifier.warning(context, 'Username, email, dan password wajib diisi.', title: 'Data belum lengkap');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      AppNotifier.warning(context, 'Password minimal 6 karakter.', title: 'Data belum valid');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      await AuthService.register(
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        noTelp: _noTelpCtrl.text.isNotEmpty ? _noTelpCtrl.text.trim() : null,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      if (mounted) AppNotifier.error(context, e, title: 'Registrasi gagal');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFFFECD2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 60, offset: const Offset(0, 20)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Daftar Akun', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE67E22))),
                  const SizedBox(height: 8),
                  const Text('Buat akun kasir baru', style: TextStyle(fontSize: 14, color: Color(0xFF636E72))),
                  const SizedBox(height: 30),

                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 13)),
                    ),

                  _buildField(_usernameCtrl, 'Username', Icons.person_outline),
                  const SizedBox(height: 14),
                  _buildField(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE67E22), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildField(_noTelpCtrl, 'No. Telepon (opsional)', Icons.phone_outlined, type: TextInputType.phone),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ', style: TextStyle(color: Color(0xFF636E72))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Masuk', style: TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE67E22), width: 2)),
      ),
    );
  }
}
