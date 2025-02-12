import 'dart:convert';

import 'package:email_auth/email_auth.dart';
import 'package:ev_pro/Authentication/Login.dart';
import 'package:ev_pro/api.dart';
import 'package:ev_pro/decoration.dart';
import 'package:ev_pro/home.dart';
import 'package:flutter/cupertino.dart';
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
  bool otpSent = false;
  bool verifed = false;
  TextEditingController _otp = TextEditingController();

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
                Container(
                  height: 100,
                  width: 100,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: ClipOval(
                      child: Image.asset('assets/images/evpro_icon.jpeg')),
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
                      onPressed: () => sendOtp(_email.text),
                      child: Text('send OTP'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                //code execute when otp sent
                otpSent
                    ? Column(
                        children: [
                          Container(
                            width: 100, // Adjust the width as needed
                            child: TextField(
                              controller: _otp,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'Enter OTP',
                                counterText: '', // Hide the counter text
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                              onPressed: () =>
                                  otpVerification(_email.text, _otp.text),
                              child: Text('Verify'))
                        ],
                      )
                    : SizedBox.shrink(),
                //code run after email verification
                verifed
                    ? Column(children: [
                        TextFormField(
                          decoration: decorative()
                              .customInputDecoration(labelText: 'Password'),
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
                        InkWell(
                          onTap: () async {
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
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LoginPage()));
                                } else {
                                  final snackBar = SnackBar(
                                    elevation: 100,
                                    content: Text(responseData['message']),
                                    backgroundColor: Colors.red,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
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
                              child: Center(child: Text('Register'))),
                        ),
                      ])
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendOtp(String email) async {
    final String url = "${Api().user}send_otp?email=${email}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            otpSent = true;
          });
        } else {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            otpSent = false;
          });
        }
      }
    } catch (e) {
      print("OTP sending Error: $e");
    }
  }

  Future<void> otpVerification(String email, String otp) async {
    final String url = "${Api().user}verify_otp?email=${email}&otp=${otp}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            verifed = true;
            otpSent = false;
          });
        } else {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            verifed = false;
          });
        }
      }
    } catch (e) {
      print("OTP Verification Error: $e");
    }
  }
}
