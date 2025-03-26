import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Google Fonts Example",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Text(
            "Hello, Flutter!",
            style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}