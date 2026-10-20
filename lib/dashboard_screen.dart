  // --- Supabase Transaction Execution Core Handler ---
  Future<void> _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null || _selectedTier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a payout method and cash tier.')),
      );
      return;
    }

    final int requiredCoins = _selectedTier! * 1000; // 1,000 pawcoins = $1 USD
    if (_currentPawcoins < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance. You need $requiredCoins Pawcoins for this tier.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authorized session found.');

      // 1. Write transactional audit entry into cloud withdrawals ledger
      await _supabase.from('withdrawals').insert({
        'user_id': user.id, // Linked back to user_profiles table primary key
        'payment_method': _selectedMethod,
        'tier_amount_usd': _selectedTier,
        'coins_deducted': requiredCoins,
        'account_number': _accountNumberController.text.trim(),
        'account_name': _accountNameController.text.trim(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Safely deduct points from user profile based on target column user_id
      final int updatedCoinTotal = _currentPawcoins - requiredCoins;
      await _supabase.from('user_profiles').update({
        'pawcoins': updatedCoinTotal,
      }).eq('user_id', user.id); // Optimized for existing user_id table definitions

      _showSuccessDialog(_selectedTier!, _selectedMethod!);

      setState(() {
        _currentPawcoins = updatedCoinTotal;
        _selectedTier = null;
        _accountNumberController.clear();
        _accountNameController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
