import 'package:flutter/material.dart';
import 'attendance_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClassSelectionPage extends StatefulWidget {
  final String teacherId;

  ClassSelectionPage({required this.teacherId});

  @override
  _ClassSelectionPageState createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  List<String> classNames = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/fetch/classes?teacher_id=${widget.teacherId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<String> fetchedClasses = List<String>.from(data);
        setState(() {
          classNames = fetchedClasses;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load classes';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    itemCount: classNames.length,
                    itemBuilder: (context, index) {
                      return buildClassBox(classNames[index]);
                    },
                  ),
      ),
    );
  }

  Widget buildClassBox(String className) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceCalendarPage(className: className),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.blueAccent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                className,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
