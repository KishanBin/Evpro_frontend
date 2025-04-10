import 'dart:convert';

import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';

import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChargingPorts extends StatefulWidget {
  final int stationId;
  final dynamic date;
  final String start_time;
  final String end_time;

  const ChargingPorts({
    super.key,
    required this.stationId,
    required this.date,
    required this.start_time,
    required this.end_time,
  });

  @override
  State<ChargingPorts> createState() => _ChargingPortsState();
}

class _ChargingPortsState extends State<ChargingPorts> {
  Map<String, dynamic>? stationData;
  List<dynamic> availablePorts = [];
  int? portCount;
  int? _selectedPortIndex;
  double price = 0;

  //upi code

  //razopay code
  Razorpay _razorpay = Razorpay();

  Future<void> fetchAvailablePorts() async {
    String date = DateFormat('yyyy-MM-dd').format(widget.date);

    final String url =
        "${Api().user}getAvailablePorts?station_id=${widget.stationId}&start_time=${widget.start_time}&end_time=${widget.end_time}&date=${date}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    // print(responseData);
    try {
      if (response.statusCode == 200) {
        setState(() {
          stationData = responseData['station'];
          availablePorts = responseData['available_ports'];
          portCount = responseData['available_ports_count'];
          price = double.parse(responseData['station']['price_per_kwh']);
        });
      } else {
        print("Failed to fetch available ports");
      }
    } catch (e) {
      print("Ports fetching Error: $e");
    }
  }

  void _togglePortSelection(int index) {
    setState(() {
      if (_selectedPortIndex == index) {
        _selectedPortIndex = null;
      } else {
        _selectedPortIndex = index;
        print(_selectedPortIndex);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAvailablePorts();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    try {
      _razorpay.clear();
    } catch (e) {
      print(e);
    } // Removes all listeners
  }

  @override
  Widget build(BuildContext context) {
    //razorpay code

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Ports'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: availablePorts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.greenAccent,
            ))
          : Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 12),
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    Text(
                      'Select your Ports ',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                        height:
                            15), // Add some space between the text and the grid
                    Container(
                      child: Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: availablePorts.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _togglePortSelection(availablePorts[index]);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedPortIndex ==
                                          availablePorts[index]
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  border: Border.all(
                                      color: Colors.greenAccent, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${availablePorts[index]}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (_selectedPortIndex != null)
                      InkWell(
                        onTap: () async {
                          razorpay();
                          // showDialog(
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return AlertDialog(
                          //       content: Container(
                          //         height: 130,
                          //         width: MediaQuery.of(context).size.width,
                          //         child: Column(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceAround,
                          //           children: [
                          //             _buildPaymentOption(
                          //                 AntDesign.google_circle_fill,
                          //                 "UPI",
                          //                 true),
                          //             _buildPaymentOption(
                          //                 LineAwesome.cc_visa, "cards", false),
                          //           ],
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // );
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.greenAccent,
                          child: Center(child: Text('Pay $price')),
                        ),
                      )
                    else
                      SizedBox.shrink(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String label, bool upi) {
    return GestureDetector(
      onTap: () {
        if (upi) {
          UpiTransaction();
          Navigator.of(context).pop();
        } else {
          razorpay();
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 30),
            SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Future<void> UpiTransaction() async {}

  void razorpay() {
    var options = {
      'key': 'rzp_test_JJYkpkhUKmXkKO',
      'amount': price,
      'name': 'EV Pro',
      'description': 'charging Charge',
      'prefill': {'contact': '9152620045', 'email': 'test@razorpay.com'}
    };
    // opening the razorpay options
    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error razorpay: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    print('Hari Bol');
    //for userId
    SharedPreferences prefe = await SharedPreferences.getInstance();
    String userId = prefe.getString("userId")!;

    //formating date
    String date = DateFormat('yyyy-MM-dd').format(widget.date);
    ;

    // Format the date to the desired format

    print('Hari Bol');
    final String url = "${Api().user}port_booking";

    final Map<String, dynamic> data = {
      'station_id': widget.stationId.toString(),
      'port_number': _selectedPortIndex.toString(),
      'date': date,
      'start_time': widget.start_time,
      'end_time': widget.end_time,
      "booking_status": "booked",
      "booked_by": userId
    };

    print(url);
    print(data);

    try {
      final response = await http.post(Uri.parse(url), body: data);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData['status'] == true) {
          fetchAvailablePorts();
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            elevation: 100,
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("mat bol hari");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }
}
