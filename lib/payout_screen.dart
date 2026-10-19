import 'package:flutter/material.dart';
import 'theme.dart';
import 'supabase_service.dart';

class CashPawsPayoutScreen extends StatefulWidget {
  final int currentCoins;
  final String currentUserId;
  final Function(int updatedCoins) onBalanceChanged;

  const CashPawsPayoutScreen({
    super.key,
    required this.currentCoins,
    required this.currentUserId,
    required this.onBalanceChanged,
  });

  @override
  State<CashPawsPayoutScreen> createState() => _CashPawsPayoutScreenState();
}

class _CashPawsPayoutScreenState extends State<CashPawsPayoutScreen> {
  final _supabaseService = CashPawsSupabaseService();
  final _accountController = TextEditingController();

  String _selectedMethod = 'PayPal';
  double _selectedTier = 10.0;
  int _localCoins = 0;
  bool _isProcessing = false;

  final List<double> _incentiveTiers = List<double>.from(const [10.0, 20.0, 50.0, 100.0, 500.0, 1000.0]);

  @override
  void initState() {
    super.initState();
    _localCoins = widget.currentCoins;
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _showSnackbar(String text, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: bgColor),
    );
  }
