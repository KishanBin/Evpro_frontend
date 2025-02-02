import 'dart:convert';

import 'package:email_auth/email_auth.dart';
import 'package:ev_pro/Authentication/Login.dart';
import 'package:ev_pro/api.dart';
import 'package:ev_pro/decoration.dart';
import 'package:ev_pro/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _userType;
  String? _name;
  TextEditingController _email = TextEditingController();
  String? _password;
  bool verifed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Registration",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const CircleAvatar(
                  child: Image(image: AssetImage('assets/images/avatar.png')),
                  radius: 50, // Radius of the avatar
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  decoration: decorative()
                      .customInputDecoration(labelText: 'User Type'),
                  value: _userType,
                  items: <String>['customer', 'owner'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _userType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a user type' : null,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration:
                      decorative().customInputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _name = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      decoration: decorative()
                          .customInputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _email.text = value;
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        // Add your verification logic here
                        print('Verifying email: ${_email.toString()}');

                        try {} catch (e) {
                          print("Error $e");
                        }
                      },
                      child: Text('Verify'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration:
                      decorative().customInputDecoration(labelText: 'Password'),
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _password = value;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {}
                    final String url = "${Api().user}regi_user";

                    final Map<String, dynamic> data = {
                      'userType': _userType,
                      'name': _name,
                      'email': _email.text,
                      'password': _password
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
                            backgroundColor: Colors.greenAccent,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => LoginPage()));
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
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
