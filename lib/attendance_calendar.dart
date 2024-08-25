import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'mark_attendance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceCalendarPage extends StatefulWidget {
  final String className;

  AttendanceCalendarPage({required this.className});

  @override
  _AttendanceCalendarPageState createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDate = DateTime.now();
  int presentCount = 0;
  int absentCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAttendanceSummary();
  }

  Future<void> fetchAttendanceSummary() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:5000/fetch/attendance/summary?class_name=${widget.className}&date=${selectedDate.toIso8601String()}'));
          print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          presentCount = int.parse(data['present_count']);
          absentCount = int.parse(data['absent_count']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance summary');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Attendance Not Found !'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: format,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
              fetchAttendanceSummary();
            },
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Present',
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                          Text(
                            '$presentCount',
                            style: TextStyle(fontSize: 22.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Absent',
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                          Text(
                            '$absentCount',
                            style: TextStyle(fontSize: 22.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a date')),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkAttendancePage(
                      className: widget.className,
                      date: selectedDate,
                    ),
                  ),
                );
              }
            },
            child: Text('Edit Attendance'),
          ),
        ],
      ),
    );
  }
}
