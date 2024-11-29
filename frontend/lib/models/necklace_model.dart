class NecklaceDataPoint {
  final int time;
  final double acc;
  final double gyr;
  final double temp;
  final double pulse;

  NecklaceDataPoint({
    required this.time,
    required this.acc,
    required this.gyr,
    required this.temp,
    required this.pulse,
  });

  factory NecklaceDataPoint.fromJson(Map<String, dynamic> json) {
    return NecklaceDataPoint(
      time: json['time'],
      acc: json['acc'],
      gyr: json['gyr'],
      temp: json['temp'],
      pulse: json['pulse'],
    );
  }
}
