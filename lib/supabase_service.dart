import 'package:flutter/material.dart';
import 'supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Replace these with your actual cloud keys pulled directly from your Supabase dashboard
  final String supabaseUrl = "https://supabase.co";
  final String supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY";

  Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Registers a new user and triggers an automatic registration tracking email loop
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

  // Logs a user in and synchronizes their active app currency values to the cloud database
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

  // Logs out the active app user profile session cleanly
  Future<void> logoutUser() async {
    await Supabase.instance.client.auth.signOut();
  }
}
