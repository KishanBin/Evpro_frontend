import 'dart:convert';

import 'package:ev_pro/Screens/bookings/booking_history.dart';
import 'package:ev_pro/Screens/bookings/upcoming_booking.dart';
import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class bookings extends StatefulWidget {
  const bookings({super.key});

  @override
  State<bookings> createState() => _bookingsState();
}

class _bookingsState extends State<bookings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          centerTitle: true,
          backgroundColor: Colors.greenAccent,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Booking'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(children: [BookingListView(), HistoryListView()]),
      ),
    );
  }
}
