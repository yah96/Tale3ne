import 'package:flutter/material.dart';
import 'package:tale3ne/pages/Main/RequestsListPage.dart';
import 'package:tale3ne/pages/rides/RidesTable.dart';
import 'package:tale3ne/pages/rides/AddRide.dart';
import 'package:tale3ne/services/RidesServices.dart';
import 'package:tale3ne/models/RideData.dart';

class HomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String ID;

  HomePage({
    required this.firstName,
    required this.lastName,
    required this.ID,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RidesService ridesService = RidesService();
  List<RideData> rideDataList = [];

  @override
  void initState() {
    super.initState();
  }

  void _handleSeeRidesButtonPress(BuildContext context) async {
    try {
      final rides = await ridesService.fetchRideData();
      setState(() {
        rideDataList = rides;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RidesTable(
            rideDataList: rideDataList,
            userId: widget.ID,
            userName: (widget.firstName + " " + widget.lastName),
          ),
        ),
      );
    } catch (e) {
      if (e is EmptyRideDataListException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print('Failed to fetch ride data: $e');
      }
    }
  }

  void _handleAddRideButtonPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRides(
          userId: widget.ID,
          userName: "${widget.firstName} ${widget.lastName}",
        ),
      ),
    );
  }
  void _handleSeeRequestsButtonPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestsListPage(driverId: widget.ID,driverName: widget.firstName + " " + widget.lastName),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Semantics(
                label: 'User Name',
                child: Text(
                  '${widget.firstName} ${widget.lastName}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Semantics(
                label: 'User ID',
                child: Text(
                  'ID: ${widget.ID}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        _handleSeeRidesButtonPress(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Semantics(
                        label: 'See Rides',
                        child: Text('See Rides'),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        _handleAddRideButtonPress(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Semantics(
                        label: 'Add a Ride',
                        child: Text('Add a Ride'),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        _handleSeeRequestsButtonPress(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Semantics(
                        label: 'See Requests',
                        child: Text('See Requests'),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}
