import 'package:flutter/material.dart';
import 'package:orb/modal/operation_modal.dart';
import 'package:orb/modal/tank_modal.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/widgets/book_screen_widgets/edit_book_popup.dart';
import 'package:provider/provider.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    // print(Provider.of<TankProvider>(context, listen: false)
    //     .allTanks.length);
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text("Book"),
      ),
      body: Consumer<OperationProvider>(
          builder: (context, operationProvider, _){
            List<Operation> allOperation = operationProvider.allOperations;

            return ReorderableListView(
              onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              operationProvider.reorderOperation(oldIndex, newIndex);
            },
              children:List.generate(
                  allOperation.length, (index) {
                return ListTile(leading: Text((index+1).toString()),
                  title:Text("${allOperation[index].tankName}: ${allOperation[index].operationFunctionName}, value: ${allOperation[index].operationFunctionValue}"),
                  trailing: IconButton(icon: const Icon(Icons.edit),onPressed: (){

                    Tank tankData = Provider.of<TankProvider>(context, listen: false)
                        .allTanks
                        .firstWhere((tank) => tank.tankId == allOperation[index].tankId);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) => EditBookPopUp(
                        tankData: tankData,
                        operationId: allOperation[index].operationId,
                        operationFunctionValue: allOperation[index].operationFunctionValue,
                        operationFunctionName: allOperation[index].operationFunctionName,
                      ),
                    );
                  }),
                );
              })

            );
          }
      ),
    );
  }
}





