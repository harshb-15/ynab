import 'package:events_emitter/listener.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Make sure to import your PaymentDao, Payment, and other necessary model files correctly.

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  int touchedIndex = -1;
  // EventListener? _paymentEventListener;
  final PaymentDao _paymentDao = PaymentDao();
  List<PieChartSectionData> _pieChartSections = [];
  List<FlSpot> _lineChartSpots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    // _paymentEventListener = globalEvent.on("payment_update", (data) {
    //   debugPrint("payments are changed");

    //   setState(() {
    //     _loadData();
    //   });
    // });
  }

  void _loadData() async {
    // Fetch all payments - adjust according to your app's logic and data size
    List<Payment> payments = await _paymentDao.find();
    _generatePieChartData(payments);
    _generateLineChartData(payments);
  }

  void _generatePieChartData(List<Payment> payments) {
    // Aggregate payments by category
    final categoryTotals = <String, double>{};
    for (var payment in payments) {
      categoryTotals[payment.category.name] =
          (categoryTotals[payment.category] ?? 0) + payment.amount;
    }

    // Convert aggregates to chart data
    _pieChartSections =
        categoryTotals.entries.toList().asMap().entries.map((entry) {
      final isTouched = entry.key == touchedIndex;
      final fontSize = isTouched ? 18.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
        color: Colors.primaries[entry.key % Colors.primaries.length],
        value: entry.value.value,
        title: entry.value.key,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();

    setState(() {});
  }

  void _generateLineChartData(List<Payment> payments) {
    final now = DateTime.now();
    final lastYear = now.year;
    final monthlyTotals = List<double>.filled(12, 0);

    for (var payment in payments) {
      if (payment.datetime.year == lastYear) {
        monthlyTotals[payment.datetime.month - 1] +=
            payment.type == PaymentType.debit ? payment.amount : 0;
      }
    }

    _lineChartSpots = List.generate(
        12, (index) => FlSpot(index.toDouble() + 1, monthlyTotals[index]));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Financial Overview', style: TextStyle(color: Colors.white)),
        // backgroundColor: Colors.deepPurple, // Change the color of AppBar
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          // Use SingleChildScrollView to avoid overflow when keyboard appears
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Transaction Insights',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Heading color
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 2, // Reduced elevation for a lighter shadow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Adjusted border radius
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the content
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Transactions by Category',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 300, // Adjusted size of the pie chart container
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event,
                                  PieTouchResponse? response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            startDegreeOffset: 180,
                            sections: _pieChartSections.map((section) {
                              final isTouched =
                                  _pieChartSections.indexOf(section) ==
                                      touchedIndex;
                              final double fontSize = isTouched ? 16.0 : 14.0;
                              final double radius = isTouched ? 80.0 : 70.0;

                              return section.copyWith(
                                titlePositionPercentageOffset:
                                    1.5, // Adjust label position
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white, // Label text color changed to white
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Monthly Transactions (Previous Year)',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            200, // Adjust the size of the line chart container
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _lineChartSpots,
                                isCurved: true,
                                // colors: [Colors.blue],
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(show: true),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
