import 'package:flutter/material.dart';
// Fixed: Swapped to valid package path mapping scheme
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  RewardedAd? _rewardedAd;
  bool isAdLoading = false;

  final String rewardedUnitId = "ca-app-pub-3940256099942544/5224354917";

  Future<void> initializeAdMob() async {
    await MobileAds.instance.initialize();
  }

  void loadRewardedAd({required VoidCallback onAdLoaded}) {
    if (isAdLoading) return;
    isAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoading = false;
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          isAdLoading = false;
          debugPrint("AdMob Reward Ad Failed to Load: $error");
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(double platformProfit, double userPointsEarned) onRewardEarned,
    required VoidCallback onAdClosed,
  }) {
    if (_rewardedAd == null) {
      debugPrint("Warning: Tried to play ad, but no ad instance is ready.");
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdClosed();
        loadRewardedAd(onAdLoaded: () {});
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onAdClosed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        double simulatedGrossAdRevenueUsd = 0.05; 
        double platformProfitCut = simulatedGrossAdRevenueUsd * 0.90;
        double userPayoutCutUsd = simulatedGrossAdRevenueUsd * 0.10;
        double userPointsEarned = userPayoutCutUsd * 100000; 

        onRewardEarned(platformProfitCut, userPointsEarned);
      },
    );
    _rewardedAd = null;
  }
}
