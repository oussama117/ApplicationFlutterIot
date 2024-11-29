import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/necklace_api_service.dart'; // Replace with the actual import for your service
import '../models/necklace_model.dart'; // Replace with the actual import for your data model

class SheepProfileScreen extends StatefulWidget {
  final String idNecklace;

  SheepProfileScreen({required this.idNecklace});

  @override
  _SheepProfileScreenState createState() => _SheepProfileScreenState();
}

class _SheepProfileScreenState extends State<SheepProfileScreen> {
  List<FlSpot> accelerationData = [];
  List<FlSpot> gyroscopeData = [];
  List<FlSpot> temperatureData = [];
  List<FlSpot> heartRateData = [];
  bool isLoading = true;
  String movementStatus = '';
  String temperatureStatus = '';
  String heartRateStatus = '';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdates() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final data = await NecklaceService.fetchNecklaceData(widget.idNecklace);
      final parsedData =
          data.map((item) => NecklaceDataPoint.fromJson(item)).toList();

      setState(() {
        accelerationData = parsedData
            .map((item) => FlSpot(item.time.toDouble(), item.acc))
            .toList();
        gyroscopeData = parsedData
            .map((item) => FlSpot(item.time.toDouble(), item.gyr))
            .toList();
        temperatureData = parsedData
            .map((item) => FlSpot(item.time.toDouble(), item.temp))
            .toList();
        heartRateData = parsedData
            .map((item) => FlSpot(item.time.toDouble(), item.pulse))
            .toList();

        movementStatus = _getMovementStatus(accelerationData, gyroscopeData);
        temperatureStatus = _getTemperatureStatus(temperatureData);
        heartRateStatus = _getHeartRateStatus(heartRateData);

        isLoading = false;
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getMovementStatus(List<FlSpot> accData, List<FlSpot> gyrData) {
    final avgAcc =
        accData.map((e) => e.y).reduce((a, b) => a + b) / accData.length;
    final avgGyr =
        gyrData.map((e) => e.y).reduce((a, b) => a + b) / gyrData.length;

    if (avgAcc <= 1 || avgGyr <= 1) return 'Pausing';
    if (avgAcc <= 3 || avgGyr <= 3) return 'Walking';
    return 'Running';
  }

  String _getTemperatureStatus(List<FlSpot> tempData) {
    final avgTemp =
        tempData.map((e) => e.y).reduce((a, b) => a + b) / tempData.length;
    if (avgTemp <= 26) return 'Low';
    if (avgTemp > 32) return 'High';
    return 'Normal';
  }

  String _getHeartRateStatus(List<FlSpot> pulseData) {
    final avgPulse =
        pulseData.map((e) => e.y).reduce((a, b) => a + b) / pulseData.length;
    if (avgPulse < 75) return 'Low';
    if (avgPulse > 95) return 'High';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sheep Profile: ${widget.idNecklace}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusCard('Movement Status', movementStatus),
                    _buildStatusCard('Temperature Status', temperatureStatus),
                    _buildStatusCard('Heart Rate Status', heartRateStatus),
                  ],
                ),
                _buildMovementChartCard(
                    'Movement', accelerationData, gyroscopeData),
                _buildChartCard('Temperature', temperatureData),
                _buildChartCard('Heart Rate', heartRateData),
              ],
            ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    Color statusColor = Colors.green; // Default color for 'Normal'

    // Check the status for heart rate and temperature and change color
    if (title == 'Heart Rate Status') {
      if (status == 'Low' || status == 'High') {
        statusColor = Colors.red;
      } else {
        statusColor = Colors.green;
      }
    } else if (title == 'Temperature Status') {
      if (status == 'Low' || status == 'High') {
        statusColor = Colors.red;
      } else {
        statusColor = Colors.green;
      }
    } else if (title == 'Movement Status') {
      // Movement status does not change color based on a specific value
      statusColor = Colors.black;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '$title: $status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMovementChartCard(
      String title, List<FlSpot> accData, List<FlSpot> gyrData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: accData.isNotEmpty ? accData.first.x : 0,
                  maxX: accData.isNotEmpty ? accData.last.x : 0,
                  minY: accData.isNotEmpty && gyrData.isNotEmpty
                      ? [...accData.map((e) => e.y), ...gyrData.map((e) => e.y)]
                          .reduce((a, b) => a < b ? a : b)
                      : 0,
                  maxY: accData.isNotEmpty && gyrData.isNotEmpty
                      ? [...accData.map((e) => e.y), ...gyrData.map((e) => e.y)]
                          .reduce((a, b) => a > b ? a : b)
                      : 0,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      spots: accData,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.green,
                      spots: gyrData,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
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

  Widget _buildChartCard(String title, List<FlSpot> data) {
    Color chartColor = Colors.orange;

    if (title == 'Heart Rate') {
      chartColor = Colors.orange;
    } else {
      chartColor = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: data.isNotEmpty ? data.first.x : 0,
                  maxX: data.isNotEmpty ? data.last.x : 0,
                  minY: data.isNotEmpty
                      ? data.map((e) => e.y).reduce((a, b) => a < b ? a : b)
                      : 0,
                  maxY: data.isNotEmpty
                      ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
                      : 0,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: chartColor,
                      spots: data,
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
}
