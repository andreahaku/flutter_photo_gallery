import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_gallery/models/main_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scoped_model/scoped_model.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<Timer> _loadData() async {
    // loads all values persisted in 'shared_preferences'
    await ScopedModel.of<MainModel>(context).loadAllUserValues();

    //moves to the home page automatically
    return Timer(const Duration(seconds: 5), _onDoneLoading);
  }

  void _onDoneLoading() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'), fit: BoxFit.cover),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Shimmer.fromColors(
          baseColor: Colors.white30,
          highlightColor: Colors.white,
          period: const Duration(milliseconds: 2400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Photo Gallery',
                style: TextStyle(
                    fontSize: 42.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
                textScaleFactor: 1.0,
              ),
              Text(
                'version 1.0.0',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w100,
                    color: Colors.white),
                textScaleFactor: 1.0,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
