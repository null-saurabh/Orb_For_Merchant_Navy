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

  factory Tank.fromJson(Map<String, dynamic> json) {
    return Tank(
      tankId: json['tankId'],
      tankName: json['tankName'],
      currentROB: json['currentROB'],
      tankFunctions: json['tankFunctions'] != null
          ? List<String>.from(json['tankFunctions'])
          : null,
      tankType: json['tankType'],
      totalCapacity: json['totalCapacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tankId': tankId,
      'tankName': tankName,
      'currentROB': currentROB,
      'tankFunctions': tankFunctions,
      'tankType': tankType,
      'totalCapacity': totalCapacity,
    };
  }


}