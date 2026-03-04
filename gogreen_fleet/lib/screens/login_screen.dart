import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedHubId;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMsg;

  static const _bg = Color(0xFF0A1628);
  static const _card = Color(0xFF1A2744);
  static const _border = Color(0xFF2D3F6B);
  static const _green = Color(0xFF22C55E);
  static const _textSecondary = Color(0xFF9CA3AF);

  void _login() async {
    setState(() { _errorMsg = null; _isLoading = true; });
    await Future.delayed(const Duration(milliseconds: 800));

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final user = mockUsers.where((u) =>
      u.email.toLowerCase() == email &&
      u.password == password &&
      u.hubId == _selectedHubId
    ).firstOrNull;

    setState(() { _isLoading = false; });

    if (user == null) {
      setState(() { _errorMsg = 'Invalid credentials. Check your hub, email and password.'; });
      return;
    }

    final hub = mockHubs.firstWhere((h) => h.id == user.hubId);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen(user: user, hub: hub)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4332),
                  shape: BoxShape.circle,
                  border: Border.all(color: _green, width: 3),
                  boxShadow: [BoxShadow(color: _green.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                ),
                child: const Center(child: Text('🚗', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 16),
              const Text('GoGreen', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF22C55E), letterSpacing: 2)),
              const Text('Vehicle Inventory System', style: TextStyle(fontSize: 13, color: _textSecondary, letterSpacing: 1)),
              const Text('Capture. Track. Manage.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontStyle: FontStyle.italic)),
              const SizedBox(height: 36),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sign In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Please log in to continue', style: TextStyle(fontSize: 13, color: _textSecondary)),
                    const SizedBox(height: 24),

                    // Hub Dropdown
                    const Text('🏢  Hub Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedHubId,
                          isExpanded: true,
                          dropdownColor: _card,
                          hint: const Text('Select your hub location', style: TextStyle(color: _textSecondary)),
                          icon: const Icon(Icons.keyboard_arrow_down, color: _textSecondary),
                          items: mockHubs.map((hub) => DropdownMenuItem(
                            value: hub.id,
                            child: Text('📍 ${hub.name}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedHubId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Email
                    const Text('✉️  Email ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: const TextStyle(color: _textSecondary),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Password
                    const Text('🔒  Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(color: _textSecondary),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _textSecondary),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Error
                    if (_errorMsg != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B1A1A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade700),
                        ),
                        child: Text(_errorMsg!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                      ),
                    const SizedBox(height: 8),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                          shadowColor: _green.withOpacity(0.5),
                        ),
                        child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In  →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Demo hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(color: const Color(0xFFF59E0B), width: 3)),
                      ),
                      child: const Column(
                        children: [
                          Text('Demo: agent1@gogreen.com / pass123', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11), textAlign: TextAlign.center),
                          Text('Hub: Mumbai Hub', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('GoGreen Fleet Management • v1.0', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
