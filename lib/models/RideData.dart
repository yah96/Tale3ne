import 'package:intl/intl.dart';

class RideData {
  String id;
  String date;
  String riderId;
  String driverId;
  String driverName;
  String destination;
  String startingPosition;
  int capacity;
  bool rideCompleted;
  String status;
  List<dynamic> passengersList = [];
  RideData({
    required this.date,
    required this.riderId,
    required this.driverId,
    required this.driverName,
    required this.destination,
    required this.startingPosition,
    required this.capacity,
    required this.rideCompleted,
    required this.status,
    required this.passengersList,
    required this.id,
  });
  String getStartingPosition(){
    return startingPosition;
  }
  factory RideData.fromJson(Map<String, dynamic> json) {
    var date = json['date'];
    if (date is int) {
      // Handle timestamp
      final dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      date = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    }
    List<dynamic> passengersList = [];
    final dynamic passengersJson = json['passengers'];
    if (passengersJson != null) {
      if (passengersJson is List) {
        // If passengersJson is already a list, use it directly
        passengersList = List<dynamic>.from(passengersJson);
      } else if (passengersJson is Map<String, dynamic>) {
        // If passengersJson is a map, extract the passengers list from it
        passengersList = passengersJson['passengers'] ?? [];
      }
    }
    return RideData(
      date: date,
      riderId: json['riderId'],
      driverName: json['driverName'],
      driverId: json['driverId'],
      destination: json['destination'],
      startingPosition: json['startingPosition'],
      capacity: json['capacity'],
      rideCompleted: json['rideCompleted'],
      status: json['status'],
      id: json['_id'],
      passengersList: passengersList,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'riderId': riderId,
      'driverId': driverId,
      'driverName': driverName,
      'destination': destination,
      'startingPosition': startingPosition,
      'capacity': capacity,
      'rideCompleted': rideCompleted,
      'status': status,
      'passengers': passengersList,
    };
  }
}
