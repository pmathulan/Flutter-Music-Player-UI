import 'package:flutter/material.dart';
import 'homePage.dart';

void main() {
  runApp(MyApp());
}

//=> runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0Xff34385e),
      ),
      home: MyHomePage(),
    );
  }
}
