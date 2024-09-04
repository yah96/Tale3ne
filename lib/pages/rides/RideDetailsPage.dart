import 'package:flutter/material.dart';
import 'package:tale3ne/models/RideData.dart';
import 'package:tale3ne/services/RequestsServices.dart';
import 'package:tale3ne/services/RidesServices.dart';

class RideDetailsPage extends StatefulWidget {
  final RideData ride;
  final String userId;
  final String userName;

  RideDetailsPage({required this.ride, required this.userId, required this.userName});

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  final RidesService _ridesService = RidesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDetailsTable(),
          _buildJoinRequestButton(context, widget.ride),
        ],
      ),
    );
  }

  Widget _buildDetailsTable() {
    List<TableRow> rows = [
      _buildTableRow('Driver Name', widget.ride.driverName),
      _buildTableRow('Starting Position', widget.ride.startingPosition),
      _buildTableRow('Destination', widget.ride.destination),
      _buildTableRow('Date', widget.ride.date),
      _buildTableRow('Capacity', widget.ride.capacity.toString()),
    ];

    if (widget.userId == widget.ride.driverId) {
      for (var passenger in widget.ride.passengersList) {
        rows.add(_buildPassengerRow(passenger['passengerName']));
      }
    } else {
      rows.add(_buildTableRow('Passengers', widget.ride.passengersList.length.toString()));
    }

    return Table(
      children: rows,
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value, style: TextStyle(color: Colors.blue)),
          ),
        ),
      ],
    );
  }

  TableRow _buildPassengerRow(String passengerName) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Passengers: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ),
        TableCell(
          child: Row(
            children: [
              Expanded(
                child: Text(passengerName, style: TextStyle(color: Colors.blue)),
              ),
              if (widget.userId == widget.ride.driverId)
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    _removePassenger(passengerName);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinRequestButton(BuildContext context, RideData ride) {
    bool isSameDriver = (widget.userId == ride.driverId);
    bool isCapacityFull = (widget.ride.passengersList.length >= widget.ride.capacity);
    bool isLoading = false;

    return Visibility(
      visible: !isSameDriver,
      child: ElevatedButton(
        onPressed: (!isCapacityFull && !isLoading)
            ? () {
          setState(() {
            isLoading = true;
          });
          _sendJoinRequest(context, ride);
        }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Send Join Request', style: TextStyle(color: Colors.white)),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
        ),
      ),
    );
  }

  void _sendJoinRequest(BuildContext context, RideData ride) async {
    try {
      RequestsServices requestsServices = RequestsServices();
      Map<String, dynamic> requestData = {
        'driverId': ride.driverId,
        'passengerId': widget.userId,
        'passengerName': widget.userName,
        'rideId': ride.id,
      };

      Map<String, dynamic> response = await requestsServices.addRequest(requestData);

      if (response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Join request sent successfully!', style: TextStyle(color: Colors.green)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send join request. Please try again.', style: TextStyle(color: Colors.red)),
          ),
        );
      }
    } catch (error) {
      print('Error sending join request: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while sending join request. Please try again.', style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  void _removePassenger(String passengerName) {
    int passengerIndex = widget.ride.passengersList.indexWhere((passenger) => passenger['passengerName'] == passengerName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Passenger'),
          content: Text('Are you sure you want to remove $passengerName from the ride?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (passengerIndex != -1) {
                  removePassenger(widget.ride.passengersList[passengerIndex]);
                }
                Navigator.pop(context);
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void removePassenger(Map<String, dynamic> passengerData) async {
    try {
      bool success = await _ridesService.removePassenger(widget.ride.id, passengerData);
      String passengerName = passengerData['passengerName'];

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$passengerName removed from the ride successfully!', style: TextStyle(color: Colors.green)),
          ),
        );

        // Refresh the page after removing the passenger
        setState(() {
          widget.ride.passengersList.remove(passengerData);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove $passengerName from the ride.', style: TextStyle(color: Colors.red)),
          ),
        );
      }
    } catch (error) {
      print('Error removing passenger: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while removing the passenger. Please try again.', style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

}
