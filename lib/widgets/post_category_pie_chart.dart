import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PostCategoryPieChart extends StatelessWidget {
  const PostCategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for post category pie chart
      return AspectRatio(
        aspectRatio: 1.5,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: 8,
                color: Colors.blue,
                title: 'Information\n8',
                radius: 60,
                titleStyle: const TextStyle(color: Color.fromARGB(255, 190, 190, 190), fontSize: 14),
              ),
              PieChartSectionData(
                value: 6,
                color: Colors.orange,
                title: 'Warning\n6',
                radius: 60,
                titleStyle: const TextStyle(color: Color.fromARGB(255, 190, 190, 190), fontSize: 14),
              ),
              PieChartSectionData(
                value: 10,
                color: Colors.red,
                title: 'Alert\n10',
                radius: 60,
                titleStyle: const TextStyle(color: Color.fromARGB(255, 190, 190, 190), fontSize: 14),
              ),
            ],
          ),
        ),
      );
  }
}
