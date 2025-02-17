import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:ev_pro/decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StationDetails extends StatefulWidget {
  dynamic station;
  StationDetails({super.key, required this.station});

  @override
  State<StationDetails> createState() => _StationDetailsState();
}

class _StationDetailsState extends State<StationDetails> {
  final _formKey = GlobalKey<FormState>();
  late int station_id;
  late String location;
  late int numberOfPorts;
  late String operatingHours;
  late double pricePerKwh;
  late bool isActive;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    station_id = widget.station['id'];
    location = widget.station['location'];
    numberOfPorts = widget.station['number_of_ports'];
    operatingHours = widget.station['operating_hours'];
    pricePerKwh = double.parse(widget.station['price_per_kwh']);
    isActive = widget.station['is_active'] == 'active' ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Station Details'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  widget.station['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.station['location'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: numberOfPorts.toString(),
                  decoration: decorative()
                      .customInputDecoration(labelText: 'Number of Ports'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    numberOfPorts = int.tryParse(value) ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of ports';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: operatingHours,
                  decoration: decorative()
                      .customInputDecoration(labelText: 'Operating Hours'),
                  onChanged: (value) {
                    operatingHours = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter operating hours';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: pricePerKwh.toString(),
                  decoration: decorative()
                      .customInputDecoration(labelText: 'Price per kWh'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    pricePerKwh = double.tryParse(value) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price per kWh';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('Station: '),
                        TextButton(
                            onPressed: () {
                              if (isActive == true) {
                                setState(() {
                                  isActive = false;
                                  print(
                                      "isActive: $isActive"); // Debugging print
                                });
                              } else {
                                setState(() {
                                  isActive = true;
                                  print(
                                      "isActive: $isActive"); // Debugging print
                                });
                              }
                            },
                            child: Text(isActive ? 'Active' : 'Inactive')),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {}
                    final String url = "${Api().user}update_station";

                    final Map<String, dynamic> data = {
                      'station_id': station_id.toString(),
                      'number_of_ports': numberOfPorts.toString(),
                      'operating_hr': operatingHours.toString(),
                      'price': pricePerKwh.toString(),
                      'Is_active': isActive ? 'active' : 'inactive',
                    };

                    print(url);
                    print(data);

                    try {
                      final response =
                          await http.post(Uri.parse(url), body: data);

                      if (response.statusCode == 200) {
                        final responseData = jsonDecode(response.body);
                        print(responseData);
                        if (responseData['status'] == true) {
                          final snackBar = SnackBar(
                            elevation: 100,
                            content: Text(
                              responseData['message'],
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.greenAccent,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          final snackBar = SnackBar(
                            elevation: 100,
                            content: Text(responseData['message']),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        throw Exception(
                            'Failed to post data: ${response.statusCode}');
                      }
                    } catch (e) {
                      print("Error: $e");
                    }
                  },
                  child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('Update'))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
