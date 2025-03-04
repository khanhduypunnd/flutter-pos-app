import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/core/theme/colors.dart';
import '../../../../../view_model/report_model.dart';

class InteractivePieChart extends StatefulWidget {
  final Map<String, double> data;
  const InteractivePieChart({super.key, required this.data});

  @override
  State<InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<InteractivePieChart> {
  int? touchedIndex;

  late double maxWidth;

  
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }
  

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);
    
    final filteredData = widget.data.entries.where((entry) => entry.value > 0).toMap();
    double total = filteredData.values.fold(0, (sum, value) => sum + value);

    bool changeLayout = maxWidth > 750 ;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: changeLayout ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pie Chart
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: _buildSections(filteredData, total),
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 50,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                touchedIndex =
                                    response?.touchedSection?.touchedSectionIndex;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLegend(filteredData),
                  ],
                ),
              ),
        
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.blueAccent),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Phương thức thanh toán",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Thực nhận",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      // Table Rows
                      ...widget.data.entries.where((entry) => entry.value > 0).map((entry) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(entry.key),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${reportModel.formatCurrencyDouble(entry.value)} đ", style: const TextStyle(fontSize: 18),),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ) :
          Container(
            height: 800,
            child: Column(
                children: [
                  // Pie Chart
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _buildSections(filteredData, total),
                              borderData: FlBorderData(show: false),
                              centerSpaceRadius: 50,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    touchedIndex =
                                        response?.touchedSection?.touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLegend(filteredData),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey, width: 1),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Phương thức thanh toán",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Thực nhận",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          // Table Rows
                          ...widget.data.entries.where((entry) => entry.value > 0).map((entry) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(entry.key),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${reportModel.formatCurrencyDouble(entry.value)} đ", style: const TextStyle(fontSize: 18),),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(Map<String, double> data, double total) {
    return data.entries.mapIndexed((index, entry) {
      double percentage = (entry.value / total) * 100;
      bool isTouched = index == touchedIndex;
      double radius = isTouched ? 60 : 50;

      return PieChartSectionData(
        color: _getColor(entry.key),
        value: entry.value,
        title: '',
        radius: radius,
        badgeWidget: _buildPercentageBadge('${percentage.toStringAsFixed(1)}%'),
        badgePositionPercentageOffset: 1.5,
      );
    }).toList();
  }

  Widget _buildPercentageBadge(String percentage) {
    return Text(
      percentage,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildLegend(Map<String, double> data) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.keys.map((key) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getColor(key),
            ),
            const SizedBox(width: 8),
            Text(key),
          ],
        );
      }).toList(),
    );
  }

  Color _getColor(String label) {
    switch (label) {
      case "Tiền mặt":
        return Colors.teal;
      case "Chuyển khoản":
        return Colors.indigoAccent.shade400;
      case "Momo":
        return Colors.purple;
      case "Thanh toán thẻ":
        return Colors.orange.shade800;
      case "ZaloPay":
        return Colors.blueAccent.shade400;
      case "VNPay":
        return Colors.deepOrangeAccent.shade400;
      default:
        return Colors.grey;
    }
  }
}

extension MapExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() {
    return {for (var entry in this) entry.key: entry.value};
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}
