class _CashPawsPayoutScreenState extends State<CashPawsPayoutScreen> {
  final _supabaseService = CashPawsSupabaseService();
  final _accountController = TextEditingController();
  String _method = 'PayPal';
  double _tier = 10.0;
  int _coins = 0;
  bool _loading = false;

  // AdMob State Variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  RewardedAd? _rewardedAd; // Added tracker for the payout video wall
  bool _isRewardedAdLoading = false;

  final List<double> _tiers = const [10.0, 20.0, 50.0, 100.0, 500.0, 1000.0];

  // AdMob Test Unit IDs
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Rewarded Test ID

  @override
  void initState() {
    super.initState();
    _coins = widget.currentCoins;
    _loadBannerAd();
    _loadRewardedAd(); // Cache the rewarded video wall ahead of time
  }

  @override
  void dispose() {
    _accountController.dispose();
    _bannerAd?.dispose();
    _rewardedAd?.dispose(); // Clear video memory footprint
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isBannerAdLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('AdMob Banner failed to load: $err'); 
        },
      ),
    )..load();
  }

  // Pre-caches the video overlay to guarantee zero delay when clicking withdrawal
  void _loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    
    setState(() => _isRewardedAdLoading = true);
    
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _setupAdCallbacks();
        },
        onAdFailedToLoad: (err) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
          debugPrint('Rewarded ad failed to cache: $err');
        },
      ),
    );
  }

  void _setupAdCallbacks() {
    if (_rewardedAd == null) return;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Instantly re-cache next ad video thread
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        // Fallback execution option: lets the user process cashout even if AdMob network breaks locally
        _executeDatabaseWithdrawal(); 
      },
    );
  }

  // Intercepts the click action to trigger validation and show video ads
  void _handleWithdrawalClick() {
    final accountText = _accountController.text.trim();
    if (accountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Enter account details.')));
      return;
    }
    final int requiredCoins = (_tier * 10000).toInt();
    if (_coins < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Insufficient balance.')));
      return;
    }

    // Force ad verification rule check
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        // User successfully finished watching video payload sequence -> trigger submission
        _executeDatabaseWithdrawal();
      });
    } else {
      // If network fill rate drops or lag happens, fallback processing prevents UX lockouts
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to verified security network... Please try again.'))
      );
      _loadRewardedAd();
    }
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
