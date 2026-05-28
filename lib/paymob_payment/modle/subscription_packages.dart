class SubscriptionPackage {
  String name;
  int egpPrice;
  int swapRequests;
  int requiredPoints;

  SubscriptionPackage(
      {required this.name,
      required this.egpPrice,
      required this.swapRequests,
      required this.requiredPoints});
}

SubscriptionPackage firstPackages = SubscriptionPackage(
  name: 'Basic',
  egpPrice: 55,
  swapRequests: 10,
  requiredPoints: 200,
);

SubscriptionPackage secondPackages = SubscriptionPackage(
  name: 'Premium',
  egpPrice: 100,
  swapRequests: 30,
  requiredPoints: 400,
);

List<SubscriptionPackage> subscriptionPackages = [firstPackages, secondPackages];
