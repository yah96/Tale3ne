import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tale3ne/services/RidesServices.dart';
import 'package:tale3ne/models/RideData.dart';

class AddRides extends StatefulWidget {
  final String userId;
  final String userName;

  AddRides({required this.userId, required this.userName});

  @override
  _AddRidesState createState() => _AddRidesState(userId: userId, userName: userName);
}

class _AddRidesState extends State<AddRides> {
  final _formKey = GlobalKey<FormState>();
  final _ridesService = RidesService();
  final _rideData = RideData(
    date: '',
    riderId: '',
    driverId: '',
    driverName: '',
    destination: '',
    startingPosition: '',
    capacity: 0,
    rideCompleted: false,
    status: '',
    passengersList: [],
    id: '',
  );
  final String userId;
  final String userName;

  _AddRidesState({required this.userId, required this.userName});

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Ride'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _selectDateTime(context);
                },
                child: Text(
                  'Select Date and Time',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                ),
              ),
              if (selectedDate != null && selectedTime != null)
                Text(
                  'Selected Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute))}',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Starting Position',
                  labelStyle: TextStyle(color: Colors.green),
                ),
                onSaved: (value) {
                  _rideData.startingPosition = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'End Position',
                  labelStyle: TextStyle(color: Colors.green),
                ),
                onSaved: (value) {
                  _rideData.destination = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Passenger Capacity',
                  labelStyle: TextStyle(color: Colors.green),
                ),
                onSaved: (value) {
                  _rideData.capacity = int.tryParse(value ?? '') ?? 0;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (selectedDate != null && selectedTime != null) {
                      _rideData.date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute));
                    }
                    _rideData.driverId = userId;
                    _rideData.driverName = userName;

                    _ridesService.addRide(_rideData).then((result) {
                      if (result) {
                        // Show a success SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ride added successfully!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Reset the form and selected date/time
                        _formKey.currentState!.reset();
                        setState(() {
                          selectedDate = null;
                          selectedTime = null;
                        });

                        // Optionally, you can navigate back to a different screen or perform other actions
                      } else {
                        // Show an error SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add the ride. Please try again.'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  }
                },
                child: Text(
                  'Add Ride',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ));

    final TimeOfDay? pickedTime = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ));

    if (pickedDate != null && pickedTime != null) {
      setState(() {
        selectedDate = pickedDate;
        selectedTime = pickedTime;
      });
    }
  }
}
