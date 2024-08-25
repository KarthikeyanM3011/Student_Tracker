// import 'package:flutter/material.dart';
// import 'signup_page.dart';
// import 'home_screen_t.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>(); // Key for form validation
//   final TextEditingController userIdController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   void login() {
//     if (_formKey.currentState?.validate() ?? false) {
//       String userId = userIdController.text;
//       String password = passwordController.text;
//       print('Login API called with User ID: $userId, Password: $password');

//       // Navigate to HomeScreen and pass the userId
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeScreenT(teacherId: userId), // Pass userId to HomeScreen
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Form(
//           key: _formKey, // Assign the form key to the Form widget
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Hey!\nWelcome Back",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.blue,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: userIdController,
//                       decoration: InputDecoration(
//                         labelText: 'User ID', // Changed to User ID
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your User ID'; // Updated validation message
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       controller: passwordController,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password'; // Updated validation message
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: login,
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white),
//                       child: Text('Login'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SignUpPage()));
//                       },
//                       child: Text('Or sign up here'),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text("Terms & Conditions Apply*"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home_screen_s.dart'; // Add imports for the student home screen
import 'home_screen_t.dart'; // Add imports for the teacher home screen
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    if (_formKey.currentState?.validate() ?? false) {
      String userId = userIdController.text;
      String password = passwordController.text;

      try {
        final response = await http.get(
          Uri.parse('http://127.0.0.1:5000/fetch/id/teacherorstudent?id=$userId'),
        );

        if (response.statusCode == 200) {
          final data= json.decode(response.body);
          String userType = data['type'];

          if (userType == 'S') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenS(studentId: userId),
              ),
            );
          } else if (userType == 'T') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenT(teacherId: userId),
              ),
            );
          } else if (userType == 'N') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user found')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected response from server')),
            );
          }
        } else {
          throw Exception('Failed to check user type');
        }
      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hey!\nWelcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: userIdController,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your User ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      child: Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                      child: Text('Or sign up here'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("Terms & Conditions Apply*"),
            ],
          ),
        ),
      ),
    );
  }
}
