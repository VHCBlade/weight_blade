import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';
import 'package:weight_blade/ui/graph/month_picker.dart';

final dateFormat = DateFormat.yMMMM();
final tooltipDateFormat = DateFormat.MMMMd();

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late DateTime dateTime;
  late WeightUnit weightUnit;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateTime = DateTime(now.year, now.month);

    final bloc = context.readBloc<WeightEntryBloc>();
    weightUnit = bloc.loadedEntries.isEmpty
        ? WeightUnit.lbs
        : bloc.weightEntryMap.map[bloc.loadedEntries[0]]!.unit;
  }

  void updateMonth(DateTime dateTime) {
    context.fireEvent(WeightEvent.ensureDateTimeIsShown.event, dateTime);
    setState(() => this.dateTime = DateTime(dateTime.year, dateTime.month));
  }

  bool withinTimeRange(WeightEntry entry) =>
      dateTime.isBefore(entry.dateTime) &&
      DateTime(dateTime.year, dateTime.month + 1).isAfter(entry.dateTime);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<WeightEntryBloc>();
    final includedEntries = bloc.weightEntryMap.map.values
        .where(withinTimeRange)
        .map((e) => e.weightInUnits(weightUnit));

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Graph - ${dateFormat.format(dateTime)} - ${weightUnit.name}"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (bloc.loadedEntries.isEmpty)
            Expanded(
                child: Text("No Weight Entries Yet! Add One First!",
                    style: Theme.of(context).textTheme.displaySmall)),
          if (bloc.loadedEntries.isNotEmpty)
            Expanded(
              child: LineChart(
                LineChartData(
                  clipData: const FlClipData.all(),
                  minX: DateTime(dateTime.year, dateTime.month)
                      .microsecondsSinceEpoch
                      .toDouble(),
                  maxX: DateTime(dateTime.year, dateTime.month + 1)
                      .microsecondsSinceEpoch
                      .toDouble(),
                  minY: (includedEntries.isEmpty
                          ? bloc.weightEntryMap.map[bloc.loadedEntries[0]]!
                                  .weightInUnits(weightUnit) -
                              1
                          : includedEntries.reduce((a, b) => a < b ? a : b) - 1)
                      .roundToDouble(),
                  maxY: (includedEntries.isEmpty
                          ? bloc.weightEntryMap.map[bloc.loadedEntries[0]]!
                                  .weightInUnits(weightUnit) +
                              2
                          : includedEntries.reduce((a, b) => a > b ? a : b) + 2)
                      .roundToDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) => ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(meta.formattedValue,
                                style: TextStyle(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor)),
                          ),
                        ),
                        showTitles: true,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) => ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                                "${DateTime.fromMicrosecondsSinceEpoch(value.toInt()).day == 1 ? "" : DateTime.fromMicrosecondsSinceEpoch(value.toInt()).day}",
                                style: TextStyle(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor)),
                          ),
                        ),
                        showTitles: true,
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (list) => list.map((val) {
                                final weightEntry = bloc
                                    .weightEntryMap.map.values
                                    .firstWhere((element) =>
                                        element
                                            .dateTime.microsecondsSinceEpoch ==
                                        val.x);
                                final tooltip =
                                    "${(val.y * 10).round() / 10} ${weightUnit.name}\n"
                                    "${tooltipDateFormat.format(weightEntry.dateTime)}";
                                return LineTooltipItem(
                                    weightEntry.note.isEmpty
                                        ? tooltip
                                        : "$tooltip\n${weightEntry.note}",
                                    const TextStyle());
                              }).toList())),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getSpots(bloc),
                      color: Theme.of(context).primaryColor,
                      isCurved: false,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          color: Theme.of(context).primaryColor,
                          radius: 5,
                          strokeWidth: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => weightUnit =
                      weightUnit == WeightUnit.kg
                          ? WeightUnit.lbs
                          : WeightUnit.kg),
                  child: const Text("Swap Unit"),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => MonthPicker(
                      initialDateTime: dateTime,
                      onDateTimeChanged: updateMonth,
                    ),
                  ),
                  child: const Text("Change Month"),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<FlSpot> getSpots(WeightEntryBloc bloc) {
    return bloc.loadedEntries
        .map((element) => bloc.weightEntryMap.map[element]!)
        .map((element) => FlSpot(
              element.dateTime.microsecondsSinceEpoch.toDouble(),
              element.weightInUnits(weightUnit),
            ))
        .toList();
  }
}
