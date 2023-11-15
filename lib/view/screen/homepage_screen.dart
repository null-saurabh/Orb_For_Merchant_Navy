import 'package:flutter/material.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/widgets/homepage_widgets/tank_ui.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text("ORB"),
      ),
      body: Consumer<TankProvider>(builder: (context,provider,_){
        return GridView.builder(
            padding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemCount: provider.allTanks.length,itemBuilder: (context,index){
          return TankUi(tank: provider.allTanks[index]);
        });
      }),
    );
  }
}



