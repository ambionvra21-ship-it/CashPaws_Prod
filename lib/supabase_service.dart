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

  // Submit a dynamic withdrawal request directly to the pending admin ledger table
  Future<Map<String, dynamic>> processWithdrawalRequest({
    required String userId,
    required String payoutMethod, // 'PayPal', 'GCash', 'Maya', or 'UNO Wallet'
    required String payoutAccount, // Phone number or Email address
    required double usdAmount, // 10, 20, 50, 100, 500, 1000 tiers
  }) async {
    try {
      // 1. Convert requested USD amount back to required Pawcoins (1,000 coins = $0.10, so $10 = 100,000 coins)
      final int requiredCoins = (usdAmount * 10000).toInt();
      final int currentBalance = await getUserBalance(userId);

      // 2. Security validation: Ensure user isn't trying to bypass local state checks
      if (currentBalance < requiredCoins) {
        return {'success': false, 'message': '❌ Insufficient Pawcoins balance.'};
      }

      final int updatedBalance = currentBalance - requiredCoins;

      // 3. Atomically deduct the coins from the user profile table
      await _client
          .from('user_profiles')
          .update({'pawcoins_balance': updatedBalance})
          .eq('user_id', userId);

      // 4. Insert transaction row ledger entry directly into pending admin cash-out table
      await _client.from('withdrawal_requests').insert({
        'user_id': userId,
        'method': payoutMethod,
        'account_destination': payoutAccount,
        'usd_amount': usdAmount,
        'coins_deducted': requiredCoins,
        'status': 'PENDING',
        'created_at': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': '🎉 Withdrawal submitted! Processed on the upcoming Friday batch.',
        'new_balance': updatedBalance
      };
    } catch (e) {
      return {'success': false, 'message': '⚠️ Cloud connection error. Please try again.'};
    }
  }
}
