class WeatherResponse {
  final String cityName;
  final int timezone;
  final TemperatureInfo temperatureInfo;
  final WeatherInfo weatherInfo;
  final int visibility;
  final WindInfo windInfo;
  final SystemInfo systemInfo;

  String get iconUrl {
    return 'https://openweathermap.org/img/wn/${weatherInfo.icon}@2x.png';
  }

  WeatherResponse(
      {required this.cityName,
        required this.timezone,
      required this.temperatureInfo,
      required this.weatherInfo,
      required this.visibility,
      required this.windInfo,
      required this.systemInfo});

  factory WeatherResponse.fromJSON(Map<String, dynamic> json) {
    final cityName = json['name'];
    final timezone = json['timezone'];
    final visibility = json['visibility'];

    final temperatureJSON = json['main'];
    final temperatureInfo = TemperatureInfo.fromJSON(temperatureJSON);

    final weatherJSON = json['weather'][0];
    final weatherInfo = WeatherInfo.fromJSON(weatherJSON);

    final windJSON = json['wind'];
    final windInfo = WindInfo.fromJSON(windJSON);

    final systemJSON = json['sys'];
    final systemInfo = SystemInfo.fromJSON(systemJSON);

    return WeatherResponse(
        cityName: cityName,
        timezone: timezone,
        temperatureInfo: temperatureInfo,
        weatherInfo: weatherInfo,
        visibility: visibility,
        windInfo: windInfo,
        systemInfo: systemInfo);
  }
}

class TemperatureInfo {
  final num temperature;
  final num feelsLike;
  final num minTemperature;
  final num maxTemperature;
  final num pressure;
  final num humidity;

  TemperatureInfo(
      {required this.temperature,
      required this.feelsLike,
      required this.minTemperature,
      required this.maxTemperature,
      required this.pressure,
      required this.humidity});

  factory TemperatureInfo.fromJSON(Map<String, dynamic> json) =>
      TemperatureInfo(
          temperature: json['temp'],
          feelsLike: json['feels_like'],
          minTemperature: json['temp_min'],
          maxTemperature: json['temp_max'],
          pressure: json['pressure'],
          humidity: json['humidity']);
}

class WeatherInfo {
  final String title;
  final String desc;
  final String icon;

  WeatherInfo({required this.title, required this.desc, required this.icon});

  factory WeatherInfo.fromJSON(Map<String, dynamic> json) {
    final title = json['main'];
    final desc = json['description'];
    final icon = json['icon'];

    return WeatherInfo(title: title, desc: desc, icon: icon);
  }
}

class WindInfo {
  final num speed;
  final num degree;
  final num gust;

  WindInfo({required this.speed, required this.degree, required this.gust});

  factory WindInfo.fromJSON(Map<String, dynamic> json) => WindInfo(
      speed: json['speed'], degree: json['deg'], gust: json['gust'] ?? 0);
}

class SystemInfo {
  final String country;
  final int sunrise;
  final int sunset;

  SystemInfo(
      {required this.country, required this.sunrise, required this.sunset});

  factory SystemInfo.fromJSON(Map<String, dynamic> json) => SystemInfo(
      country: json['country'],
      sunrise: json['sunrise'],
      sunset: json['sunset']);
}
