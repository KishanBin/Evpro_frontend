import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChargingPorts extends StatefulWidget {
  final int stationId;
  final dynamic date;
  final String start_time;
  final String end_time;

  const ChargingPorts({
    super.key,
    required this.stationId,
    required this.date,
    required this.start_time,
    required this.end_time,
  });

  @override
  State<ChargingPorts> createState() => _ChargingPortsState();
}

class _ChargingPortsState extends State<ChargingPorts> {
  Map<String, dynamic>? stationData;
  List<dynamic> availablePorts = [];
  int? portCount;

  Future<void> fetchAvailablePorts() async {
    final String url =
        "${Api().user}getAvailablePorts?station_id=${widget.stationId}&start_time=${widget.start_time}&end_time=${widget.end_time}&date=${widget.date}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    print(responseData);
    try {
      if (response.statusCode == 200) {
        setState(() {
          stationData = responseData['station'];
          availablePorts = responseData['available_ports'];
          portCount = responseData['available_ports_count'];
        });
      } else {
        print("Failed to fetch available ports");
      }
    } catch (e) {
      print("Ports fetching Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAvailablePorts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ports'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: availablePorts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availablePorts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print("${availablePorts[index]} hari Bol");
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => ,
                    //     ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${availablePorts[index]}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
