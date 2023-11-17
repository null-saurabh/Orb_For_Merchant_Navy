
import 'package:flutter/material.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:provider/provider.dart';

import '../../../update/tank_provider.dart';

class ExecuteFunctionPopUp extends StatefulWidget {
  final Tank tank;
  final String functionName;
  const ExecuteFunctionPopUp({required this.tank,required this.functionName,super.key});

  @override
  State<ExecuteFunctionPopUp> createState() => _ExecuteFunctionPopUpState();
}

class _ExecuteFunctionPopUpState extends State<ExecuteFunctionPopUp> {
  final TextEditingController valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String arithmeticExpression;

  @override
  void initState() {
    super.initState();
    if(widget.functionName == "Manual Addition" || widget.functionName == "Daily Collection/Generation" || widget.functionName == "From Engine Room Bilge Well")
    {
      arithmeticExpression = "add";
    }
    else if(widget.functionName == "Evaporation" || widget.functionName == "Shore Disposal" || widget.functionName == "Incinerated" || widget.functionName == "Ows Overboard")
    {
      arithmeticExpression = "sub";
    }
    else{
      arithmeticExpression = "transfer";
    }
  }

  @override
  Widget build(BuildContext context) {
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
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Value',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(), // Defines default border color
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(), // Defines default border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(), // Defines default border color
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                double? values = double.tryParse(value);
                if (values == null || values< 0) {
                  return 'Please enter a valid non-negative number for Initial ROB';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                    OperationProvider operationProvider = Provider.of<OperationProvider>(context, listen: false);

                    bool success = Provider.of<TankProvider>(context, listen: false).performNewFunction(
                        tankId: widget.tank.tankId,
                        operationFunctionName: widget.functionName,
                        operationFunctionValue: double.tryParse(valueController.text) ?? 0,
                        arithmeticExpression: arithmeticExpression,
                        isTransfer: arithmeticExpression == "transfer" ? true:false,
                        targetTankName: arithmeticExpression == "transfer" ?widget.functionName.replaceFirst("To ",""):null,
                        operationProvider:operationProvider);

                    Navigator.pop(context);

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Operation not allowed. Please allocate operations to all tanks before proceeding."),
                        ),
                      );
                    }
                }
              },
              style: ButtonStyle(
                  minimumSize:
                  MaterialStateProperty.all(Size(MediaQuery.of(context).size.width *0.65, 50))),
              child: const Text('Confirm'),
            )
          ],
        ),
      ),
    );
  }
}
