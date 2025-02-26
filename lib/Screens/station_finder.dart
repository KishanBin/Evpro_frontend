import 'dart:async';
import 'dart:convert';
import 'package:ev_pro/Screens/timeSlot.dart';
import 'package:ev_pro/Screens/ev.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

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
  String? _latitude;
  String? _longitude;
  LatLng? self;
  List<LatLng>? _route;
  LatLng? _destination;
  double? heading;
  bool _isRoute = false;

  final PopupController _popupLayerController = PopupController();

  List<CustomMarker> stationMarker = [];
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    fetchCurrentLocation();
  }

  @override
  void dispose() {
    // Ensure to dispose resources and avoid memory leaks

    _popupLayerController.dispose();
    _mapController.dispose();
    super.dispose();
    _positionStreamSubscription?.cancel();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      currentLocation = await _locationService.getLocation();
      if (currentLocation != null) {
        self = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        _latitude = currentLocation!.latitude!.toString();
        _longitude = currentLocation!.longitude!.toString();
        setState(() {});
        // Check if there's an existing marker and remove it before adding a new one
        // stationMarker.removeWhere((marker) => marker.name == 'Your Location');

        // var myLocation = Marker(
        //   point: self!,
        //   child: const Icon(
        //     Icons.navigation_sharp,
        //     color: Colors.blue,
        //     size: 40,
        //   ),
        // );

        // var customMarker =
        //     CustomMarker(marker: myLocation, name: 'Your Location');
        // stationMarker.add(customMarker);

        var _stations = await Ev().getStation(_latitude, _longitude);

        stationMarker.addAll(_stations); // here we add the list of markers

        if (mounted) {
          setState(() {
            _mapController.move(self!, 13.0);
          });
        }
      }
    } catch (e) {
      print('Could not fetch location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Station Finder'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: self == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : _map(context, stationMarker),
    );
  }

  Widget _map(BuildContext context, List<CustomMarker> stationMarker) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mumbai,
        initialZoom: 13.0,
        onTap: (_, __) => _popupLayerController.hideAllPopups(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(markers: [
          Marker(
            point: self!,
            child: _isRoute
                ? Transform.rotate(
                    angle: (heading ?? 0) * (3.14159 / 180), // Rotate marker
                    child: Icon(
                      Icons.navigation,
                      size: 40,
                    ),
                  )
                : Icon(
                    Icons.location_pin,
                    color: Colors.blue,
                    size: 40,
                  ),
          )
        ]),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            markers: stationMarker
                .map((customMarker) => customMarker.marker)
                .toList(),
            markerCenterAnimation: const MarkerCenterAnimation(),
            popupController: _popupLayerController,
            popupDisplayOptions: PopupDisplayOptions(
              builder: (context, marker) {
                CustomMarker? customMarker = stationMarker.firstWhereOrNull(
                  (cm) => cm.marker == marker,
                );

                if (customMarker != null) {
                  return Card(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      height: 170,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Name: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${customMarker.name}\n',
                                ),
                                const TextSpan(
                                  text: 'Distance: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${customMarker.distance} km\n',
                                ),
                                const TextSpan(
                                  text: 'Type: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${customMarker.chargingType}\n',
                                ),
                                const TextSpan(
                                  text: 'Price: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${customMarker.Price} /Kwh \n',
                                ),
                              ],
                            ),
                          ),
                          if (customMarker.name != 'Your Location')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _isRoute = true;
                                    _destination = customMarker.marker.point;

                                    _positionStreamSubscription =
                                        Geolocator.getPositionStream(
                                      locationSettings: LocationSettings(
                                        accuracy: LocationAccuracy.high,
                                        distanceFilter:
                                            0, // Update whenever there's any movement
                                      ),
                                    ).listen((Position position) {
                                      // Check if the widget is still mounted before updating the state
                                      if (mounted) {
                                        setState(() {
                                          self = LatLng(position.latitude,
                                              position.longitude);
                                          heading = position
                                              .heading; // Get the heading (device direction)
                                        });
                                        _route = [];
                                        // Fetch the route only if the widget is still mounted
                                        fetchRoute();
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(width: 1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.navigation_outlined,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'Route',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => station_booking(
                                          stationId: customMarker.id!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: 30,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border: Border.all(width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        'Book',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
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
    );
  }

  Future<void> fetchRoute() async {
    print("hari bol");

    // Ensure we have both self and destination, and widget is still mounted
    if (self == null || _destination == null) return;

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
        '${self!.longitude},${self!.latitude};'
        '${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        final geometry = data['routes'][0]['geometry'];
        _decodePolyline(geometry);
      } else {
        // Handle HTTP errors (e.g., 400, 500 status codes)
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any error that might occur during the HTTP request
      print('Error fetching route: $e');
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
      print("hari bol 3");
    });
  }
}
