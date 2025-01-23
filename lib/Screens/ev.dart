import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:http/http.dart' as http;

class Ev {
  Future<List> getStation(String latitude, String longitude) async {
    List stationList = [];
    final String url = "${Api().user}findNearbyStations";
    final Map<String, String> queryParams = {
      'latitude': latitude,
      'longitude': longitude,
    };
    print(url);

    // try {
    final response = await http.get(Uri.parse(url), headers: queryParams);
    final responseData = jsonDecode(response.body);
    print(responseData);
    //   if (response.statusCode == 200) {
    //     final responseData = jsonDecode(response.body);
    //     print(responseData);

    //   } else {
    //     throw Exception('Failed to post data: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print("Error: $e");
    // }
    return stationList;
  }
}
