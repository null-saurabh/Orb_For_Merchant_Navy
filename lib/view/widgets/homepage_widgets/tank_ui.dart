import 'package:flutter/material.dart';
import 'package:orb/modal/operation_modal.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/widgets/book_screen_widgets/edit_book_popup.dart';
import 'package:orb/view/widgets/homepage_widgets/capacity_indicator.dart';
import 'package:orb/view/widgets/homepage_widgets/execute_function_popup.dart';
import 'package:provider/provider.dart';

class TankUi extends StatefulWidget {
  final Tank tank;
  const TankUi({
    required this.tank,
    super.key,
  });

  @override
  State<TankUi> createState() => _TankUiState();
}

class _TankUiState extends State<TankUi> {
  String? performOperation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green)
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0,bottom: 12,right: 5,left: 5),
        child: Column(
          children: [
            Text(widget.tank.tankName,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15,),
                        const Text("Daily Collection: 05"),
                        const Text("Today's Operation's:",style:TextStyle(fontWeight: FontWeight.w500),),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                              child: Consumer<OperationProvider>(
                                builder: (context, operationProvider, _) {
                                  // Get operations for the current tank
                                  List<Operation> operationsForThisTank =
                                  operationProvider.getOperationsForSingleTank(tankId:widget.tank.tankId);

                                  return ListView.builder(
                                    itemCount: operationsForThisTank.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          Text(
                                            "${index + 1}. ${operationsForThisTank[index].operationFunctionName}: ${operationsForThisTank[index].operationFunctionValue}",
                                          ),
                                          IconButton(icon:  const Icon(Icons.edit),onPressed: (){

                                            Tank tankData = Provider.of<TankProvider>(context, listen: false)
                                                .allTanks
                                                .firstWhere((tank) => tank.tankId == operationsForThisTank[index].tankId);

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) => EditBookPopUp(
                                                tankData: tankData,
                                                operationId: operationsForThisTank[index].operationId,
                                                operationFunctionValue: operationsForThisTank[index].operationFunctionValue,
                                                operationFunctionName: operationsForThisTank[index].operationFunctionName,
                                              ),
                                            );
                                          })
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // const Spacer(),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 55),
                          child: DropdownButtonFormField<String>(
                            onChanged: (newValue) {
                              setState(() {
                                performOperation = newValue!;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => ExecuteFunctionPopUp(tank: widget.tank,functionName: newValue,),
                                );
                                Future.delayed(const Duration(seconds: 1), () {
                                  setState(() {
                                    performOperation = null;
                                  });
                                });
                              });
                            },
                            value: performOperation,
                            items: widget.tank.tankFunctions!.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none
                                // borderRadius: BorderRadius.only(),
                              ),
                              hintText: "Select Operations",
                              hintStyle: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis,),


                            ),

                            selectedItemBuilder: (BuildContext context) {
                              return widget.tank.tankFunctions!.map((String value) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 70,
                                    child: Text(value, overflow: TextOverflow.ellipsis,maxLines: 1,softWrap: false,style: const TextStyle(fontSize: 12),),
                                  ),
                                );
                              }).toList();
                            },

                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Column(

                    children: [
                      Text("Cap: ${widget.tank.totalCapacity}"),
                      Expanded(child: CapacityIndicator(totalCapacity: widget.tank.totalCapacity, currentCapacity: widget.tank.currentROB)),
                      Text("ROB: ${widget.tank.currentROB.toStringAsFixed(2)}"),

                    ],
                  )
                ],),
            ),
          ],
        ),
      ),
    );
  }
}