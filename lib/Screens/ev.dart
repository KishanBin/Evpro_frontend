import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Ev {
  Future<List<Marker>> getStation(String? latitude, String? longitude) async {
    List<Marker> stationList = [];
    final String url =
        "${Api().user}findNearbyStations?latitude=$latitude&longitude=$longitude";

    // String url =
    //     "https://betaapp.mobilla.in/customer/v3/findNearbyStations?latitude=$latitude&longitude=$longitude";
    // final Map<String, String> queryParams = {
    //   'Authorization':
    //       "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNWVmMTAyNTA2MTIzMzc5NmZkMjBjMjZiODIxYTA5ZDg2YzVlYTM3OTQzMjE4NGQzOGIzOGNjZGJjZDM1MzFkYmNlN2ZlZGFhMjQ1ZDY3MTQiLCJpYXQiOjE3MzY1ODI3ODQuMjg5OTU1LCJuYmYiOjE3MzY1ODI3ODQuMjg5OTY0LCJleHAiOjE3NjgxMTg3ODQuMjgyMzc1LCJzdWIiOiIyMjYiLCJzY29wZXMiOltdfQ.OCSvFn-7OyrDCwKWcWX89lqkeI8uOVgrOCtw7NSA-LgHzpYT7GzrpdUpyVvlkOnVmTsaRHa_bqkbXs8gHzx1JXScarqy1IQvJl8L8NYNG1hwuejVM80-O2S3uhEb2P1Y6J6AKkTWfZv5LHxmQn9RteNHbO3gK-pSVwmxGN6dwPwvxFBoVYT0jeE6i8-ndhqHjodiLvfdLwCFJhwyKpg5HoSRjVwLF5pctrZfKsd8xhoF9lOU-McTnbiwgXd27CgAnYs4YtxZ6G0qgrkRHfc2sm2QK38U4LBkSomtBAaogIJndxalDdg-NHUSqDQZeP1znMMGuk9uINOXasvX7Mywg57podF7NJGAmME3slmN_7xV4MkpsjByufSkBZMzn7nm92Ixm23wEepDHNb7oFQ9VOft4tNlF8y2ztnK0veZPQdGMee8_hPjWQecQabwGRvsDm1Kf4leqnh8Eu3PRs7VdkIJhP75QU2CCl6iP4lvcR2XHHiGfDIM3Aukt6CvtGHG1j4LA82sXeGbl7i8ekOUWaSSUgAXHYA-4DuOZVu6zprkMUGakicKxbdMB3ekvjyMMNIr9N5V_qUbDTsJ26qbI8v615HdFavSJG-iAc0Pv1Bsoia5anghw3ipdqZxmiKXO9PdZmvpgXkYyezTZMXTa8hCHoqaTB4lLfGx4Iv0FDU",
    // };
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
          stationList.add(stations);
        }
      }
    } catch (e) {
      print("getStation Error: $e");
    }
    return stationList;
  }
}
