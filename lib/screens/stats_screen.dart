import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class StatsScreen extends StatelessWidget {
  final String vehicleId;

  const StatsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gas Statistics")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getGasHistory(vehicleId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;

          if (logs.length < 2) {
            return const Center(child: Text("Not enough data for chart"));
          }

          // ⚠️ Sort ASCENDING for chart
          logs.sort((a, b) {
            final da = (a['date'] as Timestamp).toDate();
            final db = (b['date'] as Timestamp).toDate();
            return da.compareTo(db);
          });

          final spots = <FlSpot>[];

          for (int i = 0; i < logs.length; i++) {
            final price = (logs[i]['price'] as num).toDouble();
            spots.add(FlSpot(i.toDouble(), price));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= logs.length) {
                          return const Text("");
                        }

                        final date = (logs[index]['date'] as Timestamp)
                            .toDate();

                        return Text(
                          "${date.month}/${date.day}",
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),

                borderData: FlBorderData(show: true),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
