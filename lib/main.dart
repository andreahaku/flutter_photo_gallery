import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_gallery/pages/home.dart';
import 'package:photo_gallery/pages/splashscreen.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/main_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScopedModel<MainModel>(
        model: MainModel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => SplashScreen(),
            '/home': (BuildContext context) => Home(),
          },
        ));
  }
}
