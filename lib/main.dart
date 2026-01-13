import 'package:flutter/material.dart';
import 'package:global_search_window/presentation/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Widget',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SearchScreen(),
    );
  }
}

        // Center is a layout widget. It takes a single child and positions it
    