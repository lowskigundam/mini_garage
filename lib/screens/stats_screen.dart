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
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildMessage(
              icon: Icons.error_outline,
              title: "Unable to load statistics",
              message: "Please try again later.",
            );
          }

          // Keep only valid gas records.
          final logs = (snapshot.data ?? [])
              .where((log) => log['date'] is Timestamp && log['price'] is num)
              .map((log) => Map<String, dynamic>.from(log))
              .toList();

          if (logs.isEmpty) {
            return _buildMessage(
              icon: Icons.local_gas_station_outlined,
              title: "No gas records yet",
              message: "Add gas records to generate statistics.",
            );
          }

          // Oldest record first, newest record last.
          logs.sort((a, b) {
            final dateA = (a['date'] as Timestamp).toDate();
            final dateB = (b['date'] as Timestamp).toDate();

            return dateA.compareTo(dateB);
          });

          final prices = logs
              .map((log) => (log['price'] as num).toDouble())
              .toList();

          final total = prices.fold<double>(0, (sum, price) => sum + price);

          final latest = prices.last;
          final average = total / prices.length;

          final lowest = prices.reduce((a, b) => a < b ? a : b);

          final highest = prices.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const Text(
                "Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                "Summary of recorded gas values",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),

              const SizedBox(height: 16),

              // ================= SUMMARY CARDS =================
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.payments_outlined,
                      label: "Latest",
                      value: _formatCurrencyCompact(latest),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.calculate_outlined,
                      label: "Average",
                      value: _formatCurrencyCompact(average),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.receipt_long_outlined,
                      label: "Records",
                      value: prices.length.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= CHART =================
              _buildChartCard(context, logs, prices),

              const SizedBox(height: 20),

              // ================= RANGE CARD =================
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RangeItem(
                          icon: Icons.trending_down,
                          label: "Lowest",
                          value: _formatCurrency(lowest),
                        ),
                      ),

                      Container(width: 1, height: 48, color: Colors.grey[300]),

                      Expanded(
                        child: _RangeItem(
                          icon: Icons.trending_up,
                          label: "Highest",
                          value: _formatCurrency(highest),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    List<Map<String, dynamic>> logs,
    List<double> prices,
  ) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gas Record Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              logs.length < 2
                  ? "Add another record to create a trend"
                  : "Tap a point to view its value",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),

            const SizedBox(height: 24),

            if (logs.length < 2)
              SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart, size: 52, color: Colors.grey[400]),

                      const SizedBox(height: 12),

                      const Text(
                        "Not enough data for a chart",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "At least two gas records are required.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 280,
                child: _buildLineChart(context, logs, prices, primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    List<Map<String, dynamic>> logs,
    List<double> prices,
    Color primary,
  ) {
    final spots = <FlSpot>[];

    for (int i = 0; i < prices.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i]));
    }

    final lowest = prices.reduce((a, b) => a < b ? a : b);

    final highest = prices.reduce((a, b) => a > b ? a : b);

    final range = highest - lowest;

    final padding = range == 0
        ? (highest == 0 ? 1000.0 : highest * 0.10)
        : range * 0.15;

    final calculatedMinY = lowest - padding;

    final minY = calculatedMinY < 0 ? 0.0 : calculatedMinY;

    final maxY = highest + padding;

    final yInterval = (maxY - minY) / 4;

    // Show approximately four labels on the X axis.
    final labelStep = logs.length <= 4 ? 1 : ((logs.length - 1) / 3).ceil();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (logs.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,

        // Touch a point to view date and value.
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.round();

                final date = (logs[index]['date'] as Timestamp)
                    .toDate()
                    .toLocal();

                return LineTooltipItem(
                  "${_formatCurrency(spot.y)}\n"
                  "${_formatFullDate(date)}",
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),

        // Only show horizontal grid lines.
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval <= 0 ? 1 : yInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.20),
              strokeWidth: 1,
            );
          },
        ),

        titlesData: FlTitlesData(
          // Remove the unwanted labels at the top.
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Remove the unwanted labels on the right.
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: yInterval <= 0 ? 1 : yInterval,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatAxisValue(value),
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();

                // Ignore fractional or invalid positions.
                if ((value - index).abs() > 0.01 ||
                    index < 0 ||
                    index >= logs.length) {
                  return const SizedBox.shrink();
                }

                final isFirst = index == 0;
                final isLast = index == logs.length - 1;
                final isStep = index % labelStep == 0;

                if (!isFirst && !isLast && !isStep) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatXAxisLabel(logs, index),
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.30)),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            barWidth: 3,
            color: primary,
            isStrokeCapRound: true,

            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),

            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primary.withValues(alpha: 0.25),
                  primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return "${value.toStringAsFixed(0)} ₫";
  }

  String _formatCurrencyCompact(double value) {
    return "${_formatAxisValue(value)} ₫";
  }

  String _formatAxisValue(double value) {
    if (value.abs() >= 1000000) {
      final converted = value / 1000000;

      return "${converted.toStringAsFixed(converted == converted.roundToDouble() ? 0 : 1)}M";
    }

    if (value.abs() >= 1000) {
      final converted = value / 1000;

      return "${converted.toStringAsFixed(converted == converted.roundToDouble() ? 0 : 1)}K";
    }

    return value.toStringAsFixed(0);
  }

  String _formatXAxisLabel(List<Map<String, dynamic>> logs, int index) {
    final date = (logs[index]['date'] as Timestamp).toDate().toLocal();

    bool anotherRecordOnSameDay = false;

    for (int i = 0; i < logs.length; i++) {
      if (i == index) continue;

      final otherDate = (logs[i]['date'] as Timestamp).toDate().toLocal();

      if (otherDate.year == date.year &&
          otherDate.month == date.month &&
          otherDate.day == date.day) {
        anotherRecordOnSameDay = true;
        break;
      }
    }

    // When several records share one date, show their times
    // instead of repeating the same date.
    if (anotherRecordOnSameDay) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$hour:$minute";
    }

    return "${date.day}/${date.month}";
  }

  String _formatFullDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "${date.day}/${date.month}/${date.year} "
        "$hour:$minute";
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: primary),

          const Spacer(),

          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),

          const SizedBox(height: 3),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RangeItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Icon(icon, color: primary),

        const SizedBox(height: 7),

        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),

        const SizedBox(height: 4),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
