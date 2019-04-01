import 'package:flutter/material.dart';

AssetImage _background = new AssetImage("assets/bg.png");
final _uburner = Image.asset("assets/logo.png");

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey,
          image: new DecorationImage(
            image: _background,
            fit: BoxFit.cover,
          ),
        ),
        child: _uburner,
      ),
    );
  }
}
