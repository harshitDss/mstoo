import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DropdownArrays extends StatefulWidget {
  @override
  _DropdownArraysState createState() => _DropdownArraysState();
}

class _DropdownArraysState extends State<DropdownArrays> {
  List<String> dropdownData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://mstooapp.design-street.com.au/api/v1/getfields'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        dropdownData = List<String>.from(data['test1']);
      });
    } else {
      // Handle errors
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: dropdownData.isNotEmpty ? dropdownData.first : null,
            items: dropdownData.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              // Handle dropdown value change
            },
            decoration: InputDecoration(
              labelText: 'Select an option',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
