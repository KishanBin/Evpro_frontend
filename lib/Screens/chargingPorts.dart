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
  int? _selectedPortIndex;

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

  void _togglePortSelection(int index) {
    setState(() {
      if (_selectedPortIndex == index) {
        _selectedPortIndex = null;
      } else {
        _selectedPortIndex = index;
      }
    });
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
        title: const Text('Available Ports'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: availablePorts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Select your Ports ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                          height:
                              15), // Add some space between the text and the grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: availablePorts.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                print("${availablePorts[index]} hari Bol");
                                _togglePortSelection(index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedPortIndex == index
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  border: Border.all(
                                      color: Colors.greenAccent, width: 2),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _selectedPortIndex != null
          ? BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.currency_rupee), label: 'Pay'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.payment), label: 'card')
              ],
              onTap: (index) {
                // Handle bottom navigation bar tap
                print(index);
              },
            )
          : SizedBox.shrink(),
    );
  }
}
