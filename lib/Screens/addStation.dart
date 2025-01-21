import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
                onSaved: (value) => name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
                onSaved: (value) => location = value,
              ),
              TextFormField(
                controller: latitudeController,
                decoration: InputDecoration(labelText: 'latitude'),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              TextFormField(
                controller: longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Charging Type'),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Number of Ports'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
                onSaved: (value) => numberOfPorts = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Operating Hours'),
                onSaved: (value) => operatingHours = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price Per kWh'),
                keyboardType: TextInputType.number,
                onSaved: (value) => pricePerKwh = double.tryParse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final String url = "${Api().user}add_station";

                    final Map<String, dynamic> data = {
                      'station_name': name,
                      'location': location,
                      'latitude': latitudeController!.text,
                      'longitude': longitudeController!.text,
                      'charging_type': chargingType,
                      'number_of_ports': numberOfPorts,
                      'operating_hours': operatingHours,
                      'price_per_kwh': pricePerKwh,
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
                    print('Name: $name');
                    print('Location: $location');
                    print('Latitude: ${latitudeController.toString()}');
                    print('Longitude: ${longitudeController.toString()}');
                    print('Charging Type: $chargingType');
                    print('Number of Ports: $numberOfPorts');

                    print('Operating Hours: $operatingHours');
                    print('Price Per kWh: $pricePerKwh');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
