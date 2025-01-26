import 'package:flutter/material.dart';

class station_booking extends StatefulWidget {
  int station_id;
  station_booking({super.key, required this.station_id});

  @override
  State<station_booking> createState() => _station_bookingState();
}

class _station_bookingState extends State<station_booking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Book Port'),
          centerTitle: true,
          backgroundColor: Colors.greenAccent,
        ),
        body: Center(
          child: Container(
            child: Text('Welcome'),
          ),
        ));
  }
}
