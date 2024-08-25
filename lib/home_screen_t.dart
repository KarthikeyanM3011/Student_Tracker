import 'package:flutter/material.dart';
import 'login_page.dart';
import 'class_selection.dart';
import 'mark_attendance.dart';

class HomeScreenT extends StatelessWidget {
  final String teacherId;

  HomeScreenT({required this.teacherId}); // Constructor with teacherId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert), // This is the three-dot icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the Drawer
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Teacher ID: $teacherId"),
              accountEmail: Text("johndoe@example.com"), // You can also update this dynamically
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://www.example.com/profile_picture.jpg",
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer on tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      // Navigate to settings or perform some action
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0), // Horizontal space of 30 on both sides
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, Teacher ID: $teacherId', // Display teacherId
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Space between text and buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassSelectionPage(teacherId: teacherId)), // Pass teacherId
                );
                print('Attendance Page');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
