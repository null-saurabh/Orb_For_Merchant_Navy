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

  void addNewOperation({required int tankId,required String tankName,required String operationFunctionName, required double operationFunctionValue, required List<Tank> allInitialTankData, required List<Tank> allFinalTankData,required bool isTargetTank,required DateTime date ,String? targetTankName}){
    Operation newOperation = Operation(
        operationId: _operations.length,
        tankId: tankId,
        tankName: tankName,
        operationFunctionName: operationFunctionName,
        operationFunctionValue: operationFunctionValue,
        isTargetTank: isTargetTank,
        allInitialTankData: allInitialTankData,
        allFinalTankData: allFinalTankData,
      date: date,
      targetTankName: isTargetTank ? targetTankName : null,
    );

    _operations.add(newOperation);
    if(_operations.length >2){
      // print(_operations[1].allInitialTankData[allInitialTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB);
      // print(_operations[1].allFinalTankData[allFinalTankData.indexWhere((tank) => tank.tankId == tankId)].currentROB);
    }
  }

  void insertOperation({required int tankId,    required String tankName,    required String operationFunctionName,    required double operationFunctionValue,    required bool isTargetTank,  required DateTime date , String? targetTankName,    required int insertIndex, required TankProvider tankProvider,}) {
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
      allInitialTankData = _operations[insertIndex-1].allFinalTankData;
      // allInitialTankData = _operations[insertIndex].allInitialTankData;

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

    List<Tank> deepCopyAllFinalTankData = List.from(allFinalTankData.map((tank) {
      return Tank(
        tankId: tank.tankId,
        tankName: tank.tankName,
        currentROB: tank.currentROB,
        totalCapacity: tank.totalCapacity,
        tankType: tank.tankType,
        tankFunctions: tank.tankFunctions != null ? [...tank.tankFunctions!] : null,
      );
    }));

    lastFinalTankData = deepCopyAllFinalTankData;
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
      allFinalTankData: deepCopyAllFinalTankData,
      targetTankName: isTargetTank ? targetTankName : null,
      date: date
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

      List<Tank> deepCopyUpdatedAllTankData = List.from(updatedAllTankData.map((tank) {
        return Tank(
          tankId: tank.tankId,
          tankName: tank.tankName,
          currentROB: tank.currentROB,
          totalCapacity: tank.totalCapacity,
          tankType: tank.tankType,
          tankFunctions: tank.tankFunctions != null ? [...tank.tankFunctions!] : null,
        );
      }));

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
        allFinalTankData: deepCopyUpdatedAllTankData,
        targetTankName: subsequentOperation.operationFunctionName.contains("To")
            ? subsequentOperation.operationFunctionName.replaceFirst("To ", "")
            : null,
        date: subsequentOperation.date
      );

      updateEditedOperation(
        operationId: subsequentOperation.operationId,
        newOperationData: updatedOperation,
      );
      lastFinalTankData = deepCopyUpdatedAllTankData;
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

      List<Tank> deepCopyEditedOperationAllTankData = List.from(editedOperationAllTankData.map((tank) {
        return Tank(
          tankId: tank.tankId,
          tankName: tank.tankName,
          currentROB: tank.currentROB,
          totalCapacity: tank.totalCapacity,
          tankType: tank.tankType,
          tankFunctions: tank.tankFunctions != null ? [...tank.tankFunctions!] : null,
        );
      }));

      lastFinalTankData = deepCopyEditedOperationAllTankData;

      // Update the edited operation
      Operation newEditedOperation = Operation(
          operationId: operationToEdit.operationId,
          tankId: operationToEdit.tankId,
          tankName: operationToEdit.tankName,
          operationFunctionName: newOperationFunctionName,
          operationFunctionValue: newOperationFunctionValue,
          isTargetTank: newOperationFunctionName.contains("To")? true:false,
          allInitialTankData: operationToEdit.allInitialTankData,
          allFinalTankData: deepCopyEditedOperationAllTankData,
          // allFinalTankData: editedOperationAllTankData,
          targetTankName: newOperationFunctionName.contains("To") ? newOperationFunctionName.replaceFirst("To ",""):null,
          date: operationToEdit.date
      );


      // Update the edited operation in the list
      updateEditedOperation(operationId: operationId, newOperationData: newEditedOperation);


      // Iterate through subsequent operations and update them
      for (int i = index + 1; i < _operations.length; i++) {
        print('in iterate');
        Operation subsequentOperation = _operations[i];

        // List<Tank> lastFinalTankData = _operations[i - 1].allFinalTankData;

        List<Tank> updatedAllTankData = performEditedOperation(
          allInitialTankData: lastFinalTankData,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        );

        List<Tank> deepCopyUpdatedAllTankData = List.from(updatedAllTankData.map((tank) {
          return Tank(
            tankId: tank.tankId,
            tankName: tank.tankName,
            currentROB: tank.currentROB,
            totalCapacity: tank.totalCapacity,
            tankType: tank.tankType,
            tankFunctions: tank.tankFunctions != null ? [...tank.tankFunctions!] : null,
          );
        }));

        // Update the subsequent operation with the new tank data
        Operation updatedOperation = Operation(
          operationId: subsequentOperation.operationId,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          isTargetTank: subsequentOperation.operationFunctionName.contains("To") ? true : false,
          allInitialTankData: lastFinalTankData,
          allFinalTankData: deepCopyUpdatedAllTankData,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
          date: subsequentOperation.date
        );

        updateEditedOperation(operationId: subsequentOperation.operationId, newOperationData: updatedOperation);
        lastFinalTankData = deepCopyUpdatedAllTankData;
      }
      // tankProvider.updateAllTanks(_operations.last.allFinalTankData);
      // tankProvider.updateAllTanks(editedOperationAllTankData);
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

        List<Tank> deepCopyUpdatedAllTankData = List.from(updatedAllTankData.map((tank) {
          return Tank(
            tankId: tank.tankId,
            tankName: tank.tankName,
            currentROB: tank.currentROB,
            totalCapacity: tank.totalCapacity,
            tankType: tank.tankType,
            tankFunctions: tank.tankFunctions != null ? [...tank.tankFunctions!] : null,
          );
        }));

        // Update the subsequent operation with the new tank data
        Operation updatedOperation = Operation(
          operationId: subsequentOperation.operationId,
          tankId: subsequentOperation.tankId,
          tankName: subsequentOperation.tankName,
          operationFunctionName: subsequentOperation.operationFunctionName,
          operationFunctionValue: subsequentOperation.operationFunctionValue,
          isTargetTank: subsequentOperation.operationFunctionName.contains("To") ? true : false,
          allInitialTankData: lastFinalTankData,
          allFinalTankData: deepCopyUpdatedAllTankData,
          targetTankName: subsequentOperation.operationFunctionName.contains("To") ? subsequentOperation.operationFunctionName.replaceFirst("To ", "") : null,
        date: subsequentOperation.date
        );

        updateEditedOperation(operationId: subsequentOperation.operationId, newOperationData: updatedOperation);
        lastFinalTankData = deepCopyUpdatedAllTankData;
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
        tankFunctions: tank.tankFunctions != null ? List<String>.from(tank.tankFunctions!) : null,
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

      Operation updatedOperation = Operation(
        operationId: newOperationData.operationId,
        tankId: newOperationData.tankId,
        tankName: newOperationData.tankName,
        operationFunctionName: newOperationData.operationFunctionName,
        operationFunctionValue: newOperationData.operationFunctionValue,
        isTargetTank: newOperationData.isTargetTank,
        allInitialTankData: newOperationData.allInitialTankData,
        allFinalTankData: newOperationData.allFinalTankData,
        targetTankName: newOperationData.targetTankName,
        date: newOperationData.date
      );

      _operations[index] = updatedOperation;
      notifyListeners();
    }
  }

  void reorderOperation({required int oldIndex, required int newIndex, required TankProvider tankProvider}) {
    if (oldIndex < 0 || oldIndex >= _operations.length || newIndex < 0 || newIndex >= _operations.length) {
      return;
    }

    int movedItemOperationId = _operations[oldIndex].operationId;
    int movedItemTankId = _operations[oldIndex].tankId;
    String movedItemTankName = _operations[oldIndex].tankName;
    String movedItemOperationFunctionName = _operations[oldIndex].operationFunctionName;
    double movedItemOperationFunctionValue = _operations[oldIndex].operationFunctionValue;
    bool movedItemIsTargetTank = _operations[oldIndex].isTargetTank;
    DateTime movedItemDate =_operations[oldIndex].date;
    String? movedItemTargetName = _operations[oldIndex].targetTankName;

    deleteOperation(operationId: movedItemOperationId, tankProvider: tankProvider);
    insertOperation(tankId: movedItemTankId, tankName: movedItemTankName, operationFunctionName: movedItemOperationFunctionName, operationFunctionValue: movedItemOperationFunctionValue, isTargetTank: movedItemIsTargetTank, insertIndex: newIndex, tankProvider: tankProvider,date: movedItemDate,targetTankName: movedItemTargetName);

    notifyListeners();
  }

}
