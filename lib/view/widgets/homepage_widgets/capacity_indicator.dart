import 'package:flutter/material.dart';

class CapacityIndicator extends StatelessWidget {
  final double totalCapacity;
  final double currentCapacity;

  const CapacityIndicator({super.key, required this.totalCapacity, required this.currentCapacity});

  @override
  Widget build(BuildContext context) {

    double percentage = (currentCapacity / totalCapacity).clamp(0.0, 1.0);

    Color barColor;
    if (percentage >= 0.9) {
      barColor = Colors.red;
    } else if (percentage >= 0.85) {
      barColor = Colors.yellow;
    }else {
      barColor = Colors.green;  // water blue
    }

    return Container(
      height: double.infinity,
      width: 10,
      decoration: BoxDecoration(
        color: Colors.grey,  // this will be the background color of the bar
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.black),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter, // This ensures the colored bar starts from the bottom
        children: <Widget>[
          FractionallySizedBox(
            heightFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}