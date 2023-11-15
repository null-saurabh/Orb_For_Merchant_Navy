import 'package:flutter/material.dart';
import 'package:orb/view/widgets/add_tank_screen_widgets/add_tank_popup.dart';

class NoTankDesign extends StatelessWidget {
  const NoTankDesign({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: (MediaQuery.of(context).size.height)/2 - 200),
        SizedBox(
          height: 105,
          width: double.infinity,
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const AddTankPopUp(editTank: false,),
              );
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.black26,
              size: 100,
            ),
          ),
        ),
        const Padding(
          padding:
          EdgeInsets.only(top: 10, bottom: 25),
          child: Text("Add All Onboarded Tanks Here",
              style: TextStyle(
                  color: Colors.black38,
                  fontSize: 19,
                  fontWeight: FontWeight.w500)),
        )
      ],
    );
  }
}
