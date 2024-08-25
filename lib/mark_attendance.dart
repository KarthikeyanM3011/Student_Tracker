import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Student {
  final int rollNo;
  final String name;
  int attended; // Changed to int to match the server data

  Student({required this.rollNo, required this.name, required this.attended});

  // Convert the student to a JSON map
  Map<String, dynamic> toJson() => {
    'roll_no': rollNo,
    'name': name,
    'attended': attended, // Send as int
  };

  // Convenience getter to convert int to bool
  bool get isAttended => attended == 1;
}

class MarkAttendancePage extends StatefulWidget {
  final String className;
  final DateTime date;

  const MarkAttendancePage({required this.className, required this.date});

  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:5000/fetch/students?class_name=${widget.className}&date=${widget.date.toIso8601String()}'));

      if (response.statusCode == 200) {
        List<Student> fetchedStudents = List<Student>.from(
          json.decode(response.body).map((data) => Student(
            rollNo: data['roll_no'],
            name: data['name'],
            attended: data['attended'],
          )),
        );
        setState(() {
          students = fetchedStudents;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load students')),
      );
    }
  }

  Future<void> submitAttendance() async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/update/attendance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'class_name': widget.className,
        'date': widget.date.toIso8601String(),
        'students': students.map((student) => student.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance updated successfully')),
      );
    } else {
      // Optionally parse and display more specific error messages
      final responseBody = json.decode(response.body);
      final errorMessage = responseBody['error'] ?? 'Failed to update attendance';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update attendance: ${error.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance for ${widget.className} on ${widget.date.toLocal().toShortDateString()}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                Student student = students[index];
                return CheckboxListTile(
                  title: Text(student.name),
                  value: student.isAttended,
                  onChanged: (bool? value) {
                    setState(() {
                      student.attended = value == true ? 1 : 0;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: submitAttendance,
              child: Text('Submit Attendance'),
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeFormatting on DateTime {
  String toShortDateString() {
    return '${this.day.toString().padLeft(2, '0')}/${this.month.toString().padLeft(2, '0')}/${this.year}';
  }
}

