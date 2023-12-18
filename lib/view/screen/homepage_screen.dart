import 'package:flutter/material.dart';
import 'package:orb/modal/operation_modal.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/screen/book_screen.dart';
import 'package:orb/view/widgets/book_screen_widgets/edit_book_popup.dart';
import 'package:orb/view/widgets/homepage_widgets/tank_ui.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  DateTime _selectedDate = DateTime.now();


  // @override
  // void initState() {
  //   TankProvider tankProvider = TankProvider();
  //   tankProvider.initializeTanksFromPreferences();
  //   super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 5, title: const Text("ORB"), actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null && pickedDate != _selectedDate) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
        ),

        IconButton(
          icon: const Icon(Icons.menu_book_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BookScreen(),
              ),
            );
          },
        ),
      ]),
      body: Consumer<TankProvider>(builder: (context, provider, _) {
        // print(provider.allTanks.length);
        // print(Provider.of<TankProvider>(context).allTanks.length);
        return Row(
          children: [
            Flexible(
              flex: 4,
              child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    childAspectRatio: 2/1.5,
                  ),
                  itemCount: provider.allTanks.length,
                  itemBuilder: (context, index) {
                    return TankUi(tank: provider.allTanks[index],date:  _selectedDate);
                  }),
            ),
            Flexible(
                flex: 2,
                child: Container(
                  height: double.infinity,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Consumer<OperationProvider>(
                      builder: (context, operationProvider, _) {
                    List<Operation> allOperation =
                        operationProvider.allOperations;
                    TankProvider tankProvider =
                        Provider.of<TankProvider>(context, listen: false);

                    return bookOverView(operationProvider, tankProvider, allOperation, context);
                  }),
                ))
          ],
        );
      }),
    );
  }

  ReorderableListView bookOverView(OperationProvider operationProvider, TankProvider tankProvider, List<Operation> allOperation, BuildContext context) {
    return ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        operationProvider.reorderOperation(
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                            tankProvider: tankProvider);
                      },
                      children: List.generate(allOperation.length, (index) {
                        Tank initialTank = allOperation[index]
                            .allInitialTankData[allOperation[index]
                                .allInitialTankData
                                .indexWhere((tank) =>
                                    tank.tankId ==
                                    allOperation[index].tankId)];
                        Tank finalTank = allOperation[index]
                            .allFinalTankData[allOperation[index]
                                .allFinalTankData
                                .indexWhere((tank) =>
                                    tank.tankId ==
                                    allOperation[index].tankId)];

                        // print("${allOperation[index].tankName} => ${allOperation[index].operationFunctionName}: ${allOperation[index].operationFunctionValue} ( initial: ${initialTank.currentROB}, final: ${finalTank.currentROB} )");
                        return ListTile(
                          key: ValueKey(index),
                          leading: Text((index + 1).toString()),
                          title: Text(
                              "${allOperation[index].tankName} => ${allOperation[index].operationFunctionName}: ${allOperation[index].operationFunctionValue} ( initial: ${initialTank.currentROB}, final: ${finalTank.currentROB} )"),
                          subtitle: (() {
                            if (finalTank.currentROB > finalTank.totalCapacity) {
                              return const Text("Error: Rob Exceeds Capacity",
                                  style: TextStyle(color: Colors.red));
                            } else if ((finalTank.currentROB/finalTank.totalCapacity)*100 > 90) {
                              return const Text("Warning: High Level",
                                  style: TextStyle(color: Colors.purple));
                            } else if (finalTank.currentROB < 0) {
                              return const Text("Error: Tank is negative",
                                  style: TextStyle(color: Colors.red));
                            }else if ((finalTank.currentROB/finalTank.totalCapacity)*100 < 10) {
                              return const Text("Warning: Low Level",
                                  style: TextStyle(color: Colors.purple));
                            } else {
                              return null; // No subtitle if none of the conditions are met
                            }
                          })(),

                          onTap: () {
                            Tank tankData = tankProvider.allTanks.firstWhere(
                                    (tank) => tank.tankId == allOperation[index].tankId);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) => EditBookPopUp(
                                tankData: tankData,
                                operationId: allOperation[index].operationId,
                                operationFunctionValue:
                                allOperation[index].operationFunctionValue,
                                operationFunctionName:
                                allOperation[index].operationFunctionName,
                              ),
                            );
                          },
                        );
                      }));
  }
}
