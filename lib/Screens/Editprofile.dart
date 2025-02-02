import 'dart:convert';
import 'dart:io';
import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdatePage extends StatefulWidget {
  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  String user_id = '';
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  File? _image;
  String? pImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse("${Api().user}profileUpdate");
      print(uri);
      var request = http.MultipartRequest('POST', uri);
      request.fields['userId'] = user_id;
      request.fields['name'] = _nameController.text;
      request.fields['email'] = _emailController.text;

      if (_image != null) {
        var multipartFile =
            await http.MultipartFile.fromPath('image', _image!.path);

        request.files.add(multipartFile);
      }
      try {
        var response = await request.send();
        var responseInstance = await http.Response.fromStream(response);
        var responseData = jsonDecode(responseInstance.body);
        print(responseData);
        if (response.statusCode == 200) {
          if (responseData['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'])),
            );
          }
        } else {
          print(response.statusCode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile Update failed')),
          );
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString("userId")!;
    String _name = prefs.getString("name")!;
    String _email = prefs.getString("email")!;
    pImage = prefs.getString("image");
    print(pImage);
    _nameController = TextEditingController(text: _name);
    _emailController = TextEditingController(text: _email);

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.camera_alt, size: 50)
                            : null,
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage("$pImage"),
                      ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _nameController.text = value;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  _emailController.text = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
