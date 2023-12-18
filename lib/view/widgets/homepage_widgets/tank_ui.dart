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
  final DateTime date;
  const TankUi({
    required this.tank,
    required this.date,
    super.key,
  });

  @override
  State<TankUi> createState() => _TankUiState();
}

class _TankUiState extends State<TankUi> {
  String? performOperation;

  @override
  Widget build(BuildContext context) {
    List<Operation> allOperationForThisTank = Provider.of<OperationProvider>(context).getOperationsForSingleTank(tankId: widget.tank.tankId);
    List<Operation> filteredOutDailyCollectionFromThisTankOperations = allOperationForThisTank.where((operation) => operation.operationFunctionName != "Daily Collection/Generation").toList();

    List<Operation> allOperation = Provider.of<OperationProvider>(context).allOperations;
    List<Operation> filteredOutDailyCollectionFromAllTankOperations = allOperation.where((operation) => operation.operationFunctionName != "Daily Collection/Generation").toList();
    int totalDailyCollectionOperations = allOperation.length - filteredOutDailyCollectionFromAllTankOperations.length;

    Operation? dailyCollectionOperation;
    for (Operation operation in allOperationForThisTank) {
      if (operation.operationFunctionName == "Daily Collection/Generation") {
        dailyCollectionOperation = operation;
        break;
      }
    }
    String dailyCollectionValue = dailyCollectionOperation != null ? dailyCollectionOperation.operationFunctionValue.toString() : "0.0";

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
                        widget.tank.tankFunctions!.contains("Daily Collection/Generation")
                        ? Row(
                          children: [
                            IconButton(icon:  const Icon(Icons.edit),onPressed: (){

                              Tank tankData = Provider.of<TankProvider>(context, listen: false)
                                  .allTanks
                                  .firstWhere((tank) => tank.tankId == dailyCollectionOperation!.tankId);

                              showDialog(
                                context: context,
                                builder: (BuildContext context) => EditBookPopUp(
                                  tankData: tankData,
                                  operationId: dailyCollectionOperation!.operationId,
                                  operationFunctionValue: dailyCollectionOperation.operationFunctionValue,
                                  operationFunctionName: dailyCollectionOperation.operationFunctionName,
                                ),
                              );
                            }),
                            Text("Daily Collection: $dailyCollectionValue"),
                          ],
                        )
                            :const SizedBox(height: 1,) ,
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

                                  return ListView.builder(
                                    itemCount: filteredOutDailyCollectionFromThisTankOperations.length,
                                    itemBuilder: (context, index) {

                                      Tank initialTank = filteredOutDailyCollectionFromThisTankOperations[index]
                                          .allInitialTankData[filteredOutDailyCollectionFromThisTankOperations[index]
                                          .allInitialTankData
                                          .indexWhere((tank) =>
                                      tank.tankId ==
                                          filteredOutDailyCollectionFromThisTankOperations[index].tankId)];
                                      Tank finalTank = filteredOutDailyCollectionFromThisTankOperations[index]
                                          .allFinalTankData[filteredOutDailyCollectionFromThisTankOperations[index]
                                          .allFinalTankData
                                          .indexWhere((tank) =>
                                      tank.tankId ==
                                          filteredOutDailyCollectionFromThisTankOperations[index].tankId)];

                                      return Row(
                                        children: [
                                          Text(
                                            "${filteredOutDailyCollectionFromThisTankOperations[index].operationId + 1 - totalDailyCollectionOperations}. ${filteredOutDailyCollectionFromThisTankOperations[index].operationFunctionName}: ${filteredOutDailyCollectionFromThisTankOperations[index].operationFunctionValue} ( B.O: ${initialTank.currentROB}, A.O: ${finalTank.currentROB})",
                                          ),
                                          IconButton(icon:  const Icon(Icons.edit),onPressed: (){

                                            Tank tankData = Provider.of<TankProvider>(context, listen: false)
                                                .allTanks
                                                .firstWhere((tank) => tank.tankId == filteredOutDailyCollectionFromThisTankOperations[index].tankId);

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) => EditBookPopUp(
                                                tankData: tankData,
                                                operationId: filteredOutDailyCollectionFromThisTankOperations[index].operationId,
                                                operationFunctionValue: filteredOutDailyCollectionFromThisTankOperations[index].operationFunctionValue,
                                                operationFunctionName: filteredOutDailyCollectionFromThisTankOperations[index].operationFunctionName,
                                              ),
                                            );
                                          }),
                                          IconButton(icon:  const Icon(Icons.delete),onPressed: (){
                                            TankProvider tankProvider = Provider.of<TankProvider>(context,listen: false);
                                            Provider.of<OperationProvider>(context,listen: false).deleteOperation(
                                                operationId: filteredOutDailyCollectionFromThisTankOperations[index].operationId, tankProvider: tankProvider);
                                          }),

                                          // IconButton(icon:  const Icon(Icons.add),onPressed: (){
                                          //
                                          //   // TankProvider tankProvider = Provider.of<TankProvider>(context,listen: false);
                                          //
                                          // //   Provider.of<OperationProvider>(context,listen: false).insertOperation(
                                          // //       tankId: operationsForThisTank[index].tankId,
                                          // //       tankName: operationsForThisTank[index].tankName,
                                          // //       operationFunctionName: operationFunctionName,
                                          // //       operationFunctionValue: operationFunctionValue,
                                          // //       isTargetTank: isTargetTank,
                                          // //       insertIndex: operationsForThisTank[index].operationId,
                                          // //       tankProvider: tankProvider);
                                          // }),

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
                            items: widget.tank.tankFunctions!.where((function) => function != "Daily Collection/Generation").map<DropdownMenuItem<String>>((String value) {
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