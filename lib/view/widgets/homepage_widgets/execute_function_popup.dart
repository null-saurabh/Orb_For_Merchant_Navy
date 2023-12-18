import 'package:flutter/material.dart';
import 'package:orb/modal/operation_modal.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:provider/provider.dart';

import '../../../update/tank_provider.dart';

class ExecuteFunctionPopUp extends StatefulWidget {
  final Tank tank;
  final String functionName;
  const ExecuteFunctionPopUp(
      {required this.tank, required this.functionName, super.key});

  @override
  State<ExecuteFunctionPopUp> createState() => _ExecuteFunctionPopUpState();
}

class _ExecuteFunctionPopUpState extends State<ExecuteFunctionPopUp> {
  final TextEditingController valueController = TextEditingController();
  final TextEditingController operationIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String arithmeticExpression;


  @override
  void initState() {
    super.initState();
    if (widget.functionName == "Manual Addition" ||
        widget.functionName == "Daily Collection/Generation" ||
        widget.functionName == "From Engine Room Bilge Well") {
      arithmeticExpression = "add";
    } else if (widget.functionName == "Evaporation" ||
        widget.functionName == "Shore Disposal" ||
        widget.functionName == "Incinerated" ||
        widget.functionName == "Ows Overboard") {
      arithmeticExpression = "sub";
    } else {
      arithmeticExpression = "transfer";
    }
    operationIdController.text =
        (Provider.of<OperationProvider>(context, listen: false)
                    .allOperations
                    .isNotEmpty
                ? Provider.of<OperationProvider>(context, listen: false)
                    .allOperations
                    .last
                    .operationId +2 - (Provider.of<OperationProvider>(context,listen: false).allOperations.length - Provider.of<OperationProvider>(context,listen: false).allOperations.where((operation) => operation.operationFunctionName != "Daily Collection/Generation").toList().length)
                : 0 +1)
            .toString();
  }

  @override
  Widget build(BuildContext context) {

    List<Operation> allOperation = Provider.of<OperationProvider>(context).allOperations;
    List<Operation> filteredOutDailyCollectionFromAllTankOperations = allOperation.where((operation) => operation.operationFunctionName != "Daily Collection/Generation").toList();
    int totalDailyCollectionOperations = allOperation.length - filteredOutDailyCollectionFromAllTankOperations.length;


    return AlertDialog(
      contentPadding: const EdgeInsets.all(20.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: operationIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Operation ID',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Operation ID';
                }
                int? enteredOperationId = int.tryParse(value);
                if (enteredOperationId == null || enteredOperationId <= 0) {
                  return 'Please enter a valid positive integer for Operation ID';
                }
                int maxOperationId = Provider.of<OperationProvider>(context, listen: false).allOperations.length;

                if (enteredOperationId > maxOperationId +1) {
                  return 'Operation ID cannot be greater than $maxOperationId';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Value',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(), // Defines default border color
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(), // Defines default border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(), // Defines default border color
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                double? values = double.tryParse(value);
                if (values == null || values < 0) {
                  return 'Please enter a valid non-negative number for Initial ROB';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  OperationProvider operationProvider =
                      Provider.of<OperationProvider>(context, listen: false);

                  // Check if the user changed the operationId
                  int currentOperationId =
                      operationProvider.allOperations.isNotEmpty
                          ? operationProvider.allOperations.last.operationId +1 +1 - totalDailyCollectionOperations
                          : 0 +1;
                  int enteredOperationId =
                      int.parse(operationIdController.text);
                  // print("$currentOperationId : $enteredOperationId");

                  if (enteredOperationId == currentOperationId) {

                    bool success = Provider.of<TankProvider>(context,
                            listen: false)
                        .performNewFunction(
                            tankId: widget.tank.tankId,
                            operationFunctionName: widget.functionName,
                            operationFunctionValue:
                                double.tryParse(valueController.text) ?? 0,
                            arithmeticExpression: arithmeticExpression,
                            isTransfer: arithmeticExpression == "transfer"
                                ? true
                                : false,
                            targetTankName: arithmeticExpression == "transfer"
                                ? widget.functionName.replaceFirst("To ", "")
                                : null,
                            operationProvider: operationProvider,
                      date: DateTime.now()
                    );

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Operation not allowed."),
                        ),
                      );
                    } else{
                      Navigator.pop(context);
                    }
                  } else {
                    print('in insert ui');
                    Provider.of<OperationProvider>(context, listen: false)
                        .insertOperation(
                      tankId: widget.tank.tankId,
                      tankName: widget.tank.tankName,
                      operationFunctionName: widget.functionName,
                      operationFunctionValue:
                      double.tryParse(valueController.text) ?? 0,

                      isTargetTank: arithmeticExpression == "transfer"
                          ? true
                          : false,
                      targetTankName: arithmeticExpression == "transfer"
                          ? widget.functionName.replaceFirst("To ", "")
                          : null,
                      insertIndex: enteredOperationId -1 + totalDailyCollectionOperations,
                      tankProvider: Provider.of<TankProvider>(context, listen: false),
                        date: DateTime.now()

                    );
                    Navigator.pop(context);

                  }



                }
              },
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width * 0.65, 50))),
              child: const Text('Confirm'),
            )
          ],
        ),
      ),
    );
  }
}
