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

  // Strict reward cash incentive milestones to secure a 90%+ profit margin
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

    void _submitWithdrawal() async {
    final accountText = _accountController.text.trim();
    if (accountText.isEmpty) {
      _showSnackbar('⚠️ Please enter your payout destination details.', Colors.redAccent);
      return;
    }

    final int requiredCoins = (_selectedTier * 10000).toInt();
    if (_localCoins < requiredCoins) {
      _showSnackbar('❌ Insufficient balance to redeem this cash incentive tier.', Colors.redAccent);
      return;
    }

    setState(() => _isProcessing = true);

    final response = await _supabaseService.processWithdrawalRequest(
      userId: widget.currentUserId,
      payoutMethod: _selectedMethod,
      payoutAccount: accountText,
      usdAmount: _selectedTier,
    );

    setState(() => _isProcessing = false);

    if (response['success'] == true) {
      setState(() {
        _localCoins = response['new_balance'] as int;
      });
      widget.onBalanceChanged(_localCoins);
      _accountController.clear();
      _showSuccessDialog(response['message'].toString());
    } else {
      _showSnackbar(response['message'].toString(), Colors.redAccent);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: CashPawsColors.cardNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 REQUEST FILED', style: TextStyle(color: CashPawsColors.textWhite, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: CashPawsColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: CashPawsColors.neonGreen, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

    void _submitWithdrawal() async {
    final accountText = _accountController.text.trim();
    if (accountText.isEmpty) {
      _showSnackbar('⚠️ Please enter your payout destination details.', Colors.redAccent);
      return;
    }

    final int requiredCoins = (_selectedTier * 10000).toInt();
    if (_localCoins < requiredCoins) {
      _showSnackbar('❌ Insufficient balance to redeem this cash incentive tier.', Colors.redAccent);
      return;
    }

    setState(() => _isProcessing = true);

    final response = await _supabaseService.processWithdrawalRequest(
      userId: widget.currentUserId,
      payoutMethod: _selectedMethod,
      payoutAccount: accountText,
      usdAmount: _selectedTier,
    );

    setState(() => _isProcessing = false);

    if (response['success'] == true) {
      setState(() {
        _localCoins = response['new_balance'] as int;
      });
      widget.onBalanceChanged(_localCoins);
      _accountController.clear();
      _showSuccessDialog(response['message'].toString());
    } else {
      _showSnackbar(response['message'].toString(), Colors.redAccent);
    }
  }

    void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: CashPawsColors.cardNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 REQUEST FILED', style: TextStyle(color: CashPawsColors.textWhite, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: CashPawsColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: CashPawsColors.neonGreen, fontWeight: FontWeight.bold)),
          )
        ],  @override
  Widget build(BuildContext context) {
    double usdValue = _localCoins / 10000;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP COIN BALANCE SNAPSHOT CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Live Balance:', style: TextStyle(color: CashPawsColors.textMuted, fontSize: 14, fontWeight: FontWeight.bold)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on, color: CashPawsColors.goldAccent, size: 20),
                                  const SizedBox(width: 6),
                                  Text('$_localCoins', style: const TextStyle(color: CashPawsColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text('\$${usdValue.toStringAsFixed(2)} USD', style: const TextStyle(color: CashPawsColors.neonGreen, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // WALLET TYPE GATEWAY RADIOS
                    const Text('SELECT PAYMENT METHOD', style: TextStyle(color: CashPawsColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    const SizedBox(height: 10),
                    _buildMethodRadio('PayPal', Icons.account_balance_wallet_outlined),
                    _buildMethodRadio('GCash', Icons.phone_android_outlined),
                    _buildMethodRadio('Maya', Icons.credit_card_outlined),
                    _buildMethodRadio('UNO Wallet', Icons.stars_outlined),
                    const SizedBox(height: 20),

                    // INCENTIVE REDEMPTION VALUE GRID
                    const Text('SELECT TRANSACTION TIER', style: TextStyle(color: CashPawsColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _incentiveTiers.length,
                      itemBuilder: (context, index) {
                        double tierValue = _incentiveTiers[index];
                        bool isSelected = _selectedTier == tierValue;
                        return InkWell(
                          onTap: () => setState(() => _selectedTier = tierValue),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? CashPawsColors.neonGreen.withOpacity(0.15) : CashPawsColors.cardNavy,
                              border: Border.all(color: isSelected ? CashPawsColors.neonGreen : Colors.transparent, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${tierValue.toStringAsFixed(0)}',
                              style: TextStyle(color: isSelected ? CashPawsColors.neonGreen : CashPawsColors.textWhite, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ACCOUNT DETAILS FORM ENTRY SLOT
                    Text(
                      _selectedMethod == 'PayPal' ? 'PAYPAL EMAIL ADDRESS' : 'MOBILE WALLET ACCOUNT NUMBER',
                      style: const TextStyle(color: CashPawsColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _accountController,
                      style: const TextStyle(color: CashPawsColors.textWhite),
                      keyboardType: _selectedMethod == 'PayPal' ? TextInputType.emailAddress : TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CashPawsColors.cardNavy,
                        hintText: _selectedMethod == 'PayPal' ? 'example@paypal.com' : '09XXXXXXXXX',
                        hintStyle: TextStyle(color: CashPawsColors.textMuted.withOpacity(0.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: CashPawsColors.neonGreen)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // UNO REFERRAL CARD INTEGRATION
                    if (_selectedMethod == 'UNO Wallet') ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                                SizedBox(width: 8),
                                Text('UNO Digital Bank Bonus', style: TextStyle(color: CashPawsColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '📌 Join One and grab a ₱100 bonus! Use code V98HAR on signup. Register through: https://uno.global',
                              style: TextStyle(color: CashPawsColors.textMuted, fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // SUBMISSION BUTTON PLATFORM LAUNCHER
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CashPawsColors.neonGreen,
                          foregroundColor: CashPawsColors.backgroundMidnight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isProcessing ? null : _submitWithdrawal,
                        child: Text(
                          _isProcessing ? 'PROCESSING CLOUD SYNC...' : 'CONFIRM WITHDRAWAL',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodRadio(String value, IconData icon) {
    bool isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: CashPawsColors.cardNavy,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? CashPawsColors.neonGreen : Colors.transparent, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? CashPawsColors.neonGreen : CashPawsColors.textMuted, size: 22),
            const SizedBox(width: 14),
            Text(value, style: TextStyle(color: isSelected ? CashPawsColors.textWhite : CashPawsColors.textMuted, fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? CashPawsColors.neonGreen : CashPawsColors.textMuted, size: 20),
          ],
        ),
      ),
);
}
}
      ),
    );
  }

  
