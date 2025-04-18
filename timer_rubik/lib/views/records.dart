import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_rubik/providers/times_providers.dart';

/// Widget que muestra estadísticas rápidas como el último tiempo registrado,
/// el mejor tiempo personal (PB) y promedios como Ao5, Ao12, etc.
class RecordsTimes extends StatelessWidget {
  const RecordsTimes({super.key});

  /// Retorna el último tiempo registrado.
  String getCurrentTime(List<Map<String, dynamic>> times) {
    if (times.isEmpty) {
      return '';
    }
    return times.last['time'].toString();
  }

  /// Calcula y retorna el mejor tiempo personal (PB).
  double? getPB(List<Map<String, dynamic>> times) {
    List<double> sortedTimes = times
        .map((t) => double.tryParse(t['time'].toString()) ?? double.infinity)
        .toList()
      ..sort();

    return sortedTimes.isNotEmpty ? sortedTimes.first : null;
  }

  /// Calcula el promedio de los últimos 'howMany' tiempos,
  /// ignorando el mejor y el peor (estilo WCA).
  String getPBao(int howMany, List<Map<String, dynamic>> times) {
    if (times.length < howMany) {
      return "--";
    }

    List<double> lastTimes = times
        .take(howMany)
        .map((t) => double.tryParse(t['time'].toString()) ?? double.nan)
        .toList();

    lastTimes.removeWhere((t) => t.isNaN);

    lastTimes.sort();
    if (lastTimes.length > 2) {
      lastTimes = lastTimes.sublist(1, lastTimes.length - 1);
    }

    double average = lastTimes.reduce((a, b) => a + b) / lastTimes.length;

    return average.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final times = Provider.of<TimesProvider>(context).times;

    return Container(
      color: Colors.transparent,
      height: 100,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text("LastTime: ${getCurrentTime(times)}"),
              Text("PB: ${getPB(times)?.toStringAsFixed(2) ?? '--'}"),
              Text("Ao5: ${getPBao(5, times)}"),
            ],
          ),
          Column(
            children: [
              Text("Ao12: ${getPBao(12, times)}"),
              Text("Ao50: ${getPBao(50, times)}"),
              Text("Ao100: ${getPBao(100, times)}")
            ],
          )
        ],
      ),
    );
  }
}
