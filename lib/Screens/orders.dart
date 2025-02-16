import 'dart:convert';
import 'package:ev_pro/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> orders = [];
  bool isLoading = true;

  fetchOrders(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    final String url = "${Api().user}get_orders?user_id=${userId}&date=${date}";

    print(url);
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        // print(responseData);
        setState(() {
          orders.addAll(responseData['data']);
        });
        isLoading = false;
        print(orders);
      }
    } catch (e) {
      print("OTP Verification Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchOrders(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${DateFormat('MM/dd/yyyy').format(_selectedDate)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ))
                : orders.isEmpty
                    ? Image(image: AssetImage('assets/images/no_data.jpg'))
                    : ListView.builder(
                        itemCount: orders.length,
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
                                    orders[index]['name'].toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    orders[index]['email'].toString(),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.blueGrey),
                                  ),
                                  SizedBox(height: 10),
                                  Divider(),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Booked at: ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: orders[index]['booking']
                                                  ['created_at']
                                              .toString()
                                              .substring(0, 11),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blueGrey),
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
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text:
                                              "${orders[index]['booking']['start_time'].toString().substring(0, 5)} - ${orders[index]['booking']['end_time'].toString().substring(0, 5)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blueGrey),
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
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: orders[index]['booking']
                                                  ['port_number']
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          )
        ]),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime now = DateTime(2000);
    final DateTime maxDate = DateTime(2027);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: maxDate, // Set the maximum selectable date to 5 days from now
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });

    fetchOrders(_selectedDate);
  }
}
