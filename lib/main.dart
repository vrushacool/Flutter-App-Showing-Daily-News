import 'package:flutter/material.dart';

import 'news.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "News",
      theme: ThemeData(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline1: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                headline2: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
          primaryColor: Colors.red,
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.black),
            backgroundColor: Colors.deepOrange,
          ),
          primaryTextTheme: TextTheme(
            headline6: TextStyle(color: Colors.black),
          )

          /* light theme settings */
          ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      home: News(),
    );
  }
}
