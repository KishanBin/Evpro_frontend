import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;

class station_finder extends StatefulWidget {
  const station_finder({super.key});

  @override
  State<station_finder> createState() => _station_finderState();
}

class _station_finderState extends State<station_finder> {
  LatLng _mumbai = LatLng(19.0760, 72.8777);
  late MapController _mapController;
  loc.LocationData? currentLocation;
  loc.Location _locationService = loc.Location();

  Future<void> fetchCurrentLocation() async {
    try {
      currentLocation = await _locationService.getLocation();
      setState(() {
        if (currentLocation != null) {
          _mapController.move(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            13.0,
          );

          _mumbai =
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        }
      });
    } catch (e) {
      print('Could not fetch location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Google Maps Demo'),
          backgroundColor: Colors.greenAccent,
        ),
        body: _map());
  }

  Widget _map() {
    return Stack(
      children: [
        FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mumbai,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example'),
              MarkerLayer(markers: [
                Marker(
                  point: _mumbai,
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ]),
            ]),
        Positioned(
            top: 560,
            left: 280,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(50)),
              height: 60,
              width: 60,
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => fetchCurrentLocation(),
              ),
            )),
      ],
    );
  }
}
