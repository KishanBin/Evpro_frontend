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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const CircleAvatar(
                child: Image(image: AssetImage('assets/images/avatar.png')),
                radius: 50, // Radius of the avatar
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
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
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final String url = "${Api().user}login_user";

                    final Map<String, dynamic> data = {
                      'email': _email,
                      'password': _password
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
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('token', responseData['token']);
                          final snackBar = SnackBar(
                            elevation: 100,
                            content: Text(responseData['message']),
                            backgroundColor: Colors.green,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => Dashboard()));
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
                  }
                },
                child: Text('Login'),
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
    );
  }
}
