import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseChartWidget extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;

  const ExpenseChartWidget({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return _buildEmptyChart(context);
    }

    final categoryTotals = _calculateCategoryTotals();
    final total = categoryTotals.values.fold<double>(0, (sum, value) => sum + value);

    if (total == 0) {
      return _buildEmptyChart(context);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _createPieChartSections(categoryTotals, total),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(categoryTotals, total),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'No data to display',
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

  Map<String, double> _calculateCategoryTotals() {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.categoryId] = (totals[expense.categoryId] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<String, double> categoryTotals,
    double total,
  ) {
    final sections = <PieChartSectionData>[];
    var index = 0;

    for (final entry in categoryTotals.entries) {
      final category = categories.firstWhere(
        (cat) => cat.id == entry.key,
        orElse: () => categories.last, // Default to "Other"
      );

      final percentage = (entry.value / total) * 100;
      final isSmallSection = percentage < 5;

      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: isSmallSection ? '' : '${percentage.toStringAsFixed(1)}%',
          color: category.color,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    }

    return sections;
  }

  Widget _buildLegend(Map<String, double> categoryTotals, double total) {
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedEntries.take(6).map((entry) {
        final category = categories.firstWhere(
          (cat) => cat.id == entry.key,
          orElse: () => categories.last,
        );

        final percentage = (entry.value / total) * 100;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${category.icon} ${category.name}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}