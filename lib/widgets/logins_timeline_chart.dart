import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LoginsTimelineChart extends StatelessWidget {
  const LoginsTimelineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.0,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 2),
                FlSpot(1, 4),
                FlSpot(2, 8),
                FlSpot(3, 12),
                FlSpot(4, 10),
                FlSpot(5, 7),
                FlSpot(6, 5),
                FlSpot(7, 3),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
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
                  const times = ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'];
                  return Text(times[value.toInt()], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}