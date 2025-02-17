import 'dart:convert';

import 'package:ev_pro/Screens/owner/station_details.dart';
import 'package:ev_pro/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Maintenance extends StatefulWidget {
  const Maintenance({super.key});

  @override
  State<Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  List<dynamic> stations = [];
  bool isLoading = true;

  fetchStation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    final String url = "${Api().user}get_station?user_id=${userId}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        setState(() {
          stations.addAll(responseData['data']);
        });
        isLoading = false;
        // print(stations);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    fetchStation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : stations.isEmpty
              ? Image(image: AssetImage('assets/images/no_data.jpg'))
              : ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StationDetails(
                              station: stations[index],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stations[index]['name'].toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                stations[index]['location'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(height: 10),
                              Divider(),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Charging Type: ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: stations[index]['charging_type']
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
