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

  void addNewOperation({required int tankId,required String tankName,required String operationFunctionName, required double operationFunctionValue, required List<Tank> allInitialTankData, required List<Tank> allFinalTankData,required bool isTargetTank, String? targetTankName}){
    Operation newOperation = Operation(
        operationId: _operations.length,
        tankId: tankId,
        tankName: tankName,
        operationFunctionName: operationFunctionName,
        operationFunctionValue: operationFunctionValue,
        isTargetTank: isTargetTank,
        allInitialTankData: allInitialTankData,
        allFinalTankData: allFinalTankData,
      targetTankName: isTargetTank ? targetTankName : null,
    );

    _operations.add(newOperation);
    if(_operations.length >2){
      print(_operations[1].allInitialTankData[allInitialTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB);
      print(_operations[1].allFinalTankData[allFinalTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB);

    }
  }

  void insertOperation({
    required int tankId,
    required String tankName,
    required String operationFunctionName,
    required double operationFunctionValue,
    required bool isTargetTank,
    String? targetTankName,
    required int insertIndex,
    required TankProvider tankProvider,
  }) {
    // Check if the insertIndex is within bounds
    if (insertIndex < 0 || insertIndex > _operations.length) {
      throw ArgumentError("Invalid insertIndex");
    }

    // Calculate allInitialTankData based on the existing operation at insertIndex
    List<Tank> allInitialTankData;
    List<Tank> lastFinalTankData;

    if (insertIndex == 0) {
      // If inserting at the beginning, use the initial data of the first tank
      allInitialTankData = _operations.isNotEmpty ? _operations.first.allInitialTankData : [];
    } else {
      // If inserting in the middle, use the final data of the preceding operation
      allInitialTankData = _operations[insertIndex].allInitialTankData;
      // List<Tank> b = _operations.first.allFinalTankData;
      // print("-a: ${b[b.indexWhere((tank) => tank.tankId == tankId)].currentROB}");
      // print("a: ${allInitialTankData[allInitialTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB}");
    }

    // Perform the function to get allFinalTankData
    List<Tank> allFinalTankData = performEditedOperation(
      allInitialTankData: allInitialTankData,
      tankId: tankId,
      tankName: tankName,
      operationFunctionName: operationFunctionName,
      operationFunctionValue: operationFunctionValue,
      targetTankName: isTargetTank ? targetTankName : null,
    );

    lastFinalTankData = allFinalTankData;
    // print("after executing: ${lastFinalTankData[lastFinalTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB}");

    // Create the new operation
    Operation newOperation = Operation(
      operationId: insertIndex, // or any appropriate logic for assigning the operationId
      tankId: tankId,
      tankName: tankName,
      operationFunctionName: operationFunctionName,
      operationFunctionValue: operationFunctionValue,
      isTargetTank: isTargetTank,
      allInitialTankData: allInitialTankData,
      allFinalTankData: allFinalTankData,
      targetTankName: isTargetTank ? targetTankName : null,
    );

    // Insert the new operation at the specified index
    _operations.insert(insertIndex, newOperation);

    // Iterate through subsequent operations and update their operationId
    for (int i = insertIndex + 1; i < _operations.length; i++) {
      _operations[i].operationId = i;
    }

    // Iterate through subsequent operations and update them
    for (int i = insertIndex + 1; i < _operations.length; i++) {
      // List<Tank> c = _operations.first.allFinalTankData;
      // print("in look: ${c[c.indexWhere((tank) => tank.tankId == tankId)].currentROB}");
      Operation subsequentOperation = _operations[i];

      // print("Iterating $i");
      List<Tank> updatedAllTankData = performEditedOperation(
        allInitialTankData: lastFinalTankData,
        tankId: subsequentOperation.tankId,
        tankName: subsequentOperation.tankName,
        operationFunctionName: subsequentOperation.operationFunctionName,
        operationFunctionValue: subsequentOperation.operationFunctionValue,
        targetTankName: subsequentOperation.operationFunctionName.contains("To")
            ? subsequentOperation.operationFunctionName.replaceFirst("To ", "")
            : null,
      );

      // print("Iterating Rob: ${updatedAllTankData[updatedAllTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB}");
      // Update the subsequent operation with the new tank data
      Operation updatedOperation = Operation(
        operationId: subsequentOperation.operationId,
        tankId: subsequentOperation.tankId,
        tankName: subsequentOperation.tankName,
        operationFunctionName: subsequentOperation.operationFunctionName,
        operationFunctionValue: subsequentOperation.operationFunctionValue,
        isTargetTank: subsequentOperation.operationFunctionName.contains("To"),
        allInitialTankData: lastFinalTankData,
        allFinalTankData: updatedAllTankData,
        targetTankName: subsequentOperation.operationFunctionName.contains("To")
            ? subsequentOperation.operationFunctionName.replaceFirst("To ", "")
            : null,
      );

      updateEditedOperation(
        operationId: subsequentOperation.operationId,
        newOperationData: updatedOperation,
      );
      lastFinalTankData = updatedAllTankData;
    }

    tankProvider.updateAllTanks(lastFinalTankData);
    notifyListeners();
  }


  void editOperation({required TankProvider tankProvider,required int operationId, required String newOperationFunctionName, required double newOperationFunctionValue}) {

    int index = _operations.indexWhere((operation) => operation.operationId == operationId);
    List<Tank> lastFinalTankData;

    if (index != -1){
      Operation operationToEdit = _operations[index];

      // Perform the edited operation and get the updated tank data
      List<Tank> editedOperationAllTankData = performEditedOperation(
          allInitialTankData: operationToEdit.allInitialTankData,
          tankId: operationToEdit.tankId,
          tankName: operationToEdit.tankName,
          operationFunctionName: newOperationFunctionName,
          operationFunctionValue: newOperationFunctionValue,
          targetTankName: newOperationFunctionName.contains("To") ? newOperationFunctionName.replaceFirst("To ",""):null,
      );

      lastFinalTankData = editedOperationAllTankData;

      // Update the edited operation
      Operation newEditedOperation = Operation(
          operationId: operationToEdit.operationId,
          tankId: operationToEdit.tankId,
          tankName: operationToEdit.tankName,
          operationFunctionName: newOperationFunctionName,
          operationFunctionValue: newOperationFunctionValue,
          isTargetTank: newOperationFunctionName.contains("To")? true:false,
          allInitialTankData: operationToEdit.allInitialTankData,
          allFinalTankData: editedOperationAllTankData,
          targetTankName: newOperationFunctionName.contains("To") ? newOperationFunctionName.replaceFirst("To ",""):null
      );


      // Update the edited operation in the list
      updateEditedOperation(operationId: operationId, newOperationData: newEditedOperation);


      // Iterate through subsequent operations and update them
      for (int i = index + 1; i < _operations.length; i++) {

        Operation subsequentOperation = _operations[i];

        List<Tank> updatedAllTankData = performEditedOperation(
          allInitialTankData: lastFinalTankData,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        // Update the subsequent operation with the new tank data
        Operation updatedOperation = Operation(
          operationId: subsequentOperation.operationId,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          isTargetTank: subsequentOperation.operationFunctionName.contains("To") ? true : false,
          allInitialTankData: lastFinalTankData,
          allFinalTankData: updatedAllTankData,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        updateEditedOperation(operationId: subsequentOperation.operationId, newOperationData: updatedOperation);
        lastFinalTankData = updatedAllTankData;
      }
      tankProvider.updateAllTanks(lastFinalTankData);
    }
  }

  void deleteOperation({required int operationId, required TankProvider tankProvider}) {
    int index = _operations.indexWhere((operation) => operation.operationId == operationId);

    if (index != -1) {
      // Get the tank data before the deleted operation
      List<Tank> lastFinalTankData = _operations[index].allInitialTankData;

      // Remove the operation
      _operations.removeAt(index);

      // // Update operation IDs for remaining operations
      // for (int i = index; i < _operations.length; i++) {
      //   _operations[i].operationId = i;
      // }

      // Iterate through subsequent operations and update them
      for (int i = index; i < _operations.length; i++) {

        Operation subsequentOperation = _operations[i];
        _operations[i].operationId = i;

        List<Tank> updatedAllTankData = performEditedOperation(
          allInitialTankData: lastFinalTankData,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        // Update the subsequent operation with the new tank data
        Operation updatedOperation = Operation(
          operationId: subsequentOperation.operationId,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          isTargetTank: subsequentOperation.operationFunctionName.contains("To") ? true : false,
          allInitialTankData: lastFinalTankData,
          allFinalTankData: updatedAllTankData,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        updateEditedOperation(operationId: subsequentOperation.operationId, newOperationData: updatedOperation);
        lastFinalTankData = updatedAllTankData;
      }

      tankProvider.updateAllTanks(lastFinalTankData);
      notifyListeners();
    }
  }

  List<Tank> performEditedOperation({required List<Tank> allInitialTankData, required int tankId, required String tankName, required String operationFunctionName, required double operationFunctionValue, String? targetTankName,}){

    List<Tank> updatedTankData = allInitialTankData.map((tank) {
      return Tank(
        tankId: tank.tankId,
        tankName: tank.tankName,
        currentROB: tank.currentROB,
        totalCapacity: tank.totalCapacity,
        tankType: tank.tankType,
        tankFunctions: tank.tankFunctions != null ? [...tank.tankFunctions!] : null,
      );
    }).toList();


    int index = updatedTankData.indexWhere((tank) => tank.tankId == tankId);
    // print("rob before operation" +allInitialTankData[index].currentROB.toString());

    if (operationFunctionName == "Manual Addition" || operationFunctionName == "Daily Collection/Generation" ||operationFunctionName == "From Engine Room Bilge Well") {
      updatedTankData[index].currentROB += operationFunctionValue;
    }
    else if (operationFunctionName == "Evaporation" || operationFunctionName == "Shore Disposal" ||operationFunctionName == "Incinerated" ||operationFunctionName == "Ows Overboard") {
      updatedTankData[index].currentROB -= operationFunctionValue;
    }
    else{
      int targetIndex = updatedTankData.indexWhere((tank) => tank.tankName == targetTankName);
      updatedTankData[index].currentROB -= operationFunctionValue;
      updatedTankData[targetIndex].currentROB += operationFunctionValue;
    }
    // print("rob after operation" +allInitialTankData[index].currentROB.toString());
    return updatedTankData;
  }

  void updateEditedOperation({required int operationId, required Operation newOperationData}){
    int index = _operations.indexWhere((operation) => operation.operationId == operationId);
    if (index != -1) {
      _operations[index] = newOperationData;
      notifyListeners();
    }
  }


}
