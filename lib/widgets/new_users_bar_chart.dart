import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NewUsersBarChart extends StatelessWidget {
  const NewUsersBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4, color: Colors.blue)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: Colors.blue)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 11, color: Colors.blue)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: Colors.blue)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Mar', 'Apr', 'May', 'Jun', 'Jul'];
                  return Text(months[value.toInt()], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
