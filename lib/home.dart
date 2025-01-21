import 'package:ev_pro/Screens/Editprofile.dart';
import 'package:ev_pro/Screens/addStation.dart';
import 'package:ev_pro/Screens/station_finder.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Location location = Location();

  Future<bool> checkLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false; // Location services are not enabled
      }
    }
    return true; // Location services are enabled
  }

  @override
  void initState() {
    // TODO: implement initState
    checkLocationService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 400,
          child: Wrap(
            spacing: 20, // spacing between icons
            runSpacing: 20, // spacing between rows
            children: iconButtons.map((iconButton) {
              return Column(
                children: [
                  IconButton(
                    iconSize: 100,
                    color: Colors.greenAccent,
                    icon: Icon(iconButton['icon']),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => iconButton['onPressed']));
                    },
                  ),
                  Text(iconButton['label']),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> iconButtons = [
    {
      'icon': Icons.ev_station_outlined,
      'label': 'Add Station',
      'onPressed': add_Station(),
    },
    {
      'icon': Icons.location_on_outlined,
      'label': 'Location',
      'onPressed': station_finder(),
    },
    {
      'icon': Icons.book_online,
      'label': 'Booking',
      'onPressed': () {
        print('Booking button pressed');
      },
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
      'onPressed': ProfileUpdatePage(),
    },
  ];
}
