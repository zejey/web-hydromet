import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NotificationsLineChart extends StatelessWidget {
  const NotificationsLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for notifications line chart
    return AspectRatio(
      aspectRatio: 2.5,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 3),
                FlSpot(1, 6),
                FlSpot(2, 5),
                FlSpot(3, 8),
                FlSpot(4, 6),
                FlSpot(5, 9),
                FlSpot(6, 12),
              ],
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.2)),
              dotData: FlDotData(show: true),
            ),
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
                  const months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
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
