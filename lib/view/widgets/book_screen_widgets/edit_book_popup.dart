import 'package:flutter/material.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:provider/provider.dart';

class EditBookPopUp extends StatefulWidget {
  final int operationId;
  final double operationFunctionValue;
  final String operationFunctionName;
  final Tank tankData;
  const EditBookPopUp({required this.tankData,required this.operationId,required this.operationFunctionValue,required this.operationFunctionName,super.key});

  @override
  State<EditBookPopUp> createState() => _EditBookPopUpState();
}

class _EditBookPopUpState extends State<EditBookPopUp> {
  final TextEditingController valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? newOperationFunctionName;

  @override
  void initState() {
    super.initState();
      valueController.text = widget.operationFunctionValue.toString();
      newOperationFunctionName = widget.operationFunctionName;
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
                  return 'Please enter edited value';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: widget.operationFunctionName,
              onChanged: (newValue) {
                setState(() {
                  newOperationFunctionName = newValue!;
                });
              },
              items: widget.tankData.tankFunctions!
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelText: "Select Updated Operation",

              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select Operation';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                TankProvider tankProvider = Provider.of<TankProvider>(context,listen: false);

                Provider.of<OperationProvider>(context,listen: false).editOperation(
                    tankProvider: tankProvider,
                    operationId: widget.operationId,
                    newOperationFunctionName: newOperationFunctionName!,
                    newOperationFunctionValue: double.tryParse(valueController.text) ?? 0,
                );
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  minimumSize:
                  MaterialStateProperty.all(Size(MediaQuery.of(context).size.width *0.65, 50))),
              child: const Text('Save Operation'),
            )
          ],
        ),
      ),
    );
  }
}
