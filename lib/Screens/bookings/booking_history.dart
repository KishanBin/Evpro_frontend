import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HistoryListView extends StatefulWidget {
  HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  List bookingHistory = [];
  String $message = "";
  bool isLoading = true;

  fetchBookingHistory() async {
    SharedPreferences prefe = await SharedPreferences.getInstance();
    String userId = prefe.getString("userId")!;

    final String url =
        "${Api().user}bookings?user_id=${userId}&is_upcoming=false";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          setState(() {
            bookingHistory.addAll(responseData['data']);
          });
          isLoading = false;
        } else {
          setState(() {
            $message = responseData['message'];
          });
          isLoading = false;
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
    fetchBookingHistory();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.greenAccent,
          ))
        : bookingHistory.isEmpty
            ? Image(image: AssetImage('assets/images/no_data.jpg'))
            : ListView.builder(
                itemCount: bookingHistory.length,
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
                            bookingHistory[index]['station_name'].toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            bookingHistory[index]['station_location']
                                .toString(),
                            style:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Booked at: ",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                TextSpan(
                                  text: bookingHistory[index]['created_at']
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                TextSpan(
                                  text:
                                      bookingHistory[index]['date'].toString(),
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                TextSpan(
                                  text:
                                      "${bookingHistory[index]['start_time'].toString().substring(0, 5)} - ${bookingHistory[index]['end_time'].toString().substring(0, 5)}",
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                TextSpan(
                                  text: bookingHistory[index]['port_number']
                                      .toString(),
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                TextSpan(
                                  text:
                                      bookingHistory[index]['price'].toString(),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          bookingHistory[index]['booking_status'].toString() ==
                                  "cancelled"
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.grey, // Text color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('Cancelled'),
                                    onPressed: () {
                                      // Handle cancel action
                                    },
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
