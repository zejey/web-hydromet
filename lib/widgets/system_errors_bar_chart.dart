import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SystemErrorsBarChart extends StatelessWidget {
  const SystemErrorsBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.0,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4, color: Colors.red)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 9, color: Colors.orange)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.blue)]),
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
                  const labels = ['Network', 'Auth', 'Database'];
                  return Text(labels[value.toInt()], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}