import 'dart:convert';

import 'package:ev_pro/Authentication/register.dart';
import 'package:ev_pro/api.dart';
import 'package:ev_pro/decoration.dart';
import 'package:ev_pro/home.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EV',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w900),
                      ),
                      Icon(
                        Icons.flash_on,
                        color: Colors.greenAccent,
                        size: 30,
                      ),
                      Text(
                        "Pro",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w900),
                      )
                    ],
                  ),
                ),
                Container(
                    height: 250,
                    width: 380,
                    child: Image(
                      image: AssetImage('assets/images/login_temp.jpeg'),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                    )),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorColor: Colors.greenAccent,
                  decoration:
                      decorative().customInputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Simple email validation
                    String pattern = r'^[^@]+@[^@]+\.[^@]+';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorColor: Colors.greenAccent,
                  decoration:
                      decorative().customInputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value;
                  },
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final String url = "${Api().user}login_user";

                      final Map<String, dynamic> data = {
                        'email': _email,
                        'password': _password
                      };

                      print(url);
                      print(data);

                      final response =
                          await http.post(Uri.parse(url), body: data);
                      final responseData = jsonDecode(response.body);
                      print(responseData);
                      try {
                        if (response.statusCode == 200) {
                          if (responseData['status'] == true) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            prefs.setString('userId',
                                responseData['data']['id'].toString());

                            prefs.setString('token', responseData['token']);
                            prefs.setString(
                                'name', responseData['data']['name']);
                            prefs.setString(
                                'userType', responseData['data']['user_type']);
                            prefs.setString(
                                'email', responseData['data']['email']);
                            prefs.setString(
                                'image', responseData['data']['image']);

                            final snackBar = SnackBar(
                              elevation: 100,
                              content: Text(responseData['message']),
                              backgroundColor: Colors.greenAccent,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => Dashboard()));
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
                    }
                  },
                  child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('Login'))),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Don't have Account? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Create Account',
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegistrationPage()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
