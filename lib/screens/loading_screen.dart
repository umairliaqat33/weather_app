import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_app/exceptions/exceptions.dart';
import 'location_screen.dart';
import 'package:weather_app/services/weather.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoadingScreenState();
  }
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }

  void getLocationData() async {
    try {
      bool isLocationPermissionAllowed =
          await WeatherModel.getLocationPermission();
      var weatherData;
      if (isLocationPermissionAllowed) {
        weatherData = await WeatherModel().getLocationWeather();
      } else {
        weatherData = null;
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LocationScreen(
          locationWeather: weatherData,
        );
      }));
    } on LocationPermissionDeniedException catch (e) {
      log(e.message);
    }
  }
}
