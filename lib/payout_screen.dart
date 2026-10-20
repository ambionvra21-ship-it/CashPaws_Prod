import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  String _method = 'PayPal';
  double _tier = 10.0;
  int _coins = 0;
  bool _loading = false;

  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  bool _isTopBannerLoaded = false;
  bool _isBottomBannerLoaded = false;

  final List<double> _tiers = const [10.0, 20.0, 50.0, 100.0, 500.0, 1000.0];
  final String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _coins = widget.currentCoins;
    _initializeSafeBanners();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  void _initializeSafeBanners() {
    _topBannerAd = BannerAd(
      adUnitId: _testBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isTopBannerLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Top Payout Banner failed to load silently: $err');
        },
      ),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: _testBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isBottomBannerLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Bottom Payout Banner failed to load silently: $err');
        },
      ),
    )..load();
  }

  void _handleWithdrawalClick() {
    final accountText = _accountController.text.trim();
    if (accountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Enter account details.')));
      return;
    }
    // 1,000 coins = $1 base conversion ratio calculation mapping
    final int requiredCoins = (_tier * 1000).toInt(); 
    if (_coins < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Insufficient balance.')));
      return;
    }
    _executeDatabaseWithdrawal();
  }

  void _executeDatabaseWithdrawal() async {
    final accountText = _accountController.text.trim();
    setState(() => _loading = true);

    final res = await _supabaseService.processWithdrawalRequest(
      userId: widget.currentUserId,
      payoutMethod: _method,
      payoutAccount: accountText,
      usdAmount: _tier,
    );

    setState(() => _loading = false);

    if (res['success'] == true) {
      setState(() => _coins = res['new_balance'] as int);
      widget.onBalanceChanged(_coins);
      _accountController.clear();
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: CashPawsColors.cardNavy,
          title: const Text('🎉 SUCCESS', style: TextStyle(color: Colors.white)),
          content: Text(res['message'].toString(), style: const TextStyle(color: Colors.grey)),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashPawsColors.backgroundMidnight,
      appBar: AppBar(
        backgroundColor: CashPawsColors.backgroundMidnight,
        elevation: 0,
        title: const Text('REDEEM INCENTIVES', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isTopBannerLoaded && _topBannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _topBannerAd!.size.width.toDouble(),
                height: _topBannerAd!.size.height.toDouble(),
                padding: const EdgeInsets.only(bottom: 4),
                child: AdWidget(ad: _topBannerAd!),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CashPawsColors.cardNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Live Balance:', style: TextStyle(color: Colors.grey)),
                          Text('$_coins Coins (\$${(_coins / 1000).toStringAsFixed(2)})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('METHOD', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ...['PayPal', 'GCash', 'Maya', 'UNO Wallet'].map((m) => RadioListTile<String>(
                      title: Text(m, style: const TextStyle(color: Colors.white)),
                      value: m,
                      groupValue: _method,
                      activeColor: CashPawsColors.neonGreen,
                      onChanged: (v) => setState(() => _method = v!),
                    )),
                    const SizedBox(height: 20),
                    const Text('TIER', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: _tiers.map((t) => ChoiceChip(
                        label: Text('\$$t', style: TextStyle(color: _tier == t ? Colors.black : Colors.white)),
                        selected: _tier == t,
                        selectedColor: CashPawsColors.neonGreen,
                        backgroundColor: CashPawsColors.cardNavy,
                        onSelected: (s) => setState(() => _tier = t),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _accountController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CashPawsColors.cardNavy,
                        hintText: _method == 'PayPal' ? 'email@paypal.com' : '09XXXXXXXXX',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_method == 'UNO Wallet') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          '📌 Join One and grab a ₱100 bonus! Use code V98HAR on signup. Register through: https://uno.global',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CashPawsColors.neonGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _loading ? null : _handleWithdrawalClick,
                        child: Text(_loading ? 'SYNCING...' : 'CONFIRM WITHDRAWAL', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isBottomBannerLoaded && _bottomBannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bottomBannerAd!.size.width.toDouble(),
                height: _bottomAdMobBanner!.size.height.toDouble(), // Matches height dynamically
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AdWidget(ad: _bottomBannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
