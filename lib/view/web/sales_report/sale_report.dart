import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_model/report_model.dart';

import 'package:dacntt1_mobile_store/shared/core/pick_date/pick_date.dart';

import 'widget/chart/line_chart.dart';
import 'widget/chart/pie_chart.dart';
import 'widget/chart/bar_chart.dart';

class SaleReport extends StatefulWidget {
  const SaleReport({super.key});

  @override
  State<SaleReport> createState() => _SaleReportState();
}

class _SaleReportState extends State<SaleReport> {
  late double maxWidth;

  String selectedTab = 'Bán hàng';

  List<FlSpot> scaleFlSpots(List<FlSpot> spots, double scaleFactor) {
    return spots.map((spot) => FlSpot(spot.x, spot.y / scaleFactor)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);

    if (reportModel.listOrdersStore.isEmpty) {
      reportModel.fetchOrdersStore().then((_) {
        reportModel.fetchProducts();
      }).catchError((error) {
        if (kDebugMode) {
          print("Error fetching orders: $error");
        }
      });
    }

    //line chart
    double scaleFactor = reportModel.getMaxY() > 1000000 ? 1000000 : (reportModel.getMaxY() > 1000 ? 1000 : 1);


    //bar chart
    Map<String, List<int>> ordersAndProducts = reportModel.getOrdersAndProductsByHour();

    List<int> ordersBarChart = ordersAndProducts['orders']!;
    List<int> productsBarChart = ordersAndProducts['products']!;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                children: [TimeSelection()],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  return _buildKPIGrid(
                    row1Count: maxWidth > 1200
                        ? 5
                        : (maxWidth > 1000
                            ? 4
                            : (maxWidth > 800 ? 3 : (maxWidth > 600 ? 2 : 1))),
                    netRevenue: reportModel.formatCurrencyDouble(reportModel.netRevenue),
                    totalReceived: reportModel.formatCurrencyDouble(reportModel.totalReceived),
                    actualRevenue: reportModel.formatCurrencyDouble(reportModel.actualRevenue),
                    totalOrders: reportModel.formatCurrencyInt(reportModel.totalOrders),
                    totalProducts: reportModel.formatCurrencyInt(reportModel.totalProducts),
                  );
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      if (maxWidth > 900) {
                        return Row(
                          children: [
                            Flexible(flex: 1, child: _buildTab('Bán hàng')),
                            const SizedBox(width: 15),
                            Flexible(
                                flex: 1,
                                child: _buildTab('Phương thức thanh toán')),
                            const SizedBox(width: 15),
                            Flexible(
                                flex: 1,
                                child: _buildTab('Đơn hàng và sản phẩm')),
                          ],
                        );
                      } else if (maxWidth > 700) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Flexible(flex: 1, child: _buildTab('Bán hàng')),
                                const SizedBox(width: 15),
                                Flexible(
                                    flex: 1,
                                    child: _buildTab('Phương thức thanh toán')),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    height: 500,
                    child:  BarLineChart(
                      netRevenue: scaleFlSpots(reportModel.getNetRevenueSpots(), scaleFactor),
                      collected: scaleFlSpots(reportModel.getCollectedSpots(), scaleFactor),
                      actualReceived: scaleFlSpots(reportModel.getActualReceivedSpots(), scaleFactor),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    height: 500,
                    child: InteractivePieChart(
                        data: reportModel.getPaymentMethodData(),
                    ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    height: 500,
                    child: BarChartWidget(
                      orders: ordersBarChart,
                      products: productsBarChart,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIGrid({
    required int row1Count,
    required String netRevenue,
    required String totalReceived,
    required String actualRevenue,
    required String totalOrders,
    required String totalProducts,
  }) {
    List<Widget> cards = [
      _buildCardWithSideColor('Doanh thu thuần', netRevenue, Colors.blue),
      _buildCardWithSideColor('Đã thu', totalReceived, Colors.cyan),
      _buildCardWithSideColor('Thực nhận', actualRevenue, Colors.pink),
      _buildCardWithSideColor('Đơn hàng', totalOrders, Colors.purple),
      _buildCardWithSideColor('Sản phẩm', totalProducts, Colors.red),
    ];

    return Wrap(
      spacing: 10, // Khoảng cách giữa các card
      runSpacing: 10, // Khoảng cách giữa các dòng khi xuống dòng
      alignment: WrapAlignment.start,
      children: cards,
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
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.titleColor),
          ),
        ],
      ),
    );
  }
}
