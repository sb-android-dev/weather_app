import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_response.dart';
import 'package:weather_app/services/data_service.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({Key? key}) : super(key: key);

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final dataService = DataService();
  final cityController = TextEditingController();

  WeatherResponse? _response;
  var isLoading = false;
  Position? currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 135, 206, 235),
      appBar: AppBar(
        title: const Text("Today's Weather"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 135, 206, 235),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_response != null)
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCityTitle(
                          _response!.cityName, _response!.systemInfo.country),
                      Image.network(_response!.iconUrl, fit: BoxFit.contain, width: 80, height: 80,),
                      Text(
                        _response!.weatherInfo.title,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildTemperature(_response!.temperatureInfo),
                      const SizedBox(
                        height: 16,
                      ),
                      Card(
                        margin: const EdgeInsets.all(16),
                        color: const Color.fromARGB(255, 189, 228, 244),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            _buildOtherInfo(_response!.temperatureInfo,
                                _response!.visibility),
                            const Divider(
                              height: 2,
                              indent: 16,
                              endIndent: 16,
                              color: Colors.black12,
                            ),
                            _buildWindInfo(_response!.windInfo),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildSunInfo()
                    ],
                  ),
                ),
              ),
            Expanded(
              flex: 0,
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.streetAddress,
                          decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintText: 'Enter city name',
                              prefixIcon:
                                  const Icon(Icons.location_city_rounded),
                              suffixIcon: GestureDetector(
                                onTap: getCurrentLocation,
                                child: const Icon(Icons.my_location),
                              )),
                          controller: cityController,
                        ),
                      ),
                      const Flexible(
                          flex: 0,
                          child: SizedBox(
                            width: 8,
                          )),
                      Flexible(
                          flex: 0,
                          child: ElevatedButton(
                              onPressed: getWeather, child: const Text('View')))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTitle(String cityName, String country) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on_outlined, size: 20),
          Text(
            '$cityName, $country',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperature(TemperatureInfo temperatureInfo) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            '${temperatureInfo.temperature}° C',
            style: const TextStyle(fontSize: 40),
          ),
          Text('Feels like ${temperatureInfo.feelsLike}° C')
        ],
      ),
    );
  }

  Widget _buildOtherInfo(TemperatureInfo temperatureInfo, int visibility) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoWidget(temperatureInfo.pressure, 'hPa', 'Pressure'),
        _buildInfoWidget(temperatureInfo.humidity, '%', 'Humidity'),
        _buildInfoWidget(visibility < 1000 ? visibility : visibility / 1000,
            visibility < 1000 ? 'm' : 'km', 'Visibility'),
      ],
    );
  }

  Widget _buildWindInfo(WindInfo windInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoWidget(windInfo.speed, 'm/s', 'Speed'),
        _buildInfoWidget(windInfo.degree, '°', 'Degree'),
        // if (windInfo.gust > 0)
        _buildInfoWidget(windInfo.gust, 'm/s', 'Gust'),
      ],
    );
  }

  Widget _buildSunInfo() {
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(
        (_response!.systemInfo.sunrise + _response!.timezone) * 1000,
        isUtc: true);
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(
        (_response!.systemInfo.sunset + _response!.timezone) * 1000,
        isUtc: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSunWidget(sunriseTime, 'sunrise'),
        _buildSunWidget(sunsetTime, 'sunset'),
      ],
    );
  }

  Widget _buildSunWidget(DateTime time, String type) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      color: type == 'sunrise'
          ? const Color.fromARGB(255, 255, 251, 230)
          : const Color.fromARGB(255, 255, 243, 228),
      child: Stack(
        children: [
          Positioned(
            bottom: -8,
            left: -12,
            child: Image.asset(
              'images/$type.png',
              fit: BoxFit.fitHeight,
              height: 60,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 48, top: 12, bottom: 12, right: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '$type at'.toUpperCase(),
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
              Text(
                DateFormat.jm().format(time),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildInfoWidget(num data, String unit, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        RichText(
          text: TextSpan(
              text: '$data',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
              children: [
                TextSpan(
                    text: ' $unit',
                    style: unit.contains('°')
                        ? const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w400)
                        : const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400))
              ]),
        ),
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(color: Colors.black87, fontSize: 12),
        ),
      ]),
    );
  }

  // call API for weather of 'cityName'
  void getWeather() async {
    final cityName = cityController.text;

    final response = await dataService.getWeather(cityName);

    setState(() => _response = response);
  }

  // Check for location permission & get user location
  Future<Position> getPosition() async {
    LocationPermission? permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get address from Latitude & Longitude
  Future<String> getAddress(lat, lng) async {
    try {
      List<Placemark> addresses = await placemarkFromCoordinates(lat, lng);

      Placemark placeMark = addresses[0];
      return placeMark.locality ?? '';
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      setState(() {
        isLoading = true;
      });
      final currentPosition = await getPosition();
      cityController.text =
          await getAddress(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }
}
