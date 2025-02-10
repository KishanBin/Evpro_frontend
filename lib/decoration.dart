import 'package:flutter/material.dart';

class decorative {
  InputDecoration customInputDecoration({
    required String labelText,
    String? hintText,
    String? errorText,
    Icon? prefixIcon,
  }) {
    return InputDecoration(
      labelStyle: TextStyle(color: Colors.black),
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
    );
  }
}
