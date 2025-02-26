
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  LatLng destination = LatLng(19.206363, 72.838200);
  loc.LocationData? currentLocation;

  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? self;
  List<LatLng>? _route;
  double? heading;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Update whenever there's any movement
      ),
    ).listen((Position position) {
      setState(() {
        self = LatLng(position.latitude, position.longitude);
        heading = position.heading; // Get the heading (device direction)
      });

      fetchRoute();
    });
  }

  @override
  void dispose() {
    // Ensure to dispose resources and avoid memory leaks
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('OpenStreetMap with Flutter'),
        ),
        body: self == null
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ))
            : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: self!,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                        point: self!,
                        child: Transform.rotate(
                          angle:
                              (heading ?? 0) * (3.14159 / 180), // Rotate marker
                          child: Icon(
                            Icons.navigation,
                            color: Colors.blue,
                            size: 30,
                          ),
                        )),
                    Marker(
                        point: destination,
                        rotate: true,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ))
                  ]),
                  if (self != null && _route != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route!,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                ],
              ));
  }

  Future<void> fetchRoute() async {
    if (self == null || destination == null) return;

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
        '${self!.longitude},${self!.latitude};'
        '${destination.longitude},${destination.latitude}?overview=full&geometries=polyline');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    }
  }

  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints =
        polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      _route = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }
}