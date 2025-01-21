import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:dacntt1_mobile_store/shared/core/pick_date/pick_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'widget/chart/line_chart.dart';
import 'widget/chart/pie_chart.dart';
import 'widget/chart/bar_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SaleReport(),
    );
  }
}

class SaleReport extends StatefulWidget {
  const SaleReport({super.key});

  @override
  State<SaleReport> createState() => _SaleReportState();
}

class _SaleReportState extends State<SaleReport> {
  late double maxWidth;

  String selectedTab = 'Bán hàng';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    bool isChange_tab = maxWidth > 900;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                children: [
                  TimeSelection()
                ],
              ),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;

                  if (maxWidth > 1200) {
                    return _buildKPIGrid(5);
                  } else if (maxWidth > 1000) {
                    return _buildKPIGrid(4, 1);
                  } else if (maxWidth > 800) {
                    return _buildKPIGrid(3, 2);
                  } else if (maxWidth > 600) {
                    return _buildKPIGrid(2, 2, 1);
                  } else {
                    return Container(
                      height: 495,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardWithSideColor('Doanh thu thuần', '21,080,000', Colors.blue),
                          const SizedBox(height: 10),
                          _buildCardWithSideColor('Đã thu', '21,135,000', Colors.cyan),
                          const SizedBox(height: 10),
                          _buildCardWithSideColor('Thực nhận', '21,135,000', Colors.pink),
                          const SizedBox(height: 10),
                          _buildCardWithSideColor('Đơn hàng', '9', Colors.purple),
                          const SizedBox(height: 10),
                          _buildCardWithSideColor('Sản phẩm', '9', Colors.red),
                        ],
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      if (maxWidth > 900) {
                        return Row(
                          children: [
                            Flexible(flex: 1, child: _buildTab('Bán hàng')),
                            const SizedBox(width: 15),
                            Flexible(flex: 1, child: _buildTab('Phương thức thanh toán')),
                            const SizedBox(width: 15),
                            Flexible(flex: 1, child: _buildTab('Đơn hàng và sản phẩm')),
                          ],
                        );
                      } else if (maxWidth > 700) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Flexible(flex: 1, child: _buildTab('Bán hàng')),
                                const SizedBox(width: 15),
                                Flexible(flex: 1, child: _buildTab('Phương thức thanh toán')),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildTab('Đơn hàng và sản phẩm'),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTab('Bán hàng'),
                            const SizedBox(height: 15),
                            _buildTab('Phương thức thanh toán'),
                            const SizedBox(height: 15),
                            _buildTab('Đơn hàng và sản phẩm'),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (selectedTab == 'Bán hàng')
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 500,
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

              if (selectedTab == 'Phương thức thanh toán')
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 500,
                    child: InteractivePieChart(),
                  ),
                ),


              if (selectedTab == 'Đơn hàng và sản phẩm')
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 500,
                    child: BarChartWidget(
                      orders: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120],
                      products: [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72],
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIGrid(int row1Count, [int? row2Count, int? row3Count]) {
    List<Widget> cards = [
      _buildCardWithSideColor('Doanh thu thuần', '21,080,000', Colors.blue),
      _buildCardWithSideColor('Đã thu', '21,135,000', Colors.cyan),
      _buildCardWithSideColor('Thực nhận', '21,135,000', Colors.pink),
      _buildCardWithSideColor('Đơn hàng', '9', Colors.purple),
      _buildCardWithSideColor('Sản phẩm', '9', Colors.red),
    ];

    List<Widget> rows = [];

    rows.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cards.take(row1Count).toList(),
    ));

    if (row2Count != null) {
      rows.add(
        const SizedBox(height: 10),
      );
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: cards.skip(row1Count).take(row2Count).toList(),
      ));
    }

    if (row3Count != null) {
      rows.add(
        const SizedBox(height: 10),
      );
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: cards.skip(row1Count + (row2Count ?? 0)).take(row3Count).toList(),
      ));
    }

    return Column(
      children: rows,
    );
  }

  Widget _buildCardWithSideColor(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 70,
              color: color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTab = title;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 32.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.titleColor),
          ),
        ],
      ),
    );
  }
}
