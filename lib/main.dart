import 'dart:convert';
import 'package:ev_pro/Authentication/Login.dart';
import 'package:ev_pro/api.dart';
import 'package:ev_pro/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLoggedIn;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    print("token: $token");
    if (token != null) {
      final String url = "${Api().user}checkLoginToken";
      final Map<String, dynamic> data = {
        'login_token': token,
      };
      final response = await http.post(Uri.parse(url), body: data);
      final responseData =
          jsonDecode(response.body); // Update the state based on the response
      setState(() {
        isLoggedIn = responseData['status'];
      });
    } else {
      // No token found, set isLoggedIn to false
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home:
          //  isLoggedIn == null
          //     ? Center(child: CircularProgressIndicator())
          //     : isLoggedIn!
          //         ? Dashboard()
          LoginPage(),
    );
  }
}
