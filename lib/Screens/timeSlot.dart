import 'dart:convert';

import 'package:ev_pro/Screens/chargingPorts.dart';
import 'package:ev_pro/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class station_booking extends StatefulWidget {
  final int stationId;

  station_booking({Key? key, required this.stationId}) : super(key: key);

  @override
  State<station_booking> createState() => _StationBookingState();
}

class _StationBookingState extends State<station_booking> {
  Map<String, dynamic>? stationData;
  List<dynamic> slotsList = [];
  String? chargingType;
  DateTime _selectedDate = DateTime.now();

  Future<void> fetchTimeSlots() async {
    // print(widget.stationId);
    final String url =
        "${Api().user}fetchTimeSlot?station_id=${widget.stationId}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    // print(responseData);
    try {
      if (response.statusCode == 200) {
        setState(() {
          stationData = responseData['station'];
          slotsList = responseData['slots'];
          chargingType = responseData['station']['charging_type'];
        });
      }
    } catch (e) {
      print("Ports fetching Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Slots'),
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
                            const Icon(Icons.electrical_services,
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${DateFormat('MM/dd/yyyy').format(_selectedDate)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (slotsList.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: slotsList.length,
                  itemBuilder: (context, index) {
                    final slot = slotsList[index]; // Changed from port to slot
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChargingPorts(
                                  stationId: widget.stationId,
                                  date: _selectedDate,
                                  start_time: slot['start_time'],
                                  end_time: slot['end_time']),
                            ));
                      }, // Changed from port_number to slot_number
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            '${slot['start_time']} - ${slot['end_time']}', // Changed from Port to Slot
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
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }
}
