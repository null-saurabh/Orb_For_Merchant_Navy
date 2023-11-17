class Tank {
  final int tankId;
  final String tankName;
  double currentROB;
  final double totalCapacity;
  final String tankType;
  List<String>? tankFunctions;

  Tank({
    required this.tankId,
    required this.tankName,
    required this.currentROB,
    this.tankFunctions,
    required this.tankType,
    required this.totalCapacity
  });



}