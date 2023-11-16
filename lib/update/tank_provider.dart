import 'package:flutter/material.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';

class TankProvider extends ChangeNotifier {

  List<Tank> _tanks = [];
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
    }
  }

  void updateAllTanks(List<Tank> newTanks) {
    if (newTanks.isNotEmpty) {
      _tanks = List.from(newTanks);
    }
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

    // List<Tank> allInitialTankData = _tanks;
    // List<Tank> allInitialTankData = _tanks.map((tank) => Tank.copy(tank)).toList();

    List<Tank> allInitialTankData = _tanks.map((tank) {
      return Tank(
        tankId: tank.tankId,
        tankName: tank.tankName,
        currentROB: tank.currentROB,
        totalCapacity: tank.totalCapacity,
        tankType: tank.tankType,
        tankFunctions: tank.tankFunctions
      );
    }).toList();


    int index = _tanks.indexWhere((tank) => tank.tankId == tankId);
    if (index != -1) {
      Tank tank = _tanks[index];

      // print("provider rob before operation"+tank.currentROB.toString());
      if (arithmeticExpression == "add") {
        tank.currentROB += operationFunctionValue;
        operationProvider.addNewOperation(
            tankId: tankId,
            tankName: tank.tankName,
            operationFunctionName: operationFunctionName,
            operationFunctionValue: operationFunctionValue,
            allInitialTankData: allInitialTankData,
            allFinalTankData:_tanks,
            isTargetTank: isTransfer
        );
        // print("provider rob after operation"+tank.currentROB.toString());
        // print(_tanks[_tanks.indexWhere((tank) => tank.tankId == tankId)].currentROB.toString() + "tank rob");
        // print(allInitialTankData[allInitialTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB.toString() + "initialData Rob");
      }



      else if (arithmeticExpression == "sub") {

        tank.currentROB -= operationFunctionValue;

        operationProvider.addNewOperation(tankId: tankId,
            tankName: tank.tankName,
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
              tankName: tank.tankName,
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
    }
  }

}