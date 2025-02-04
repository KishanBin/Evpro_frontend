import 'dart:convert';
import 'package:ev_pro/Screens/Editprofile.dart';
import 'package:ev_pro/Screens/addStation.dart';
import 'package:ev_pro/Screens/station_finder.dart';
import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Location location = Location();

  String? user_id;
  String _name = "";
  String? _email;
  String _image = "http://srv710339.hstgr.cloud/images/1738525088.jpg";

  Future<bool> checkLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false; // Location services are not enabled
      }
    }
    return true; // Location services are enabled
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString("userId")!;
    print(user_id);
    final uri = Uri.parse("${Api().user}profileUpdate");
    print(uri);

    var request = http.MultipartRequest('POST', uri);
    request.fields['userId'] = user_id!;
    try {
      var response = await request.send();
      var responseInstance = await http.Response.fromStream(response);
      var responseData = jsonDecode(responseInstance.body);
      // print(responseData);

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          prefs.setString('name', responseData['data']['name']);
          prefs.setString('email', responseData['data']['email']);
          prefs.setString('image', responseData['data']['image']);
          _image = prefs.getString('image')!;
          _name = prefs.getString('name')!;
          _email = prefs.getString('email');
          setState(() {});
        } else {
          debugPrint(responseData['message']);
        }
      } else {
        debugPrint(response.statusCode.toString());
      }
    } catch (e) {
      print("profileData: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    checkLocationService();
    _fetchUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_image),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              _name, // Replace with the user's name
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 400,
          child: Wrap(
            spacing: 20, // spacing between icons
            runSpacing: 20, // spacing between rows
            children: iconButtons.map((iconButton) {
              return Column(
                children: [
                  IconButton(
                    iconSize: 100,
                    color: Colors.greenAccent,
                    icon: Icon(iconButton['icon']),
                    onPressed: () async {
                      await _fetchUserData();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => iconButton['onPressed']));
                    },
                  ),
                  Text(iconButton['label']),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> iconButtons = [
    {
      'icon': Icons.ev_station_outlined,
      'label': 'Add Station',
      'onPressed': add_Station(),
    },
    {
      'icon': Icons.location_on_outlined,
      'label': 'Location',
      'onPressed': station_finder(),
    },
    {
      'icon': Icons.book_online,
      'label': 'Booking',
      'onPressed': () {
        print('Booking button pressed');
      },
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
      'onPressed': ProfileUpdatePage(),
    },
  ];
}
