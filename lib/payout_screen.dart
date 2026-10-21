import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({Key? key}) : super(key: key);

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Text Inputs Controllers
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  // Framework Interaction Metric States
  int _currentPawcoins = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _selectedMethod; 
  int? _selectedTier; 

  // FIXED: Explicitly initialized reward values and payment methods
  final List<String> _payoutMethods = ['GCash', 'Maya', 'PayPal', 'UNO Wallet'];
  final List<int> _payoutTiers =;

  // AdMob Performance Configuration Layers
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  bool _isTopBannerLoaded = false;
  bool _isBottomBannerLoaded = false;
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
    _initAdMobBanners();
  }

  // Sync profile details matching user_id primary key allocations
  Future<void> _fetchUserBalance() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('pawcoins')
          .eq('user_id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _currentPawcoins = data['pawcoins'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallet tracking records: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initAdMobBanners() {
    _topBannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isTopBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Top Banner failed to inject: $error');
        },
      ),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBottomBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Bottom Banner failed to inject: $error');
        },
      ),
    )..load();
  }

    // --- 1. Transaction Processing & Security Gates ---
  Future<void> _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null || _selectedTier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your payout channel and payout milestone tier.')),
      );
      return;
    }

    final int requiredCoins = _selectedTier! * 1000;
    if (_currentPawcoins < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance. You need $requiredCoins Pawcoins for this tier.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Session terminated.');

      // Write formal log directly into the withdrawals cloud ledger table
      await _supabase.from('withdrawals').insert({
        'user_id': user.id,
        'payment_method': _selectedMethod,
        'tier_amount_usd': _selectedTier,
        'coins_deducted': requiredCoins,
        'account_number': _accountNumberController.text.trim(),
        'account_name': _accountNameController.text.trim(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      final int updatedCoinTotal = _currentPawcoins - requiredCoins;
      await _supabase.from('user_profiles').update({
        'pawcoins': updatedCoinTotal,
      }).eq('user_id', user.id);

      _showSuccessDialog(_selectedTier!, _selectedMethod!);

      setState(() {
        _currentPawcoins = updatedCoinTotal;
        _selectedTier = null;
        _accountNumberController.clear();
        _accountNameController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      // FIXED: Code compilation block statement successfully changed to standard finally parameter
      setState(() => _isSubmitting = false);
    }
  }

  // --- 2. Interactive Form Build Tree Interface ---
  @override
  Widget build(BuildContext context) {
    final double currentUsdValue = _currentPawcoins / 1000.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        title: const Text('CashPaws Payouts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1E),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                if (_isTopBannerLoaded && _topBannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _topBannerAd!.size.width.toDouble(),
                    height: _topBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _topBannerAd!),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            color: const Color(0xFF1A1A1E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.orangeAccent, width: 0.5)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Text('Available Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Text(
                                    '🐾 $_currentPawcoins',
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '≈ \$${currentUsdValue.toStringAsFixed(2)} USD',
                                    style: const TextStyle(fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text('Select Payout Method', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF1A1A1E),
                            style: const TextStyle(color: Colors.white),
                            value: _selectedMethod,
                            hint: const Text('Choose payment channel', style: TextStyle(color: Colors.grey)),
                            items: _payoutMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                            onChanged: (val) => setState(() => _selectedMethod = val),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF1A1A1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (_selectedMethod == 'UNO Wallet') ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📌 Join One and grab a ₱100 bonus! Use code V98HAR on signup. Register through: https://uno.global',
                                    style: TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                                                    // --- 1. Account Detail Input Forms ---
                          const Text('Account Number / Identifier', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _accountNumberController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter mobile number or email ID',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Account identifier cannot be blank' : null,
                          ),
                          const SizedBox(height: 16),

                          const Text('Recipient Registered Name', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _accountNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter your full legal name',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Legal beneficiary name required' : null,
                          ),
                          const SizedBox(height: 24),

                          // --- 2. Withdrawal Milestone Selection Layout Row ---
                          const Text('Select Cash-Out Tier Amount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _payoutTiers.map((tier) {
                                final int coinCost = tier * 1000;
                                final bool isSelected = _selectedTier == tier;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: ChoiceChip(
                                    label: Text('\$$tier USD (🐾 ${coinCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m},')})'),
                                    selected: isSelected,
                                    selectedColor: Colors.orangeAccent,
                                    backgroundColor: const Color(0xFF1A1A1E),
                                    labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
                                    onSelected: (bool selected) => setState(() => _selectedTier = selected ? tier : null),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // --- 3. Secure Execution Request Button Trigger ---
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _processWithdrawal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : const Text('Submit Withdrawal Request', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_isBottomBannerLoaded && _bottomBannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bottomBannerAd!.size.width.toDouble(),
                    height: _bottomBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd!),
                  ),
              ],
            ),
    );
  }

  // --- 4. Transaction Audit Success Warning Popup ---
  void _showSuccessDialog(int amount, String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1E),
          title: const Text('Request Received', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Your request for \$$amount USD via $method has been submitted successfully.\n\nTransfers process within 3 to 5 business days.', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Great!', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- 5. Lifecycle Resource Garbage Collectors ---
  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }
}
