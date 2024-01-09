import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:weather_app/services/location.dart';
import 'package:weather_app/services/networking.dart';

const apiKey = 'ce68ee2c81a37ac4e4796f81f29b6b71';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  static Future<bool> getLocationPermission() async {
    bool isLocationPermissionAllowed = false;
    LocationPermission permission;
    try {
      await Geolocator.isLocationServiceEnabled();
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        Geolocator.openLocationSettings();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        isLocationPermissionAllowed = true;
      } else
        isLocationPermissionAllowed = false;
    } catch (e) {
      log(e.toString());

      if (e.toString() != "Location services not enabled") {
        throw const LocationServiceDisabledException();
      }
    }
    return isLocationPermissionAllowed;
  }

  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();

    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
