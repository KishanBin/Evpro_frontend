import 'dart:convert';
import 'dart:ffi';

import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Ev {
  Future<List<CustomMarker>> getStation(
      String? latitude, String? longitude) async {
    List<CustomMarker> stationList = [];
    final String url =
        "${Api().user}findNearbyStations?latitude=$latitude&longitude=$longitude";

    print(url);

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = jsonDecode(response.body);
      print("mapData: $responseData");
      if (response.statusCode == 200) {
        List x = responseData;
        for (int i = 0; i < x.length; i++) {
          var y = x[i];
          var latitude0 = double.parse(y['latitude']);
          var longitude0 = double.parse(y['longitude']);

          var stations = Marker(
              point: LatLng(latitude0, longitude0),
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ));

          var customMarker = CustomMarker(
              marker: stations,
              name: y['name'],
              id: y['id'],
              location: y['location'],
              chargingType: y['charging_type'],
              number_of_ports: y['number_of_ports'],
              availability_status: y['availability_status'],
              operation_hr: y['operating_hours'],
              Price: y['price_per_kwh'],
              distance: y['distance']);
          stationList.add(customMarker);
        }
      }
    } catch (e) {
      print("getStation Error: $e");
    }
    return stationList;
  }

  void getAvailableports() {}
}

class CustomMarker {
  final Marker marker;
  final String name; // Example additional data field
  String? location;
  String? chargingType;
  int? number_of_ports;
  String? operation_hr;
  String? availability_status;
  String? Price;
  int? id;
  int? distance;

  CustomMarker(
      {required this.marker,
      required this.name,
      this.id,
      this.location,
      this.chargingType,
      this.number_of_ports,
      this.operation_hr,
      this.availability_status,
      this.Price,
      this.distance});
}
