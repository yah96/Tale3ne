import 'package:flutter/material.dart';
import 'package:tale3ne/pages/rides/RideDetailsPage.dart';
import 'package:tale3ne/models/RideData.dart';
import 'package:tale3ne/pages/chat/ChatScreen.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:tale3ne/services/RidesServices.dart';

class RidesTable extends StatefulWidget {
  final List<RideData> rideDataList;
  final String userId;
  final String userName;

  RidesTable({
    required this.rideDataList,
    required this.userId,
    required this.userName,
  });

  @override
  _RidesTableState createState() => _RidesTableState();
}

class _RidesTableState extends State<RidesTable> {
  int? _selectedRowIndex;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  TextEditingController _searchController = TextEditingController();
  List<RideData> filteredRideDataList = [];
  Offset? _longPressPosition;
  TextStyle sharpTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w900, // Adjust the font weight
    letterSpacing: 0.5, // Add letter spacing for clarity
    // fontFamily: 'YourCustomFont', // If you have a custom font
  );
  @override
  void initState() {
    super.initState();
    filteredRideDataList = widget.rideDataList;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                labelText: 'Search by Starting Position',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Customized Header
                  Container(
                    color: Colors.black,
                    child: Row(
                      children: buildHeaders(),
                    ),
                  ),
                  ...buildRows(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildHeaders() {
    return [
      buildHeader('Date', 0),
      buildHeader('Starting Position', 1),
      buildHeader('End Position', 2),
    ];
  }
  Widget buildHeader(String text, int columnIndex) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            _sort(columnIndex);
          },
          child: Text(
            text,
            style: sharpTextStyle,
          ),
        ),
      ),
    );
  }
  List<Widget> buildRows() {
    return filteredRideDataList.map((ride) {
      final rowIndex = filteredRideDataList.indexOf(ride);
      final isEvenRow = rowIndex % 2 == 0;
      final backgroundColor = isEvenRow ? Colors.grey[300] : Colors.grey[400];
      final isDriverIdMatched = _isDriverIdMatched(ride);

      return GestureDetector(
        onLongPressStart: (details) {
          _showPopupMenu(context,ride, details.globalPosition);
        },

        child: Container(
          color: isDriverIdMatched ? Colors.green : backgroundColor,
          child: Row(
            children: buildCells(ride),
          ),
        ),
      );
    }).toList();
  }
  List<Widget> buildCells(RideData ride) {
      return [
        buildCell(ride.date),
        buildCell(ride.startingPosition),
        buildCell(ride.destination),
      ];
    }
  Widget buildCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _contactRider(RideData ride) {
    print(ride.driverId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userId: widget.userId,
          userName: widget.userName,
          otherUserId: ride.driverId,
          otherUserName: ride.driverName,
        ),
      ),
    );
  }
  void _performSearch(String searchQuery) {
    setState(() {
      filteredRideDataList = fuzzySearch(widget.rideDataList, searchQuery) as List<RideData>;
      _selectedRowIndex = _selectedRowIndex != null && _selectedRowIndex! < filteredRideDataList.length
          ? _selectedRowIndex
          : null;
    });
  }
  List<RideData> fuzzySearch(List<RideData> rideDataList, String searchTerm) {
    final rideDataMap = {for (var rideData in rideDataList) rideData.startingPosition: rideData};
    final tokens = rideDataList.map((e) => [e.startingPosition]).toList();

    final fuse = Fuzzy(
      rideDataMap.values.toList(),
      options: FuzzyOptions(
        keys: [WeightedKey(name: 'startingPosition', getter: (dynamic obj) => (obj as RideData).startingPosition, weight: 1)],
        findAllMatches: true,
        tokenize: true,
        isCaseSensitive: false,
        threshold: 0.5,
        verbose: false,
        shouldSort: true,
      ),
    );
    final result = fuse.search(searchTerm);
    final matchedRideData = result
        .map((r) => r.item)
        .where((item) => item is RideData && rideDataMap.containsKey(item.startingPosition))
        .map((item) => rideDataMap[item.startingPosition]!)
        .toList();
    return matchedRideData;
  }
  bool _isDriverIdMatched(RideData ride) {
    return ride.driverId == widget.userId;
  }
  void _showPopupMenu(BuildContext context, RideData ride, Offset longPressPosition) async {
    final isDriverIdMatched = _isDriverIdMatched(ride);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        longPressPosition.dx,
        longPressPosition.dy,
        MediaQuery.of(context).size.width - longPressPosition.dx,
        MediaQuery.of(context).size.height - longPressPosition.dy,
      ),
      items: isDriverIdMatched
          ? [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
        PopupMenuItem<String>(
          value: 'details',
          child: Text('Details'),
        ),
      ]
          : [
        PopupMenuItem<String>(
          value: 'chat',
          child: Text('Chat'),
        ),
        PopupMenuItem<String>(
          value: 'details',
          child: Text('Details'),
        ),
      ],
    ).then((value) {
      if (value == 'chat') {
        _contactRider(ride);
      } else if (value == 'delete' && isDriverIdMatched) {
        _deleteRide(ride);
      } else if (value == 'details') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailsPage(
              ride: ride,
              userId: widget.userId,
              userName: widget.userName,
            ),
          ),
        ).then((refreshPage) {
          if (refreshPage == true) {
            // Refresh the page here (e.g., by calling a function to reload data)
            // For example, you can call a function to reload ride details.
            // reloadRideDetails();
          }
        });
      }
    });
  }
  void _deleteRide(RideData ride) async {
    try {
      RidesService ridesService = RidesService();
      await ridesService.deleteRide(ride.id);

      setState(() {
        widget.rideDataList.remove(ride);
        filteredRideDataList.remove(ride);
        _selectedRowIndex = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting ride: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete ride'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  void _sort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }

      switch (columnIndex) {
        case 0:
          filteredRideDataList.sort((a, b) => _compareStrings(a.date, b.date));
          break;
        case 1:
          filteredRideDataList.sort((a, b) => _compareStrings(a.driverName, b.driverName));
          break;
        case 2:
          filteredRideDataList.sort((a, b) => _compareStrings(a.startingPosition, b.startingPosition));
          break;
        case 3:
          filteredRideDataList.sort((a, b) => _compareStrings(a.destination, b.destination));
          break;
      // Add more cases for additional columns if needed
      }

      if (!_sortAscending) {
        filteredRideDataList = filteredRideDataList.reversed.toList();
      }
    });
  }
  int _compareStrings(String a, String b) {
    return _sortAscending ? a.compareTo(b) : b.compareTo(a);
  }

}
