import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng2;
import 'package:geolocator/geolocator.dart';
import 'package:tale3ne/services/user_service.dart'; // Replace with the actual file path
import 'package:tale3ne/pages/chat/ChatScreen.dart';
import 'dart:async';

class LocationMap extends StatefulWidget {
  final String userId;
  final String userName;
  LocationMap({
    required this.userId,
    required this.userName,
  });

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  latLng2.LatLng? _userLocation;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userLocations = [];
  late Timer _timer;
  late UserService _userService; // Assuming you have a UserService class

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _initializeData();
    _startPeriodicUpdates();
  }
  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _getUserLocation(),
        _getAllUserLocations(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print("Error initializing data: $error");
      // Handle error if data initialization fails
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Location retrieved successfully");

      setState(() {
        _userLocation = latLng2.LatLng(position.latitude, position.longitude);
      });
      _userService.updateLocation(widget.userId, position.latitude.toString(), position.longitude.toString());
    } catch (e) {
      print("Error getting user location: $e");
      // Handle error if location retrieval fails
    }
  }
  Future<void> _getAllUserLocations() async {
    try {
      await _userService.getAllUserLocations();

      setState(() {
        _userLocations = _userService.userLocations ?? [];
      });
    } catch (error) {
      print("Error getting all user locations: $error");
    }
  }
  void _startPeriodicUpdates() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _getUserLocation();
      _getAllUserLocations();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : _buildMap(),
        ],
      ),
    );
  }
  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: _userLocation ?? latLng2.LatLng(0, 0),
        zoom: 15.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
          markers: _userLocations
              .map(
                (location) => Marker(
              width: 80.0,
              height: 80.0,
                  point: latLng2.LatLng(
                    (location['location']['latitude'] is String)
                        ? double.parse(location['location']['latitude'])
                        : location['location']['latitude'] as double,
                    (location['location']['longitude'] is String)
                        ? double.parse(location['location']['longitude'])
                        : location['location']['longitude'] as double,
                  ),              builder: (ctx) => GestureDetector(
                onTap: () {
                    _showUserCoords(context, location);
                },
                child: Icon(
                  Icons.location_on,
                  color: location['ID'] == widget.userId ? Colors.red : Colors.blue,
                  size: 50.0,
                ),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  void _showUserCoords(BuildContext context, Map<String, dynamic> userLocation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${userLocation['firstname']} ${userLocation['lastname']}'),
          content: Text(
              'Latitude: ${userLocation['location']['latitude']}\nLongitude: ${userLocation['location']['longitude']}'),
          actions: [
            if (userLocation['ID'] != widget.userId)
              ElevatedButton(
                onPressed: () {
                  _startChat(userLocation['ID'],userLocation['firstname']+userLocation['lastname']);
                },
                child: Text('Chat'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
  void _startChat(String userId, String name) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userId: widget.userId,
          userName: widget.userName,
          otherUserId: userId,
          otherUserName: name,
        ),
      ),
    );
  }
}
