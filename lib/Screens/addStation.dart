import 'dart:convert';
import 'dart:ffi';

import 'package:ev_pro/api.dart';
import 'package:ev_pro/decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class add_Station extends StatefulWidget {
  const add_Station({super.key});

  @override
  State<add_Station> createState() => _add_StationState();
}

class _add_StationState extends State<add_Station> {
  final _formKey = GlobalKey<FormState>();
  loc.LocationData? currentLocation;
  loc.Location _locationService = loc.Location();

  String? name;
  String? location;
  TextEditingController? latitudeController;
  TextEditingController? longitudeController;
  String? chargingType;
  int? numberOfPorts;

  String? operatingHours;
  double? pricePerKwh;

  Future<void> fetchCurrentLocation() async {
    try {
      currentLocation = await _locationService.getLocation();

      setState(() {
        if (currentLocation != null) {
          latitudeController =
              TextEditingController(text: currentLocation!.latitude.toString());

          longitudeController = TextEditingController(
              text: currentLocation!.longitude.toString());
        }
      });
    } catch (e) {
      print('Could not fetch location: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EV Station Form'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration:
                    decorative().customInputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
                onSaved: (value) => name = value,
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                decoration:
                    decorative().customInputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
                onSaved: (value) => location = value,
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: latitudeController,
                decoration:
                    decorative().customInputDecoration(labelText: 'latitude'),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: longitudeController,
                decoration:
                    decorative().customInputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<String>(
                decoration: decorative()
                    .customInputDecoration(labelText: 'Select Charging Type'),
                value: chargingType,
                onChanged: (String? newValue) {
                  setState(() {
                    chargingType = newValue;
                  });
                },
                items: <String>['Level 2', 'Level 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the charging type';
                  }
                  return null;
                },
                onSaved: (value) => chargingType = value,
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                decoration: decorative()
                    .customInputDecoration(labelText: 'Number of Ports'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
                onSaved: (value) => numberOfPorts = int.parse(value!),
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                decoration: decorative()
                    .customInputDecoration(labelText: 'Operating Hours'),
                onSaved: (value) => operatingHours = value,
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                decoration: decorative()
                    .customInputDecoration(labelText: 'Price Per kWh'),
                keyboardType: TextInputType.number,
                onSaved: (value) => pricePerKwh = double.tryParse(value!),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final String url = "${Api().user}add_station";
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var userId = prefs.getString('userId');

                    final Map<String, dynamic> data = {
                      'owner_id': userId,
                      'name': name,
                      'location': location,
                      'latitude': latitudeController!.text,
                      'longitude': longitudeController!.text,
                      'charging_type': chargingType,
                      'number_of_ports': numberOfPorts.toString(),
                      'operating_hours': operatingHours,
                      'price_per_kwh': pricePerKwh.toString(),
                    };

                    print(url);
                    print(data);

                    try {
                      final response = await http.post(Uri.parse(url),
                          // headers: {'Content-Type': 'application/json'},
                          body: data);

                      if (response.statusCode == 200) {
                        final responseData = jsonDecode(response.body);
                        print(responseData);
                        if (responseData['status'] == true) {
                          final snackBar = SnackBar(
                            elevation: 100,
                            content: Text(responseData['message']),
                            backgroundColor: Colors.green,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context);
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
                    // Process the data here
                  }
                },
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text('Submit'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
