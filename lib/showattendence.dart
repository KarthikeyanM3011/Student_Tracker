import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowAttendancePage extends StatefulWidget {
  final String studentId;

  ShowAttendancePage({required this.studentId}); // Constructor with studentId

  @override
  _ShowAttendancePageState createState() => _ShowAttendancePageState();
}

class _ShowAttendancePageState extends State<ShowAttendancePage> {
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/fetch/student/attendance?student_id=${widget.studentId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          attendanceData = data.map((item) => item as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load attendance data';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = 'An error occurred';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final record = attendanceData[index];
                      return ListTile(
                        title: Text('Date: ${record['date']}'),
                        subtitle: Text('Status: ${record['present'] == 1 ? 'Present' : 'Absent'}'),
                      );
                    },
                  ),
      ),
    );
  }
}
