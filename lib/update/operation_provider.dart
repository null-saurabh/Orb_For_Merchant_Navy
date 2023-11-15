import 'package:flutter/material.dart';
import 'package:orb/modal/operation_modal.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/tank_provider.dart';

class OperationProvider extends ChangeNotifier {


  final List<Operation> _operations = [];
  List<Operation> get allOperations => _operations;

  List<Operation> getOperationsForSingleTank({required int tankId}) {
    return _operations.where((operation) => operation.tankId == tankId).toList();
  }

  void addNewOperation({required int tankId,required String operationFunctionName, required double operationFunctionValue, required List<Tank> allInitialTankData, required List<Tank> allFinalTankData,required bool isTargetTank, String? targetTankName}){
    Operation newOperation = Operation(
        operationId: _operations.length,
        tankId: tankId,
        operationFunctionName: operationFunctionName,
        operationFunctionValue: operationFunctionValue,
        isTargetTank: isTargetTank,
        allInitialTankData: allInitialTankData,
        allFinalTankData: allFinalTankData,
      targetTankName: isTargetTank ? targetTankName : null,
    );

    _operations.add(newOperation);
  }

  void editOperation({required TankProvider tankProvider,required int operationId, required String newOperationFunctionName, required double newOperationFunctionValue}){

    int index = _operations.indexWhere((operation) => operation.operationId == operationId);
    List<Tank> lastFinalTankData;

    if (index != -1){
      Operation operationToEdit = _operations[index];

      // Perform the edited operation and get the updated tank data
      List<Tank> editedOperationTankData = performEditedOperation(
          allInitialTankData: operationToEdit.allInitialTankData,
          tankId: operationToEdit.tankId,
          operationFunctionName: newOperationFunctionName,
          operationFunctionValue: newOperationFunctionValue,
          targetTankName: newOperationFunctionName.contains("To") ? newOperationFunctionName.replaceFirst("To ",""):null,
      );

      lastFinalTankData = editedOperationTankData;

      // Update the edited operation
      Operation newEditedOperation = Operation(
          operationId: operationToEdit.operationId,
          tankId: operationToEdit.tankId,
          operationFunctionName: newOperationFunctionName,
          operationFunctionValue: newOperationFunctionValue,
          isTargetTank: newOperationFunctionName.contains("To")? true:false,
          allInitialTankData: operationToEdit.allInitialTankData,
          allFinalTankData: editedOperationTankData,
          targetTankName: newOperationFunctionName.contains("To") ? newOperationFunctionName.replaceFirst("To ",""):null
      );

      // Update the edited operation in the list
      updateEditedOperation(operationId: operationId, newOperationData: newEditedOperation);

      // Iterate through subsequent operations and update them
      for (int i = index + 1; i < _operations.length; i++) {

        Operation subsequentOperation = _operations[i];

        List<Tank> updatedTankData = performEditedOperation(
          allInitialTankData: lastFinalTankData,
          tankId: subsequentOperation.tankId,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        // Update the subsequent operation with the new tank data
        Operation updatedOperation = Operation(
          operationId: subsequentOperation.operationId,
          tankId: subsequentOperation.tankId,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          isTargetTank: subsequentOperation.operationFunctionName.contains("To") ? true : false,
          allInitialTankData: lastFinalTankData,
          allFinalTankData: updatedTankData,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        // Update the subsequent operation in the list
        updateEditedOperation(operationId: subsequentOperation.operationId, newOperationData: updatedOperation);

        lastFinalTankData = updatedTankData;
      }

      tankProvider.updateAllTanks(lastFinalTankData);
    }
  }



  List<Tank> performEditedOperation({
    required List<Tank> allInitialTankData,
    required int tankId,
    required String operationFunctionName,
    required double operationFunctionValue,
    String? targetTankName,
}){
    int index = allInitialTankData.indexWhere((tank) => tank.tankId == tankId);

    if (operationFunctionName == "Manual Addition" || operationFunctionName == "Daily Collection/Generation" ||operationFunctionName == "From Engine Room Bilge Well") {
      allInitialTankData[index].currentROB += operationFunctionValue;
    }
    else if (operationFunctionName == "Evaporation" || operationFunctionName == "Shore Disposal" ||operationFunctionName == "Incinerated" ||operationFunctionName == "Ows Overboard") {
      allInitialTankData[index].currentROB -= operationFunctionValue;
    }
    else{
      int targetIndex = allInitialTankData.indexWhere((tank) => tank.tankName == targetTankName);
      allInitialTankData[index].currentROB -= operationFunctionValue;
      allInitialTankData[targetIndex].currentROB += operationFunctionValue;
    }

    return allInitialTankData;
  }



  void updateEditedOperation({required int operationId, required Operation newOperationData}){
    int index = _operations.indexWhere((operation) => operation.operationId == operationId);
    if (index != -1) {
      _operations[index] = newOperationData;
      notifyListeners();
    }
  }

}
