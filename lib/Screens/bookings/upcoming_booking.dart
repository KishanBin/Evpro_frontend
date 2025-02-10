import 'dart:convert';
import 'dart:core';

import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingListView extends StatefulWidget {
  BookingListView({super.key});

  @override
  State<BookingListView> createState() => _BookingListViewState();
}

class _BookingListViewState extends State<BookingListView> {
  List bookingList = [];
  String $message = "";

  fetchBookings() async {
    SharedPreferences prefe = await SharedPreferences.getInstance();
    String userId = prefe.getString("userId")!;

    final String url =
        "${Api().user}bookings?user_id=${userId}&is_upcoming=true";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          setState(() {
            bookingList.addAll(responseData['data']);
          });
        } else {
          setState(() {
            $message = responseData['message'];
          });
        }
      }
    } catch (e) {
      print("Ports fetching Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return bookingList.isEmpty
        ? Image(image: AssetImage('assets/images/no_data.jpg'))
        : ListView.builder(
            itemCount: bookingList.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookingList[index]['station_name'].toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bookingList[index]['station_location'].toString(),
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Booked at: ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextSpan(
                              text: bookingList[index]['created_at']
                                  .toString()
                                  .substring(0, 11),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Booking of: ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextSpan(
                              text: bookingList[index]['date'].toString(),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Time slot: ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextSpan(
                              text:
                                  "${bookingList[index]['start_time'].toString().substring(0, 5)} - ${bookingList[index]['end_time'].toString().substring(0, 5)}",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Port no: ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextSpan(
                              text:
                                  bookingList[index]['port_number'].toString(),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Price: ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextSpan(
                              text: bookingList[index]['price'].toString(),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Cancel'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Alert'),
                                  content: Text(
                                      'Are you sure you want to cancel the Booking'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        cancelBooking(
                                                context,
                                                bookingList[index]['station_id']
                                                    .toString(),
                                                bookingList[index]
                                                        ['port_number']
                                                    .toString(),
                                                bookingList[index]['date']
                                                    .toString(),
                                                bookingList[index]['start_time']
                                                    .toString(),
                                                bookingList[index]['end_time']
                                                    .toString(),
                                                bookingList[index]['created_at']
                                                    .toString())
                                            .then((value) =>
                                                Navigator.of(context).pop());
                                      },
                                      child: Text('Ok'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Future<void> cancelBooking(
      BuildContext context,
      String station_id,
      String port_number,
      String date,
      String start_time,
      String end_time,
      String createdAt) async {
    SharedPreferences prefe = await SharedPreferences.getInstance();
    String userId = prefe.getString("userId")!;

    print('Hari Bol');
    final String url = "${Api().user}cancel_booking";

    final Map<String, dynamic> data = {
      'station_id': station_id,
      'port_number': port_number,
      'date': date,
      'start_time': start_time,
      'end_time': end_time,
      "booking_status": "booked",
      "booked_by": userId,
      "created_at": createdAt
    };

    print(url);
    print(data);

    try {
      final response = await http.post(Uri.parse(url), body: data);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData['status'] == true) {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          fetchBookings();
        } else {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        throw Exception('Failed to cancel: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
