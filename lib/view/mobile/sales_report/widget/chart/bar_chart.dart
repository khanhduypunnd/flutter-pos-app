import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<int> orders;
  final List<int> products;

  const BarChartWidget({
    required this.orders,
    required this.products,
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

  List<int> aggregateData(List<int> data, double interval) {
    int groupSize = interval.toInt();
    List<int> aggregated = [];
    for (int i = 0; i < data.length; i += groupSize) {
      aggregated.add(data.sublist(i, i + groupSize > data.length ? data.length : i + groupSize).reduce((a, b) => a + b));
    }
    return aggregated;
  }

  @override
  Widget build(BuildContext context) {
    double interval = getIntervalBasedOnScreenSize(context);
    List<int> aggregatedOrders = aggregateData(orders, interval);
    List<int> aggregatedProducts = aggregateData(products, interval);

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Thời gian: ${(group.x * interval).toInt()}-${(group.x * interval + interval - 1).toInt()}h\n${rodIndex == 0 ? 'Số lượng đơn: ' : 'Số lượng sản phẩm: '}${rod.toY.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                double interval = getIntervalBasedOnScreenSize(context);
                int startHour = (value * interval).toInt();
                int endHour = (startHour + interval - 1).toInt();
                if (interval == 1) {
                  return Text('$startHour');
                }
                return Text('$startHour-$endHour');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value % 10 == 0) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(aggregatedOrders.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: aggregatedOrders[index].toDouble(),
                color: Colors.blueAccent,
                width: 8,
              ),
              BarChartRodData(
                toY: aggregatedProducts[index].toDouble(),
                color: Colors.greenAccent,
                width: 8,
              ),
            ],
            barsSpace: 4,
          );
        }),
      ),
    );
  }
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
        appBar: AppBar(title: const Text('Bar Chart with Dynamic Interval')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChartWidget(
              orders: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120],
              products: [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72],
            ),
          ),
        ),
      ),
    );
  }
}
