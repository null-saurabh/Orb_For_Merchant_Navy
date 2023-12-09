import 'package:flutter/material.dart';
import 'package:orb/update/operation_provider.dart';
import 'package:orb/update/tank_provider.dart';
import 'package:orb/view/screen/add_tank_screen.dart';
import 'package:orb/view/screen/homepage_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? tanksJson = prefs.getStringList('tanks');

  runApp(MyApp(hasTanks: tanksJson != null && tanksJson.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool hasTanks;

  const MyApp({super.key,required this.hasTanks});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TankProvider()),
        ChangeNotifierProvider(create: (_) => OperationProvider()),
        // Add other providers if needed
      ],
      child: MaterialApp(
        title: 'Orb Book',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: hasTanks ? const HomePageScreen() : const AddTankScreen(),
      ),
    );
  }
}