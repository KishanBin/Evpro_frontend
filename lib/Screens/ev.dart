import 'dart:convert';

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
      // print("mapData: $responseData");
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

          var customMarker = CustomMarker(marker: stations, name: y['name']);
          stationList.add(customMarker);
        }
      }
    } catch (e) {
      print("getStation Error: $e");
    }
    return stationList;
  }
}

class CustomMarker {
  final Marker marker;
  final String name; // Example additional data field

  CustomMarker({
    required this.marker,
    required this.name,
  });
}
