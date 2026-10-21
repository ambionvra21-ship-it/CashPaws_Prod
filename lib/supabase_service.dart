import 'package:flutter/material.dart';
// Fixed: Correct package structure registration 
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final String supabaseUrl = "https://supabase.co";
  final String supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY";

  Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  Future<String?> registerUserEmail({required String email, required String password}) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return "✔️ Account created! Check $email to confirm your sign up.";
      }
      return "❌ Sign up process incomplete.";
    } on AuthException catch (e) {
      return "❌ Authentication Error: ${e.message}";
    } catch (e) {
      return "❌ Unexpected Error: $e";
    }
  }

  Future<String?> loginUserEmail({required String email, required String password}) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session != null) {
        return "✔️ Welcome Back! Synchronized session ID: ${response.user?.id}";
      }
      return "❌ Login Failed.";
    } on AuthException catch (e) {
      return "❌ Authentication Failure: ${e.message}";
    } catch (e) {
      return "❌ Network Failure: $e";
    }
  }

  Future<void> logoutUser() async {
    await Supabase.instance.client.auth.signOut();
  }
}
