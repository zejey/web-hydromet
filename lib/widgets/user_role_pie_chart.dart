import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UserRolePieChart extends StatelessWidget {
  const UserRolePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 4,
              color: Colors.green,
              title: 'Users\n4',
              radius: 60,
              titleStyle: const TextStyle(
                color: Color.fromARGB(255, 190, 190, 190),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1,1))],
              ),
            ),
            PieChartSectionData(
              value: 4,
              color: Colors.blue,
              title: 'Emergency Responder\n4',
              radius: 60,
              titleStyle: const TextStyle(
                color: Color.fromARGB(255, 190, 190, 190),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1,1))],
              ),
            ),
            PieChartSectionData(
              value: 4,
              color: Colors.orange,
              title: 'Community Leader\n4',
              radius: 60,
              titleStyle: const TextStyle(
                color: Color.fromARGB(255, 190, 190, 190),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1,1))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
