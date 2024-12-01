import 'dart:async';
// import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/necklace_api_service.dart'; // Replace with the actual import for your service
import '../models/necklace_model.dart'; // Replace with the actual import for your data model
import '../models/sheep_model.dart';
import '../helpers/notification_helper.dart';

class SheepProfileScreen extends StatefulWidget {
  final String idNecklace;
  final Sheep sheep;

  SheepProfileScreen({required this.idNecklace, required this.sheep});

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
  String generalStatus = '';

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

        // Update statuses
        movementStatus = _getMovementStatus(accelerationData, gyroscopeData);
        temperatureStatus = _getTemperatureStatus(temperatureData);
        heartRateStatus = _getHeartRateStatus(heartRateData);
        generalStatus = _getGeneralStatus(
            temperatureStatus, heartRateStatus, movementStatus);

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
    if (accData.isEmpty || gyrData.isEmpty) return 'No Data';

    final avgAcc =
        accData.map((e) => e.y).reduce((a, b) => a + b) / accData.length;
    final avgGyr =
        gyrData.map((e) => e.y).reduce((a, b) => a + b) / gyrData.length;

    if (avgAcc <= 1 || avgGyr <= 1) return 'Pausing';
    if (avgAcc <= 3 || avgGyr <= 3) return 'Walking';
    return 'Running';
  }

  String _getTemperatureStatus(List<FlSpot> tempData) {
    if (tempData.isEmpty) return 'No Data';

    final avgTemp =
        tempData.map((e) => e.y).reduce((a, b) => a + b) / tempData.length;
    if (avgTemp <= 26) return 'Low';
    if (avgTemp > 32) return 'High';
    return 'Normal';
  }

  String _getHeartRateStatus(List<FlSpot> pulseData) {
    if (pulseData.isEmpty) return 'No Data';

    final avgPulse =
        pulseData.map((e) => e.y).reduce((a, b) => a + b) / pulseData.length;
    if (avgPulse < 75) return 'Low';
    if (avgPulse > 95) return 'High';
    return 'Normal';
  }

  String _getGeneralStatus(
      String tempStatus, String pulseStatus, String movementStatus) {
    if (tempStatus == 'Low' || pulseStatus == 'Low') {
      return 'Sheep is Sick';
    } else if (pulseStatus == 'High' && movementStatus == 'Running') {
      return 'Sheep is Running';
    } else if (movementStatus == 'Pausing' &&
        (tempStatus == 'High' ||
            tempStatus == 'Low' ||
            pulseStatus == 'High' ||
            pulseStatus == 'Low')) {
      showNotification(
        'Health Alert',
        'A sheep is showing signs of being unwell. Please check its health!',
      );

      return 'Sheep is Unwell';
    } else if (tempStatus == 'Normal' &&
        pulseStatus == 'Normal' &&
        movementStatus == 'Running') {
      return 'Sheep is Well';
    } else {
      return 'Status Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Sheep Profile: ${widget.idNecklace}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Combined status card
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sheep General Status",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.orange),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sheep ID',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.id,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Sheep necklace ID',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.necklaceID,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Sheep age',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.age,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Sheep Race',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.race,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sheep Weight',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.weight,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Sheep Vaccination',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.vaccinated
                                          ? 'Vaccinated'
                                          : 'Not Vaccinated',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Sheep general health',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      widget.sheep.healthStatus,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'General Present Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      generalStatus,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Movement Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      movementStatus,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(movementStatus),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Temperature Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      temperatureStatus,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _getStatusColor(temperatureStatus),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Text(
                                      'Heart Rate Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(226, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      heartRateStatus,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(heartRateStatus),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Sheep Chart Presentation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMovementChartCard(
                    'Movement', accelerationData, gyroscopeData),
                _buildChartCard('Temperature', temperatureData),
                _buildChartCard('Heart Rate', heartRateData),
              ],
            ),
    );
  }

  // Helper function to get the color for each status
  Color _getStatusColor(String status) {
    if (status == 'Low' || status == 'High') {
      return Colors.red;
    } else if (status == 'Normal' || status == 'Running') {
      return Colors.green;
    }
    return Colors.black;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'acceleration: ${accData.last.y}, gyroscope: ${gyrData.last.y}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Row(
                  children: [
                    Card(
                      color: Colors.blue,
                      child: SizedBox(
                        width: 30,
                        height: 10,
                      ),
                    ),
                    Text('Acceleration'),
                    SizedBox(
                      width: 10,
                    ),
                    Card(
                      color: Colors.green,
                      child: SizedBox(
                        width: 30,
                        height: 10,
                      ),
                    ),
                    Text('Gyroscope'),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
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
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: accData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                    ),
                    LineChartBarData(
                      spots: gyrData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
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
    Color lineColor;
    if (title == 'Heart Rate') {
      lineColor = Colors.orange;
    } else {
      lineColor = Colors.purple;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  title == 'Heart Rate'
                      ? '${data.last.y} Bpm'
                      : '${data.last.y} °C',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Card(
                      color: lineColor,
                      child: const SizedBox(
                        width: 30,
                        height: 10,
                      ),
                    ),
                    Text(title),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
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
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 2,
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
