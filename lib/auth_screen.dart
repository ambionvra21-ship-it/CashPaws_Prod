import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Text Form Field Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Framework Interaction States
  bool _isLoginTab = true;
  bool _isLoading = false;
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 1. Supabase Core Authentication Submission Request Pipelines ---
  Future<void> _handleAuthAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      if (_isLoginTab) {
        // Sign into an existing profile ledger session
        final AuthResponse response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (response.user != null && mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        // Register a brand new email account record matrix
        final AuthResponse response = await _supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Registration successful! Creating your paw profile...'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Seed the basic database row entry if profile creation via SQL triggers is pending
          _initializeProfileSilently(response.user!.id);
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeProfileSilently(String userId) async {
    try {
      // Seeds values matching your structural user_id constraints safely
      await _supabase.from('user_profiles').upsert({
        'user_id': userId,
        'pawcoins': 500, // Welcome bonus pawcoins to encourage early app adoption
        'ads_watched_today': 0,
        'step_coins_today': 0,
        'tap_high_score': 0,
      });
    } catch (e) {
      debugPrint('Silent profiles upsert bypassed or handled downstream: $e');
    }
  }

    // --- 2. Screen Visual Layout Engine Architecture ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214), // Dark neon aesthetic baseline
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo Title Header
                const Center(
                  child: Text(
                    '🐾 CashPaws',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      shadows: [
                        Shadow(color: Colors.orange, blurRadius: 10, offset: Offset(0, 2))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Earn Rewards with Virtual Pets',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),

                // Custom Inline Authentication Segmented Tab Selector Controls
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLoginTab = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _isLoginTab ? Colors.orangeAccent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isLoginTab ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLoginTab = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !_isLoginTab ? Colors.orangeAccent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'REGISTER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isLoginTab ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Email Address Form Input Field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    hintText: 'Enter your email address',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email string cannot be blank';
                    if (!val.contains('@')) return 'Please supply a structurally valid email reference';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Verification Input Field
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                    hintText: 'Enter security password',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password security key required';
                    if (val.length < 6) return 'Password footprint must contain 6 characters minimum';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Core Action Execution Trigger Submission Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuthAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : Text(
                          _isLoginTab ? 'LOG INTO CURRENT SESSION' : 'CREATE ACCOUNT RECORD',
                          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
