import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/transactions/presentation/bloc/transaction_bloc.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedMonthIndex = DateTime.now().month - 1;
  int _selectedYear = DateTime.now().year;
  
  final List<String> _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  @override
  void initState() {
    super.initState();
    _requestData();
  }

  void _requestData() {
    context.read<TransactionBloc>()
        .add(LoadMonthlyStatistics(_selectedYear, _selectedMonthIndex + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER GRAFIK
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 20, left: 16, right: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0BBE4), Color(0xFF957DAD)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Grafik Bulanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // TAB PEMILIHAN BULAN
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _months.asMap().entries.map((entry) {
                        final index = entry.key;
                        final name = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(name),
                            selected: _selectedMonthIndex == index,
                            selectedColor: AppTheme.primaryColor,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: _selectedMonthIndex == index ? Colors.white : Colors.black,
                              fontWeight: _selectedMonthIndex == index ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedMonthIndex = index);
                                _requestData();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // AREA GRAFIK
                  Expanded(
                    child: BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoaded) {
                          final data = state.monthlyStatistics;
                          
                          if (data == null || (data['income'] == 0 && data['expense'] == 0)) {
                            return _buildEmptyState();
                          }

                          return _MonthlyBarChart(
                            monthName: _months[_selectedMonthIndex],
                            income: (data['income'] as num).toDouble(),
                            expense: (data['expense'] as num).toDouble(),
                            savings: (data['savings'] as num).toDouble(),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LEGENDA WARNA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegend(Colors.blue, 'Income'),
                      _buildLegend(Colors.red, 'Outcome'),
                      _buildLegend(Colors.amber, 'Savings'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi di bulan ${_months[_selectedMonthIndex]}.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]);
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final String monthName;
  final double income;
  final double expense;
  final double savings;

  const _MonthlyBarChart({
    required this.monthName,
    required this.income,
    required this.expense,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    double maxValue = [income, expense, savings.abs()].reduce(math.max);
    double maxY = maxValue == 0 ? 10000 : maxValue * 1.3;
    double interval = maxY / 5;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: maxY,
        minY: 0,
        groupsSpace: 12,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              _rod(income, Colors.blue),
              _rod(expense, Colors.red),
              _rod(savings < 0 ? 0 : savings, Colors.amber),
            ],
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200], strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 45,
              getTitlesWidget: (v, meta) {
                if (v == 0) return const SizedBox.shrink();
                return Text(
                  v >= 1000000 ? "${(v / 1000000).toStringAsFixed(1)}M" : 
                  v >= 1000 ? "${(v / 1000).toStringAsFixed(0)}K" : v.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // DITAMBAH AGAR TULISAN TIDAK TERBENAM
              getTitlesWidget: (v, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10, // Jarak batang ke tulisan
                  child: Text(
                    "Total $monthName",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey[800],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = rodIndex == 0 ? 'Income' : rodIndex == 1 ? 'Outcome' : 'Savings';
              return BarTooltipItem(
                '$label\n${rod.toY.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  BarChartRodData _rod(double value, Color color) {
    return BarChartRodData(
      toY: value,
      width: 25,
      color: color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 0,
        color: Colors.grey[100],
      ),
    );
  }
}