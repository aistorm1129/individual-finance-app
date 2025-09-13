import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class MonthlyTrendWidget extends StatelessWidget {
  final List<Expense> expenses;

  const MonthlyTrendWidget({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return _buildEmptyChart(context);
    }

    final monthlyData = _calculateMonthlyTotals();

    if (monthlyData.isEmpty) {
      return _buildEmptyChart(context);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Spending Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(monthlyData),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: _calculateInterval(monthlyData),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= monthlyData.length) {
                            return const Text('');
                          }
                          final month = monthlyData[index].month;
                          return Text(
                            DateFormat('MMM').format(DateTime(2023, month)),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.total);
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF6C63FF),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF6C63FF),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.white,
                      tooltipBorder: BorderSide(color: Colors.grey.shade300),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= monthlyData.length) {
                            return null;
                          }
                          final data = monthlyData[index];
                          return LineTooltipItem(
                            '${DateFormat('MMM yyyy').format(DateTime(data.year, data.month))}\n',
                            TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: NumberFormat.currency(symbol: '\$').format(data.total),
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendSummary(monthlyData),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Card(
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'No trend data available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSummary(List<MonthlyData> monthlyData) {
    if (monthlyData.length < 2) {
      return const SizedBox();
    }

    final current = monthlyData.last.total;
    final previous = monthlyData[monthlyData.length - 2].total;
    final change = current - previous;
    final percentChange = previous > 0 ? (change / previous * 100) : 0;

    final isIncrease = change > 0;
    final color = isIncrease ? Colors.red : Colors.green;
    final icon = isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isIncrease
                  ? 'Spending increased by ${percentChange.abs().toStringAsFixed(1)}% from last month'
                  : 'Spending decreased by ${percentChange.abs().toStringAsFixed(1)}% from last month',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${isIncrease ? '+' : ''}${NumberFormat.currency(symbol: '\$').format(change)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<MonthlyData> _calculateMonthlyTotals() {
    final monthlyTotals = <String, double>{};

    for (final expense in expenses) {
      final key = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + expense.amount;
    }

    final sortedKeys = monthlyTotals.keys.toList()..sort();

    return sortedKeys.map((key) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return MonthlyData(year: year, month: month, total: monthlyTotals[key]!);
    }).toList();
  }

  double _calculateInterval(List<MonthlyData> data) {
    if (data.isEmpty) return 1000;

    final maxValue = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);

    if (maxValue < 1000) return 200;
    if (maxValue < 5000) return 1000;
    if (maxValue < 10000) return 2000;
    return 5000;
  }
}

class MonthlyData {
  final int year;
  final int month;
  final double total;

  MonthlyData({
    required this.year,
    required this.month,
    required this.total,
  });
}