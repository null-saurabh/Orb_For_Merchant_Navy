import 'package:flutter/material.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/screen/book_screen.dart';
import 'package:orb/view/widgets/homepage_widgets/tank_ui.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  @override
  void initState() {
    TankProvider tankProvider = TankProvider();
    tankProvider.initializeTanksFromPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text("ORB"),
        actions: [IconButton(icon: const Icon(Icons.menu_book_outlined),onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BookScreen(),
            ),
          );
        },),]
      ),
      body: Consumer<TankProvider>(builder: (context,provider,_){
        print(provider.allTanks.length);
        print(Provider.of<TankProvider>(context).allTanks.length);
        return Row(
          children: [
            Flexible(
              flex: 4,
              child: GridView.builder(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25),
                  itemCount: provider.allTanks.length,itemBuilder: (context,index){
                return TankUi(tank: provider.allTanks[index]);
              }),
            ),
            Flexible(flex: 1,
                child: Container(height: double.infinity,decoration: BoxDecoration(border: Border.all(color: Colors.grey)),)
            )
          ],
        );
      }),
    );
  }
}



