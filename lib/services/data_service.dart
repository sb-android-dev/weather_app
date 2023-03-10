import 'dart:convert';
import 'api_key.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_response.dart';

class DataService {
  Future<WeatherResponse> getWeather(String city) async {
    //https://api.openweathermap.org/data/2.5/weather?q={city name}&units={standard}&appid={API key}

    final queryParameters = {
      'q': city,
      'units': 'metric',
      'appid': API_KEY,
    };

    final uri = Uri.https(
        'api.openweathermap.org', '/data/2.5/weather', queryParameters);

    final response = await http.get(uri);

    if (kDebugMode) {
      print(response.body);
    }

    final json = jsonDecode(response.body);
    return WeatherResponse.fromJSON(json);
  }
}
