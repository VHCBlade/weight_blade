import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/model/weight.dart';

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
    dateTime = DateTime.now();

    final bloc = context.readBloc<WeightEntryBloc>();
    weightUnit = bloc.loadedEntries.isEmpty
        ? WeightUnit.lbs
        : bloc.weightEntryMap[bloc.loadedEntries[0]]!.unit;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<WeightEntryBloc>();

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
                  clipData: FlClipData.all(),
                  minX: DateTime(dateTime.year, dateTime.month)
                      .microsecondsSinceEpoch
                      .toDouble(),
                  maxX: DateTime(dateTime.year, dateTime.month + 1)
                      .microsecondsSinceEpoch
                      .toDouble(),
                  minY: (bloc.weightEntryMap.values
                              .map((e) => e.weightInUnits(weightUnit))
                              .reduce((a, b) => a < b ? a : b) -
                          1)
                      .roundToDouble(),
                  maxY: (bloc.weightEntryMap.values
                              .map((e) => e.weightInUnits(weightUnit))
                              .reduce((a, b) => a > b ? a : b) +
                          2)
                      .roundToDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      drawBehindEverything: false,
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
                      drawBehindEverything: false,
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
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
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
                                final weightEntry = bloc.weightEntryMap.values
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
                    builder: (BuildContext context) => SizedBox(
                      height: 250,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: dateTime,
                        minimumYear: 1900,
                        maximumYear: DateTime.now().year,
                        onDateTimeChanged: (dateTime) {
                          setState(() => this.dateTime = dateTime);
                        },
                      ),
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
        .map((element) => bloc.weightEntryMap[element]!)
        .map((element) => FlSpot(
              element.dateTime.microsecondsSinceEpoch.toDouble(),
              element.weightInUnits(weightUnit),
            ))
        .toList();
  }
}
