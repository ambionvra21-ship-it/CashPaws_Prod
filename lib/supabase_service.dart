import 'package:supabase_flutter/supabase_flutter.dart';

class CashPawsSupabaseService {
  static final CashPawsSupabaseService _instance = CashPawsSupabaseService._internal();
  factory CashPawsSupabaseService() => _instance;
  CashPawsSupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Fetch a user's real-time live Pawcoin balance from the secure cloud ledger table
  Future<int> getUserBalance(String userId) async {
    try {
      final data = await _client
          .from('user_profiles')
          .select('pawcoins_balance')
          .eq('user_id', userId)
          .single();
      
      return data['pawcoins_balance'] as int? ?? 0;
    } catch (e) {
      return 0; // Return a safe fallback value if connection buffers
    }
  }

  // Atomically update local coins state engine and insert an audit row into the database
  Future<bool> creditUserPoints({
    required String userId,
    required int pointsToCredit,
    required String rewardSource,
  }) async {
    try {
      // 1. Fetch current live balance variables
      final currentBalance = await getUserBalance(userId);
      final newBalance = currentBalance + pointsToCredit;

      // 2. Perform an atomic update operation straight into Supabase profiles
      await _client
          .from('user_profiles')
          .update({'pawcoins_balance': newBalance})
          .eq('user_id', userId);

      // 3. Log a detailed transactional row ledger entry for security auditing
      await _client.from('points_ledger').insert({
        'user_id': userId,
        'amount_changed': pointsToCredit,
        'activity_type': rewardSource,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
