import 'package:ev_pro/Screens/timeSlot.dart';
import 'package:ev_pro/Screens/ev.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:collection/collection.dart';

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
  final PopupController _popupLayerController = PopupController();

  List<CustomMarker> stationMarker = [];

  Future<void> fetchCurrentLocation() async {
    try {
      currentLocation = await _locationService.getLocation();

      if (currentLocation != null) {
        self = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        _latitude = currentLocation!.latitude!.toString();
        _longitude = currentLocation!.longitude!.toString();

        var myLocation = Marker(
            point: self!,
            child: const Icon(
              Icons.location_pin,
              color: Colors.blue,
              size: 40,
            ));
        var customMarker =
            CustomMarker(marker: myLocation, name: 'Your Location');
        stationMarker.add(customMarker);

        var _stations = await Ev().getStation(_latitude, _longitude);

        stationMarker.addAll(_stations); //here we add the list of markers
      }
      setState(() {});
      _mapController.move(self!, 13.0);
    } catch (e) {
      print('Could not fetch location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    fetchCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Station Finder'),
          centerTitle: true,
          backgroundColor: Colors.greenAccent,
        ),
        body: _map(context, stationMarker));
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
              userAgentPackageName: 'dev.fleaflet.flutter_map.example'),
          PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                  markers: stationMarker
                      .map((CustomMarker) => CustomMarker.marker)
                      .toList(),
                  markerCenterAnimation: const MarkerCenterAnimation(),
                  popupController: _popupLayerController,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (context, marker) {
                      CustomMarker? customMarker =
                          stationMarker.firstWhereOrNull(
                        (cm) => cm.marker == marker,
                      );
                      if (customMarker != null) {
                        return Card(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                            height: 170,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // Container(
                                //   padding: EdgeInsets.all(5),
                                //   decoration: BoxDecoration(
                                //       color: customMarker.availability_status ==
                                //               "true"
                                //           ? Colors.greenAccent
                                //           : Colors.redAccent,
                                //       borderRadius: BorderRadius.circular(5)),
                                //   child: Text(
                                //     customMarker.availability_status == "true"
                                //         ? 'Available'
                                //         : 'Not available',
                                //   ),
                                // ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Name: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '${customMarker.name}\n',
                                      ),
                                      const TextSpan(
                                        text: 'Distance: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '${customMarker.distance} km\n',
                                      ),
                                      const TextSpan(
                                        text: 'Type: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '${customMarker.chargingType}\n',
                                      ),
                                      const TextSpan(
                                        text: 'Price: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '${customMarker.Price} /Kwh \n',
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  station_booking(
                                                      stationId:
                                                          customMarker.id!)));
                                    },
                                    child: Text('Book')),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  )))
        ]);
  }
}
