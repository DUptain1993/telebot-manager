import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PerformanceAnalyticsWidget extends StatefulWidget {
  final Map<String, dynamic> analyticsData;

  const PerformanceAnalyticsWidget({
    super.key,
    required this.analyticsData,
  });

  @override
  State<PerformanceAnalyticsWidget> createState() =>
      _PerformanceAnalyticsWidgetState();
}

class _PerformanceAnalyticsWidgetState
    extends State<PerformanceAnalyticsWidget> {
  String _selectedTimeRange = '24h';
  final List<String> _timeRanges = ['1h', '6h', '24h', '7d', '30d'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(context, colorScheme),
              SizedBox(height: 3.h),
              _buildMetricsOverview(context, colorScheme),
              SizedBox(height: 3.h),
              _buildMessageThroughputChart(context, colorScheme),
              SizedBox(height: 3.h),
              _buildResponseTimeChart(context, colorScheme),
              SizedBox(height: 3.h),
              _buildErrorRateChart(context, colorScheme),
            ])));
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(children: [
      CustomIconWidget(
          iconName: 'analytics', color: colorScheme.primary, size: 24),
      SizedBox(width: 3.w),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Performance Analytics',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text('Bot performance metrics and insights',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6))),
      ])),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
              border:
                  Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: _selectedTimeRange,
                  items: _timeRanges
                      .map((range) =>
                          DropdownMenuItem(value: range, child: Text(range)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeRange = value;
                      });
                      HapticFeedback.lightImpact();
                    }
                  }))),
    ]);
  }

  Widget _buildMetricsOverview(BuildContext context, ColorScheme colorScheme) {
    final metrics = widget.analyticsData["metrics"] as Map<String, dynamic>;

    return Row(children: [
      Expanded(
          child: _buildMetricCard(
              context,
              colorScheme,
              'Messages',
              (metrics["totalMessages"] as int).toString(),
              'trending_up',
              '+12%',
              true)),
      SizedBox(width: 3.w),
      Expanded(
          child: _buildMetricCard(context, colorScheme, 'Avg Response',
              '${metrics["avgResponseTime"]}ms', 'speed', '-5%', true)),
      SizedBox(width: 3.w),
      Expanded(
          child: _buildMetricCard(context, colorScheme, 'Error Rate',
              '${metrics["errorRate"]}%', 'error_outline', '+2%', false)),
    ]);
  }

  Widget _buildMetricCard(
      BuildContext context,
      ColorScheme colorScheme,
      String title,
      String value,
      String iconName,
      String change,
      bool isPositive) {
    return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: colorScheme.outline.withValues(alpha: 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CustomIconWidget(
                iconName: iconName, color: colorScheme.primary, size: 16),
            const Spacer(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                    color: (isPositive
                            ? AppTheme.getStatusColor('success',
                                isLight: Theme.of(context).brightness ==
                                    Brightness.light)
                            : AppTheme.getStatusColor('error',
                                isLight: Theme.of(context).brightness ==
                                    Brightness.light))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(change,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPositive
                            ? AppTheme.getStatusColor('success',
                                isLight: Theme.of(context).brightness ==
                                    Brightness.light)
                            : AppTheme.getStatusColor('error',
                                isLight: Theme.of(context).brightness ==
                                    Brightness.light),
                        fontWeight: FontWeight.w500))),
          ]),
          SizedBox(height: 1.h),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6))),
        ]));
  }

  Widget _buildMessageThroughputChart(
      BuildContext context, ColorScheme colorScheme) {
    final chartData = widget.analyticsData["throughputData"] as List<dynamic>;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Message Throughput',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
        CustomIconWidget(
            iconName: 'info',
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 16),
      ]),
      SizedBox(height: 2.h),
      Container(
          height: 25.h,
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2))),
          child: Padding(
              padding: EdgeInsets.all(4.w),
              child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => FlLine(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                          strokeWidth: 1)),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 4,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}h',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6)));
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6)));
                              }))),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                        spots: (chartData).asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value as Map<String, dynamic>;
                          return FlSpot(index.toDouble(),
                              (data["messages"] as num).toDouble());
                        }).toList(),
                        isCurved: true,
                        color: colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.primary.withValues(alpha: 0.1))),
                  ],
                  lineTouchData: LineTouchData(touchTooltipData:
                      LineTouchTooltipData(getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                          '${spot.y.toInt()} messages',
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500));
                    }).toList();
                  })))))),
    ]);
  }

  Widget _buildResponseTimeChart(
      BuildContext context, ColorScheme colorScheme) {
    final responseData =
        widget.analyticsData["responseTimeData"] as List<dynamic>;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Response Time Distribution',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      SizedBox(height: 2.h),
      Container(
          height: 20.h,
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2))),
          child: Padding(
              padding: EdgeInsets.all(4.w),
              child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(touchTooltipData:
                      BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                        '${rod.toY.toInt()}ms',
                        Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500));
                  })),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final ranges = [
                                  '0-50ms',
                                  '50-100ms',
                                  '100-200ms',
                                  '200ms+'
                                ];
                                if (value.toInt() < ranges.length) {
                                  return Text(ranges[value.toInt()],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.6)));
                                }
                                return const Text('');
                              })),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      (responseData).asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value as Map<String, dynamic>;
                    return BarChartGroupData(x: index, barRods: [
                      BarChartRodData(
                          toY: (data["count"] as num).toDouble(),
                          color: colorScheme.primary,
                          width: 8.w,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4))),
                    ]);
                  }).toList(),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                          strokeWidth: 1)))))),
    ]);
  }

  Widget _buildErrorRateChart(BuildContext context, ColorScheme colorScheme) {
    final errorData = widget.analyticsData["errorData"] as List<dynamic>;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Error Rate Trend',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      SizedBox(height: 2.h),
      Container(
          height: 20.h,
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2))),
          child: Padding(
              padding: EdgeInsets.all(4.w),
              child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                          strokeWidth: 1)),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 2,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}h',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6)));
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6)));
                              }))),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                        spots: (errorData).asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value as Map<String, dynamic>;
                          return FlSpot(index.toDouble(),
                              (data["errorRate"] as num).toDouble());
                        }).toList(),
                        isCurved: true,
                        color: AppTheme.getStatusColor('error',
                            isLight: Theme.of(context).brightness ==
                                Brightness.light),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                    radius: 3,
                                    color: AppTheme.getStatusColor('error',
                                        isLight: Theme.of(context).brightness ==
                                            Brightness.light),
                                    strokeWidth: 2,
                                    strokeColor: colorScheme.surface)),
                        belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.getStatusColor('error',
                                    isLight: Theme.of(context).brightness ==
                                        Brightness.light)
                                .withValues(alpha: 0.1))),
                  ],
                  lineTouchData: LineTouchData(touchTooltipData:
                      LineTouchTooltipData(getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}% errors',
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500));
                    }).toList();
                  })))))),
    ]);
  }
}
