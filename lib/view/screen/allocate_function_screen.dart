import 'package:flutter/material.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/screen/homepage_screen.dart';
import 'package:orb/view/widgets/allocate_function_widgets/function_selection_popup.dart';
import 'package:provider/provider.dart';

class AllocateFunctionToTank extends StatelessWidget {
  const AllocateFunctionToTank({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15.0, bottom: 10),
            child: Text(
              "*Please allocate operations to each tank before proceeding further",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero))),
                child: const Text("Save & Next"),
                onPressed: () {
                  bool allTanksHaveOperations =
                      Provider.of<TankProvider>(context, listen: false)
                          .allTanks
                          .every(
                            (tank) =>
                                tank.tankFunctions != null &&
                                tank.tankFunctions!.isNotEmpty,
                          );
                  if (allTanksHaveOperations) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePageScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please allocate operations to all tanks before proceeding."),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
      appBar: AppBar(
        elevation: 5,
        title: const Text("Allocate Operations for each Tank"),
      ),
      body: Consumer<TankProvider>(builder: (context, provider, _) {
        return ListView.builder(
            itemCount: provider.allTanks.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(
                    provider.allTanks[index].tankName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tank Type: ${provider.allTanks[index].tankType}"),
                      const Text(
                        "Selected  Operations:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (provider.allTanks[index].tankFunctions != null &&
                          provider.allTanks[index].tankFunctions!.isNotEmpty)
                        ...provider.allTanks[index].tankFunctions!
                            .asMap()
                            .entries
                            .map((entry) =>
                                Text("${entry.key + 1}. ${entry.value}"))
                            .toList()
                      else
                        const Text("No operations selected"),
                    ],
                  ),
                  trailing: GestureDetector(
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 40,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => FunctionSelectionPopUP(
                            tank: provider.allTanks[index]),
                      );
                    },
                  ),
                ),
              );
            });
      }),
    );
  }
}
