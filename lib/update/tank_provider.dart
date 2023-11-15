import 'package:flutter/material.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';

class TankProvider extends ChangeNotifier {

  final List<Tank> _tanks = [];
  List<Tank> get allTanks => _tanks;

  void addTank({required Tank tankData}) {
    _tanks.add(tankData);
    notifyListeners();
  }

  void editTank({required int tankId, required Tank editedTankData}) {
    int index = _tanks.indexWhere((tank) => tank.tankId == tankId);
    if (index != -1) {
      _tanks[index] = editedTankData;
      notifyListeners();
    }else {
      print('Tank with id $tankId not found');
    }
  }

  void deleteTank({required int tankId}) {
    _tanks.removeWhere((tank) => tank.tankId == tankId);
    notifyListeners();
  }

  void addFunctionsToTank({required int tankId, required List<String> functions}) {
    int index = _tanks.indexWhere((tank) => tank.tankId == tankId);
    if (index != -1) {
      _tanks[index].tankFunctions = functions;
      notifyListeners();
    } else {
      print('Tank with id $tankId not found');
    }
  }

  void updateAllTanks(List<Tank> newTanks) {
    _tanks.clear();
    _tanks.addAll(newTanks);
    notifyListeners();
  }

  void performNewFunction({
    required int tankId,
    required String operationFunctionName,
    required double operationFunctionValue,
    required String arithmeticExpression,
    required bool isTransfer,
    required OperationProvider operationProvider,
    String? targetTankName,
  }) {

    List<Tank> allInitialTankData = _tanks;

    int index = _tanks.indexWhere((tank) => tank.tankId == tankId);
    if (index != -1) {
      Tank tank = _tanks[index];

      if (arithmeticExpression == "add") {

        tank.currentROB += operationFunctionValue;

        operationProvider.addNewOperation(
            tankId: tankId,
            operationFunctionName: operationFunctionName,
            operationFunctionValue: operationFunctionValue,
            allInitialTankData: allInitialTankData,
            allFinalTankData:_tanks,
            isTargetTank: isTransfer
        );

      }

      else if (arithmeticExpression == "sub") {

        tank.currentROB -= operationFunctionValue;

        operationProvider.addNewOperation(tankId: tankId,
            operationFunctionName: operationFunctionName,
            operationFunctionValue: operationFunctionValue,
            allInitialTankData: allInitialTankData,
            allFinalTankData:_tanks,
            isTargetTank: isTransfer);
      }

      else {
        int index = _tanks.indexWhere((tank) => tank.tankName == targetTankName);
        if (index != -1) {

          Tank targetTank = _tanks[index];
          tank.currentROB -= operationFunctionValue;
          targetTank.currentROB += operationFunctionValue;

          operationProvider.addNewOperation(
              tankId: tankId,
              operationFunctionName: operationFunctionName,
              operationFunctionValue: operationFunctionValue,
              allInitialTankData: allInitialTankData,
              allFinalTankData:_tanks,
              isTargetTank: isTransfer,
              targetTankName: targetTank.tankName
          );
        }
          }

      notifyListeners();
    } else {
      print('Tank with id $tankId not found');
    }
  }

}