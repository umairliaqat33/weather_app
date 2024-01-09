import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:weather_app/screens/loading_screen.dart';
import 'package:weather_app/utilities/constants.dart';
import 'package:weather_app/services/weather.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationWeather});

  final locationWeather;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weather = WeatherModel();
  late int temperature;
  late String weatherIcon;
  late String cityName;
  late String weatherMessage;

  @override
  void initState() {
    super.initState();

    updateUI(widget.locationWeather);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (weatherIcon == 'Error') {
        showDeniedLocationAlert(
          title: "Location Permission Denied",
          description: "Retry or allow location permission to go ahead",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/location_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
            ),
          ),
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      var weatherData = await weather.getLocationWeather();
                      updateUI(weatherData);
                    },
                    icon: Icon(
                      Icons.near_me,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      String cityName = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CityScreen();
                          },
                        ),
                      );
                      var weatherData = await weather.getCityWeather(cityName);
                      if (weatherData == null) {
                        log("erorr");
                        showWeatherDataAlert(
                          title: "City not found",
                          description:
                              "You have entered a wrong city. Get Current location or enter city name again",
                        );
                      } else {
                        updateUI(weatherData);
                      }
                    },
                    icon: Icon(
                      Icons.location_city,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      '$temperature°',
                      style: kTempTextStyle,
                    ),
                    Text(
                      weatherIcon,
                      style: kConditionTextStyle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  '$weatherMessage in $cityName',
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = 'Error';
        weatherMessage = 'Unable to get weather data';
        cityName = '';

        return;
      }
      String temp = weatherData['main']['temp'].toString();
      temperature = double.parse(temp).toInt();
      var condition = weatherData['weather'][0]['id'];
      weatherIcon = weather.getWeatherIcon(condition);
      weatherMessage = weather.getMessage(temperature);
      cityName = weatherData['name'];
    });
  }

  void showWeatherDataAlert({
    required String title,
    required String description,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
            ),
            content: Text(
              description,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      var weatherData = await weather.getLocationWeather();
                      updateUI(weatherData);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.near_me,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      String cityName = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CityScreen();
                          },
                        ),
                      );
                      var weatherData = await weather.getCityWeather(cityName);
                      if (weatherData == null) {
                        log("erorr");
                      } else {
                        updateUI(weatherData);
                      }
                    },
                    icon: Icon(
                      Icons.location_city,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  void showDeniedLocationAlert({
    required String title,
    required String description,
  }) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
            ),
            content: Text(
              description,
            ),
            actions: [
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoadingScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 30.0,
                            color: Colors.white,
                          ),
                          Text(
                            "Retry",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
