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
    maxY: 4000,
    minY: 0,
  );

  List<LineChartBarData> get lineBarsData => [
    LineChartBarData(
      spots: netRevenue,
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false)
    ),
    LineChartBarData(
      spots: collected,
      isCurved: true,
      color: Colors.green,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    ),
    LineChartBarData(
      spots: actualReceived,
      isCurved: true,
      color: Colors.orange,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    ),
  ];

  LineTouchData get lineTouchData => LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
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
    const style = TextStyle(
      fontSize: 10,
    );
    return Text('\$${value.toInt()}', style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
    getTitlesWidget: leftTitleWidgets,
    showTitles: true,
    interval: 1000,
    reservedSize: 40,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 9,
    );
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
    horizontalInterval: 1000,
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Bar Line Chart')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarLineChart(
              netRevenue: [
                FlSpot(0, 1000),
                FlSpot(6, 1500),
                FlSpot(12, 2000),
                FlSpot(18, 2500),
                FlSpot(24, 3000),
              ],
              collected: [
                FlSpot(0, 800),
                FlSpot(6, 1200),
                FlSpot(12, 1800),
                FlSpot(18, 2200),
                FlSpot(24, 2700),
              ],
              actualReceived: [
                FlSpot(0, 1200),
                FlSpot(6, 1600),
                FlSpot(12, 2200),
                FlSpot(18, 2800),
                FlSpot(24, 3200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
