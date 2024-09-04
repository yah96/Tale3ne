import 'package:flutter/material.dart';
import 'package:tale3ne/services/RequestsServices.dart';
import 'package:tale3ne/services/RidesServices.dart';

class RequestsListPage extends StatefulWidget {
  final String driverId;
  final String driverName;

  const RequestsListPage({Key? key, required this.driverId, required this.driverName}) : super(key: key);

  @override
  _RequestsListPageState createState() => _RequestsListPageState();
}

class _RequestsListPageState extends State<RequestsListPage> {
  final RequestsServices _requestsServices = RequestsServices();
  final RidesService _ridesService = RidesService();
  late List<dynamic> requests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _requestsServices.findRequestsByDriverId(widget.driverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (snapshot.data is Map<String, dynamic>) {
              requests = snapshot.data?['requests'] as List<dynamic>;

              if (requests.isEmpty) {
                return Center(child: Text('No requests available.'));
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  String passengerName = requests[index]['passengerName'];
                  String passengerId = requests[index]['passengerId'];
                  String requestId = requests[index]['_id'];
                  String rideId = requests[index]['rideId'];

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.greenAccent,
                    child: ListTile(
                      title: Text(
                        'Passenger: $passengerName',
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'Passenger ID: $passengerId',
                        style: TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _acceptRequest(passengerId, passengerName, requestId, rideId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: Text(
                              'Approve',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _rejectRequest(passengerId, requestId, rideId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('Unexpected data type'));
            }
          }
        },
      ),
    );
  }

  Future<void> _acceptRequest(String passengerId,  String passengerName, String requestId, String rideId) async {
    try {
      await _requestsServices.removeRequest(passengerId,passengerName,widget.driverId, widget.driverName,rideId,  requestId, true);
      _showSnackbar(context, 'Request accepted successfully!');
      // Update the widget state after accepting the request
      setState(() {
        requests.removeWhere((request) => request['_id'] == requestId);
      });
    } catch (error) {
      print('Error accepting request: $error');
      _showSnackbar(context, 'Error accepting request: $error', isError: true);
    }
  }

  Future<void> _rejectRequest(String passengerId, String requestId,String rideId) async {
    try {
      await _requestsServices.removeRequest(passengerId,"","", widget.driverName,rideId ,requestId, false);
      _showSnackbar(context, 'Request rejected successfully!');

      setState(() {
        requests.removeWhere((request) => request['_id'] == requestId);
      });
    } catch (error) {
      print('Error rejecting request: $error');
      _showSnackbar(context, 'Error rejecting request: $error', isError: true);
    }
  }

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
