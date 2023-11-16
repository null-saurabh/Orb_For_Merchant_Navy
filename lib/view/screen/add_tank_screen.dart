import 'package:flutter/material.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/screen/allocate_function_screen.dart';
import 'package:orb/view/widgets/add_tank_screen_widgets/add_tank_popup.dart';
import 'package:orb/view/widgets/add_tank_screen_widgets/no_tank_ui_widget.dart';
import 'package:provider/provider.dart';

class AddTankScreen extends StatelessWidget {
  const AddTankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Provider.of<TankProvider>(context).allTanks.isNotEmpty
          ?Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15.0,bottom: 10),
            child: Text("* Please add all required tanks before proceeding further",style: TextStyle(fontWeight: FontWeight.w500),),
          ),
          SizedBox(height: 50,width: double.infinity,
            child: ElevatedButton(style:ButtonStyle(shape:
            MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.zero))),child: const Text("Save & Next"), onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AllocateFunctionToTank()));
            }),
          ),
        ],
      ):null,
      appBar: AppBar(
        elevation: 10,
        title: const Text("Add All Tanks"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {showDialog(
          context: context,
          builder: (BuildContext context) => const AddTankPopUp(editTank: false,),
        );},
        child: const Icon(Icons.add),
      ),

      body: Consumer<TankProvider>(builder: (context, provider, _) {
        return provider.allTanks.isEmpty
            ?const NoTankDesign()
            : ListView.builder(
            itemCount: provider.allTanks.length,
            itemBuilder: (context,index){
              return Card(
                child: ListTile(title: Text(provider.allTanks[index].tankName,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Max Capacity: ${provider.allTanks[index].totalCapacity} m³"),
                      Text("Initial Rob: ${provider.allTanks[index].currentROB} m³"),
                      Text("Tank Type: ${provider.allTanks[index].tankType}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(child: const Icon(Icons.edit,size: 25,),onTap:(){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AddTankPopUp(editTank:true,tankDataToEdit: provider.allTanks[index],),
                        );
                      },),
                      const SizedBox(width: 7,),
                      Container(
                        height:30,  // Adjust height to your need
                        width: 2,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(width: 7,),
                      GestureDetector(child: const Icon(Icons.delete_forever,size: 25,),onTap: (){
                        provider.deleteTank(tankId:provider.allTanks[index].tankId);

                      },),
                    ],
                  ),),
              );
            });
      }),
    );
  }


}
