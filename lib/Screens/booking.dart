import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class station_booking extends StatefulWidget {
  final int stationId;

  station_booking({Key? key, required this.stationId}) : super(key: key);

  @override
  State<station_booking> createState() => _StationBookingState();
}

class _StationBookingState extends State<station_booking> {
  Map<String, dynamic>? stationData;
  List<dynamic> portsList = [];
  int? selectedPort;
  String? chargingType;
  int? timerCount;

  Future<void> fetchPorts() async {
    final String url = "${Api().user}getStationPorts?id=${widget.stationId}";

    print(url);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          stationData = responseData['station'];
          portsList = responseData['ports'];
          chargingType = responseData['station']['charging_type'];
        });
      }
    } catch (e) {
      print("Ports fetching Error: $e");
    }
  }

  void selectPort(int portNumber) {
    setState(() {
      if (selectedPort == portNumber) {
        selectedPort = null;
        timerCount = null;
      } else {
        selectedPort = portNumber;
        if (chargingType == 'Level 2') {
          timerCount = 60; // 1 hour for level 2
        } else if (chargingType == 'Level 3') {
          timerCount = 20; // 20 minutes for level 3
        }
      }
    });
  }

  void incrementTime() {
    setState(() {
      if (timerCount != null) {
        timerCount = timerCount! + (chargingType == 'Level 2' ? 20 : 60);
      }
    });
  }

  void decrementTime() {
    setState(() {
      if (timerCount != null && timerCount! > 0) {
        timerCount = timerCount! - (chargingType == 'Level 2' ? 20 : 60);
        if (timerCount! < 0) timerCount = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPorts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Port'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Column(
          children: [
            stationData != null
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.ev_station, color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Text(
                              "${stationData!["name"]}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Address: ${stationData!["location"]}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.electrical_services,
                                color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Text(
                              "Type: ${stationData!["charging_type"]}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.electric_car, color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Text(
                              "Number of Ports: ${stationData!["number_of_ports"]}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),

            // Add more UI elements or functionalities as needed
            SizedBox(height: 16),
            if (portsList.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: portsList.length,
                  itemBuilder: (context, index) {
                    final port = portsList[index];
                    return GestureDetector(
                      onTap: () => selectPort(port['port_number']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedPort == port['port_number']
                              ? Colors.greenAccent
                              : Colors.white,
                          border:
                              Border.all(color: Colors.greenAccent, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Port ${port['port_number']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: timerCount != null && timerCount! > 9
          ? BottomAppBar(
              color: Colors.greenAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: decrementTime,
                  ),
                  Text(
                    'Time: $timerCount ${chargingType == 'Level 2' ? 'minutes' : 'minutes'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: incrementTime,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        print(selectedPort);
                        print(timerCount);
                      },
                      child: Text('Book'))
                ],
              ),
            )
          : null,
    );
  }
}
