import 'package:orb/modal/tank_modal.dart';

class Operation {
  int operationId;
  final int tankId;
  final String tankName;
  final String operationFunctionName;
  final double operationFunctionValue;
  final bool isTargetTank;
  final List<Tank> allInitialTankData;
  final List<Tank> allFinalTankData;
  final DateTime date;
  final String? targetTankName;


  Operation({
    required this.operationId,
    required this.tankId,
    required this.tankName,
    required this.operationFunctionName,
    required this.operationFunctionValue,
    required this.isTargetTank,
    required this.allInitialTankData,
    required this.allFinalTankData,
    required this.date,
    this.targetTankName
  });
}
