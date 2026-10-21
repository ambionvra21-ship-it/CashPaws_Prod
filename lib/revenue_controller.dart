class RevenueController {
  // Enforces the strict 90% platform profit and 10% user allocation split
  static Map<String, double> processAdRevenue(double grossAdValueUsd) {
    double platformProfit = grossAdValueUsd * 0.90;
    double userPayoutUsd = grossAdValueUsd * 0.10;
    
    return {
      'platformProfitUsd': platformProfit,
      'userPayoutUsd': userPayoutUsd,
    };
  }
}
