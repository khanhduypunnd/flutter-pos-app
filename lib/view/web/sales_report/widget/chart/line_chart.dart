import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarLineChart extends StatelessWidget {
  final List<FlSpot> netRevenue;
  final List<FlSpot> collected;
  final List<FlSpot> actualReceived;

  const BarLineChart({
    required this.netRevenue,
    required this.collected,
    required this.actualReceived,
    Key? key,
  }) : super(key: key);

  double getIntervalBasedOnScreenSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 4;
    } else if (width < 800) {
      return 3;
    } else if (width < 1000) {
      return 2;
    } else {
      return 1;
    }
  }

  double getMaxY() {
    double maxNetRevenue = netRevenue.isNotEmpty
        ? netRevenue.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double maxCollected = collected.isNotEmpty
        ? collected.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double maxActualReceived = actualReceived.isNotEmpty
        ? actualReceived.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    double maxY = [maxNetRevenue, maxCollected, maxActualReceived]
        .reduce((a, b) => a > b ? a : b);
    double scaleFactor = getScaleFactor();
    return maxY / scaleFactor;
  }

  double getScaleFactor() {
    double maxNetRevenue = netRevenue.isNotEmpty
        ? netRevenue.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double maxCollected = collected.isNotEmpty
        ? collected.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double maxActualReceived = actualReceived.isNotEmpty
        ? actualReceived.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    double maxY = [maxNetRevenue, maxCollected, maxActualReceived]
        .reduce((a, b) => a > b ? a : b);

    double scaleFactor = maxY > 1000000 ? 1000000 : (maxY > 10000 ? 10000 : 1);
    return scaleFactor;
  }

  List<FlSpot> scaleSpots(List<FlSpot> spots, double scaleFactor) {
    return spots.map((spot) => FlSpot(spot.x, spot.y / scaleFactor)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData(context),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData sampleData(BuildContext context) => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData(context),
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        maxX: 24,
        maxY: getMaxY(),
        minY: 0,
      );

  List<LineChartBarData> get lineBarsData {
    final scaleFactor = getScaleFactor();
    return [
      LineChartBarData(
        spots: scaleSpots(netRevenue, scaleFactor),
        isCurved: false,
        color: Colors.blue,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: scaleSpots(collected, scaleFactor),
        isCurved: false,
        color: Colors.green,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: scaleSpots(actualReceived, scaleFactor),
        isCurved: false,
        color: Colors.purple,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            final scaleFactor = getScaleFactor();
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final originalValue = touchedSpot.y * scaleFactor;
              return LineTooltipItem(
                '${originalValue.toInt()} Triệu',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      );

  FlTitlesData titlesData(BuildContext context) => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles(context),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final scaleFactor = getScaleFactor();
    const style = TextStyle(fontSize: 10);

    final scaledMaxY = getMaxY();
    final highestEvenTick = (scaledMaxY / 2).floor() * 2;

    if (value == 0 || value > highestEvenTick) {
      return Container();
    }

    return Text('${(value * scaleFactor).toInt()} Triệu',
        style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 2,
        reservedSize: 80,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 9);
    return Text('${value.toInt()}h', style: style);
  }

  SideTitles bottomTitles(BuildContext context) => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: getIntervalBasedOnScreenSize(context),
        getTitlesWidget: bottomTitleWidgets,
      );


  FlGridData get gridData => FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        drawVerticalLine: false,
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.withOpacity(0.2),
            width: 4,
          ),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );
}
