import 'package:flutter/material.dart';
import 'package:untitled5/sign_up_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAD OAuth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUpScreen(),
      navigatorKey: navigatorKey,
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>();